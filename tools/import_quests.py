#!/usr/bin/env python3
"""ForeverITA development importer: validated JSON batch -> deterministic Lua."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

TEXT_FIELDS = ("title", "description", "objectives", "progress", "completion")
BODY_FIELDS = ("description", "objectives", "progress", "completion")
VALID_LAYERS = {"classic", "forever"}
VALID_OPERATIONS = {"merge", "replace", "remove"}
VALID_STATUSES = {"draft", "reviewed", "verified_classic", "verified_forever"}
VALID_DYNAMIC_TOKENS = {"class", "race"}
GROUP_RE = re.compile(r"^[A-Za-z0-9_-]+$")
HASH_RE = re.compile(r"^f\d+-\d+$")


class ValidationError(ValueError):
    pass


def fail(message: str) -> None:
    raise ValidationError(message)


def nonempty_string(value: Any) -> bool:
    return isinstance(value, str) and bool(value.strip())


def require_known_keys(obj: dict[str, Any], allowed: set[str], where: str) -> None:
    unknown = sorted(set(obj) - allowed)
    if unknown:
        fail(f"{where}: campi non riconosciuti: {', '.join(unknown)}")


def validate_defaults(defaults: Any) -> dict[str, str]:
    if defaults is None:
        return {}
    if not isinstance(defaults, dict):
        fail("defaults deve essere un oggetto JSON")

    allowed = {"status", "sourceClient", "sourceBuild"}
    require_known_keys(defaults, allowed, "defaults")

    out: dict[str, str] = {}
    for key, value in defaults.items():
        if not nonempty_string(value):
            fail(f"defaults.{key} deve essere una stringa non vuota")
        out[key] = value

    if "status" in out and out["status"] not in VALID_STATUSES:
        fail(f"defaults.status non valido: {out['status']}")

    return out


def validate_translation(value: Any, quest_id: int) -> dict[str, str]:
    if value is None:
        return {}
    if not isinstance(value, dict):
        fail(f"quest {quest_id}: translation deve essere un oggetto")

    require_known_keys(value, set(TEXT_FIELDS), f"quest {quest_id}.translation")

    out: dict[str, str] = {}
    for field in TEXT_FIELDS:
        if field in value:
            if not nonempty_string(value[field]):
                fail(f"quest {quest_id}: translation.{field} deve essere una stringa non vuota")
            out[field] = value[field]
    return out


def validate_hashes(value: Any, quest_id: int) -> dict[str, str]:
    if value is None:
        return {}
    if not isinstance(value, dict):
        fail(f"quest {quest_id}: sourceHashes deve essere un oggetto")

    require_known_keys(value, set(TEXT_FIELDS), f"quest {quest_id}.sourceHashes")

    out: dict[str, str] = {}
    for field in TEXT_FIELDS:
        if field in value:
            hash_value = value[field]
            if not isinstance(hash_value, str) or not HASH_RE.fullmatch(hash_value):
                fail(f"quest {quest_id}: sourceHashes.{field} ha formato non valido")
            out[field] = hash_value
    return out


def validate_dynamic_fields(value: Any, quest_id: int) -> dict[str, list[str]]:
    if value is None:
        return {}
    if not isinstance(value, dict):
        fail(f"quest {quest_id}: dynamicFields deve essere un oggetto")

    require_known_keys(value, set(TEXT_FIELDS), f"quest {quest_id}.dynamicFields")

    out: dict[str, list[str]] = {}
    for field in TEXT_FIELDS:
        if field not in value:
            continue
        tokens = value[field]
        if not isinstance(tokens, list) or not tokens:
            fail(f"quest {quest_id}: dynamicFields.{field} deve essere una lista non vuota")

        cleaned: list[str] = []
        seen: set[str] = set()
        for token in tokens:
            if not isinstance(token, str) or token not in VALID_DYNAMIC_TOKENS:
                fail(f"quest {quest_id}: dynamicFields.{field} contiene token non valido: {token!r}")
            if token in seen:
                fail(f"quest {quest_id}: dynamicFields.{field} contiene token duplicato: {token}")
            seen.add(token)
            cleaned.append(token)
        out[field] = cleaned

    return out


def validate_meta(value: Any, defaults: dict[str, str], quest_id: int) -> dict[str, str]:
    if value is None:
        value = {}
    if not isinstance(value, dict):
        fail(f"quest {quest_id}: meta deve essere un oggetto")

    allowed = {"status", "sourceClient", "sourceBuild", "terminologyNote", "provenance"}
    require_known_keys(value, allowed, f"quest {quest_id}.meta")

    out = dict(defaults)
    for key, item in value.items():
        if not nonempty_string(item):
            fail(f"quest {quest_id}: meta.{key} deve essere una stringa non vuota")
        out[key] = item

    if "status" in out and out["status"] not in VALID_STATUSES:
        fail(f"quest {quest_id}: meta.status non valido: {out['status']}")

    return out


def validate_batch(raw: Any) -> dict[str, Any]:
    if not isinstance(raw, dict):
        fail("il file radice deve essere un oggetto JSON")

    require_known_keys(raw, {"schema", "layer", "group", "defaults", "quests"}, "batch")

    if raw.get("schema") != 1:
        fail(f"schema non supportato: {raw.get('schema')!r}")

    layer = raw.get("layer")
    if layer not in VALID_LAYERS:
        fail("layer deve essere classic oppure forever")

    group = raw.get("group")
    if not isinstance(group, str) or not GROUP_RE.fullmatch(group):
        fail("group deve contenere solo lettere ASCII, numeri, trattino o underscore")

    defaults = validate_defaults(raw.get("defaults"))

    quests = raw.get("quests")
    if not isinstance(quests, list):
        fail("quests deve essere una lista")

    normalized: list[dict[str, Any]] = []
    seen_ids: set[int] = set()

    for index, quest in enumerate(quests):
        where = f"quests[{index}]"
        if not isinstance(quest, dict):
            fail(f"{where} deve essere un oggetto")

        require_known_keys(
            quest,
            {"id", "translation", "sourceHashes", "dynamicFields", "meta", "operation"},
            where,
        )

        quest_id = quest.get("id")
        if isinstance(quest_id, bool) or not isinstance(quest_id, int) or quest_id <= 0:
            fail(f"{where}.id deve essere un intero positivo")
        if quest_id in seen_ids:
            fail(f"QuestID duplicato nello stesso batch: {quest_id}")
        seen_ids.add(quest_id)

        operation = quest.get("operation", "merge")
        if operation not in VALID_OPERATIONS:
            fail(f"quest {quest_id}: operation non valida: {operation}")
        if layer == "classic" and "operation" in quest:
            fail(f"quest {quest_id}: operation è ammessa soltanto nel layer forever")

        translation = validate_translation(quest.get("translation"), quest_id)
        hashes = validate_hashes(quest.get("sourceHashes"), quest_id)
        dynamic_fields = validate_dynamic_fields(quest.get("dynamicFields"), quest_id)
        meta = validate_meta(quest.get("meta"), defaults, quest_id)

        if operation == "remove":
            if layer != "forever":
                fail(f"quest {quest_id}: remove è ammesso soltanto nel layer forever")
            if translation or hashes or dynamic_fields:
                fail(f"quest {quest_id}: remove non deve contenere translation/sourceHashes/dynamicFields")
        elif layer == "classic":
            if not nonempty_string(translation.get("title")):
                fail(f"quest {quest_id}: title obbligatorio per un record Classic")
            if not any(nonempty_string(translation.get(field)) for field in BODY_FIELDS):
                fail(f"quest {quest_id}: serve almeno un campo narrativo/obiettivo")
            for required in ("status", "sourceClient", "sourceBuild"):
                if not nonempty_string(meta.get(required)):
                    fail(f"quest {quest_id}: meta.{required} obbligatorio per un record Classic")
            for field in translation:
                if field not in hashes:
                    fail(f"quest {quest_id}: sourceHashes.{field} mancante")
        else:
            if operation != "remove" and not translation:
                fail(f"quest {quest_id}: un override Forever non-remove deve contenere almeno una traduzione")

        for field in dynamic_fields:
            if field not in translation:
                fail(f"quest {quest_id}: dynamicFields.{field} richiede translation.{field}")

        normalized.append(
            {
                "id": quest_id,
                "operation": operation,
                "translation": translation,
                "sourceHashes": hashes,
                "dynamicFields": dynamic_fields,
                "meta": meta,
            }
        )

    normalized.sort(key=lambda item: item["id"])
    return {
        "schema": 1,
        "layer": layer,
        "group": group,
        "quests": normalized,
    }


def lua_string(value: str) -> str:
    pieces: list[str] = ['"']
    for char in value:
        code = ord(char)
        if char == "\\":
            pieces.append("\\\\")
        elif char == '"':
            pieces.append('\\"')
        elif char == "\n":
            pieces.append("\\n")
        elif char == "\r":
            pieces.append("\\r")
        elif char == "\t":
            pieces.append("\\t")
        elif code < 32 or code == 127:
            pieces.append(f"\\{code:03d}")
        else:
            pieces.append(char)
    pieces.append('"')
    return "".join(pieces)


def render_mapping(lines: list[str], name: str, mapping: dict[str, Any], indent: str) -> None:
    if not mapping:
        return
    lines.append(f"{indent}{name} = {{")
    for field in TEXT_FIELDS:
        if field not in mapping:
            continue
        value = mapping[field]
        if isinstance(value, list):
            rendered = ", ".join(lua_string(item) for item in value)
            lines.append(f"{indent}    {field} = {{ {rendered} }},")
        else:
            lines.append(f"{indent}    {field} = {lua_string(value)},")
    lines.append(f"{indent}}},")


def render_lua(batch: dict[str, Any]) -> str:
    layer = batch["layer"]
    lines = [
        "local addonName, private = ...",
        "",
        "local FIT = private",
        'if type(FIT) ~= "table" then',
        "    FIT = _G.ForeverITA_NS",
        "end",
        'if type(FIT) ~= "table" or not FIT.Data then',
        "    return",
        "end",
        "",
        "-- Generated by tools/import_quests.py.",
        f"-- Source batch group: {batch['group']}",
        "-- Do not edit generated ordering by hand.",
        "",
    ]

    for quest in batch["quests"]:
        lines.append(f'FIT.Data:RegisterQuest("{layer}", {quest["id"]}, {{')

        for field in TEXT_FIELDS:
            if field in quest["translation"]:
                lines.append(f"    {field} = {lua_string(quest['translation'][field])},")

        if layer == "forever" and quest["operation"] in {"replace", "remove"}:
            lines.append(f'    _mode = "{quest["operation"]}",')

        render_mapping(lines, "_sourceHashes", quest["sourceHashes"], "    ")
        render_mapping(lines, "_dynamicFields", quest["dynamicFields"], "    ")

        meta = quest["meta"]
        if meta:
            lines.append("    _meta = {")
            lines.append("        synthetic = false,")
            for key in ("status", "sourceClient", "sourceBuild", "provenance", "terminologyNote"):
                if key in meta:
                    lines.append(f"        {key} = {lua_string(meta[key])},")
            lines.append("    },")

        lines.append("})")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def load_json(path: Path) -> Any:
    try:
        with path.open("r", encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError:
        fail(f"file non trovato: {path}")
    except json.JSONDecodeError as exc:
        fail(f"JSON non valido a riga {exc.lineno}, colonna {exc.colno}: {exc.msg}")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Valida un batch traduzioni ForeverITA e genera Lua deterministico."
    )
    parser.add_argument("input", type=Path, help="File JSON schema 1")
    parser.add_argument("--output", type=Path, help="File Lua da generare")
    parser.add_argument("--check", action="store_true", help="Valida soltanto, senza scrivere")
    args = parser.parse_args(argv)

    if not args.check and args.output is None:
        parser.error("--output è obbligatorio quando non si usa --check")
    if args.check and args.output is not None:
        parser.error("--check non può essere combinato con --output")
    return args


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv if argv is not None else sys.argv[1:])

    try:
        raw = load_json(args.input)
        batch = validate_batch(raw)

        if args.check:
            print(
                f"OK: {len(batch['quests'])} quest valide "
                f"(layer={batch['layer']}, group={batch['group']})"
            )
            return 0

        rendered = render_lua(batch)
        assert args.output is not None
        args.output.parent.mkdir(parents=True, exist_ok=True)
        with args.output.open("w", encoding="utf-8", newline="\n") as handle:
            handle.write(rendered)

        print(f"OK: scritto {args.output} ({len(batch['quests'])} quest)")
        return 0

    except ValidationError as exc:
        print(f"ERRORE: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
