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

    def test_classic_extra_hash_without_translation_is_rejected(self):
        raw = load_fixture("import_classic_sample.json")
        raw["quests"][0]["sourceHashes"]["completion"] = "f3-9999"

        with self.assertRaises(importer.ValidationError):
            importer.validate_batch(raw)

    def test_old_hash_schema_is_rejected(self):
        raw = load_fixture("import_classic_sample.json")
        raw["quests"][0]["sourceHashes"]["title"] = "f2-123"

        with self.assertRaises(importer.ValidationError):
            importer.validate_batch(raw)

    def test_classic_rejects_verified_forever(self):
        raw = load_fixture("import_classic_sample.json")
        raw["defaults"]["status"] = "verified_forever"

        with self.assertRaises(importer.ValidationError):
            importer.validate_batch(raw)

    def test_forever_rejects_verified_classic(self):
        raw = load_fixture("import_forever_sample.json")
        raw["defaults"]["status"] = "verified_classic"

        with self.assertRaises(importer.ValidationError):
            importer.validate_batch(raw)

    def test_verified_forever_requires_source_build(self):
        raw = load_fixture("import_forever_sample.json")
        raw["defaults"] = {
            "status": "verified_forever",
            "sourceClient": "Forever synthetic",
        }

        with self.assertRaises(importer.ValidationError):
            importer.validate_batch(raw)

    def test_verified_forever_translation_requires_hash(self):
        raw = load_fixture("import_forever_sample.json")
        raw["defaults"]["status"] = "verified_forever"
        del raw["quests"][0]["sourceHashes"]["title"]

        with self.assertRaises(importer.ValidationError):
            importer.validate_batch(raw)

    def test_verified_forever_metadata_only_override_is_allowed(self):
        raw = {
            "schema": 1,
            "layer": "forever",
            "group": "VerifiedMetadataOnly",
            "defaults": {
                "status": "verified_forever",
                "sourceClient": "Forever synthetic",
                "sourceBuild": "0",
            },
            "quests": [
                {
                    "id": 990000201,
                    "operation": "merge",
                    "meta": {
                        "provenance": "ForeverITA synthetic importer fixture",
                    },
                }
            ],
        }

        batch = importer.validate_batch(raw)
        rendered = importer.render_lua(batch)

        self.assertEqual(batch["quests"][0]["translation"], {})
        self.assertIn('status = "verified_forever"', rendered)
        self.assertNotIn('_mode = "merge"', rendered)

    def test_forever_dynamic_field_can_target_inherited_translation(self):
        raw = {
            "schema": 1,
            "layer": "forever",
            "group": "InheritedDynamicField",
            "defaults": {
                "status": "draft",
                "sourceClient": "Forever synthetic",
                "sourceBuild": "0",
            },
            "quests": [
                {
                    "id": 990000101,
                    "operation": "merge",
                    "dynamicFields": {
                        "description": ["class"],
                    },
                    "meta": {
                        "provenance": "ForeverITA synthetic importer fixture",
                    },
                }
            ],
        }

        batch = importer.validate_batch(raw)
        rendered = importer.render_lua(batch)

        self.assertIn("_dynamicFields = {", rendered)
        self.assertIn('description = { "class" },', rendered)

    def test_forever_replace_requires_translation(self):
        raw = {
            "schema": 1,
            "layer": "forever",
            "group": "InvalidReplace",
            "defaults": {
                "status": "verified_forever",
                "sourceClient": "Forever synthetic",
                "sourceBuild": "0",
            },
            "quests": [
                {
                    "id": 990000202,
                    "operation": "replace",
                    "meta": {
                        "provenance": "ForeverITA synthetic importer fixture",
                    },
                }
            ],
        }

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
