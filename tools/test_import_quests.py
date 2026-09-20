#!/usr/bin/env python3
"""Offline tests for tools/import_quests.py."""

from __future__ import annotations

import copy
import json
import sys
import unittest
from pathlib import Path

TOOLS_DIR = Path(__file__).resolve().parent
ROOT = TOOLS_DIR.parent
sys.path.insert(0, str(TOOLS_DIR))

import import_quests as importer  # noqa: E402


def load_fixture(name: str):
    with (TOOLS_DIR / "fixtures" / name).open("r", encoding="utf-8") as handle:
        return json.load(handle)


class ImportQuestTests(unittest.TestCase):
    def test_classic_fixture_validates(self):
        batch = importer.validate_batch(load_fixture("import_classic_sample.json"))
        self.assertEqual(batch["layer"], "classic")
        self.assertEqual([q["id"] for q in batch["quests"]], [990000101, 990000102])

    def test_forever_fixture_validates(self):
        batch = importer.validate_batch(load_fixture("import_forever_sample.json"))
        self.assertEqual(batch["layer"], "forever")
        self.assertEqual(
            [q["operation"] for q in batch["quests"]],
            ["merge", "replace", "remove"],
        )

    def test_output_is_deterministic_and_sorted(self):
        raw = load_fixture("import_classic_sample.json")
        raw["quests"] = list(reversed(raw["quests"]))
        batch = importer.validate_batch(raw)

        first = importer.render_lua(batch)
        second = importer.render_lua(batch)

        self.assertEqual(first, second)
        self.assertLess(first.index("990000101"), first.index("990000102"))

    def test_forever_modes_render_explicitly_only_when_needed(self):
        batch = importer.validate_batch(load_fixture("import_forever_sample.json"))
        rendered = importer.render_lua(batch)

        self.assertNotIn('_mode = "merge"', rendered)
        self.assertIn('_mode = "replace"', rendered)
        self.assertIn('_mode = "remove"', rendered)

    def test_dynamic_fields_render(self):
        batch = importer.validate_batch(load_fixture("import_classic_sample.json"))
        rendered = importer.render_lua(batch)

        self.assertIn("_dynamicFields = {", rendered)
        self.assertIn('description = { "class" },', rendered)

    def test_duplicate_id_is_rejected(self):
        raw = load_fixture("import_classic_sample.json")
        raw["quests"].append(copy.deepcopy(raw["quests"][0]))

        with self.assertRaises(importer.ValidationError):
            importer.validate_batch(raw)

    def test_unknown_dynamic_token_is_rejected(self):
        raw = load_fixture("import_classic_sample.json")
        raw["quests"][1]["dynamicFields"]["description"] = ["unknown"]

        with self.assertRaises(importer.ValidationError):
            importer.validate_batch(raw)

    def test_classic_missing_hash_is_rejected(self):
        raw = load_fixture("import_classic_sample.json")
        del raw["quests"][0]["sourceHashes"]["description"]

        with self.assertRaises(importer.ValidationError):
            importer.validate_batch(raw)

    def test_lua_string_escapes_control_characters(self):
        rendered = importer.lua_string('A"\\B\nC\tD')
        self.assertTrue(rendered.startswith('"') and rendered.endswith('"'))
        self.assertIn('\\\"', rendered)
        self.assertIn('\\\\', rendered)
        self.assertIn("\\n", rendered)
        self.assertIn("\\t", rendered)


if __name__ == "__main__":
    unittest.main()
