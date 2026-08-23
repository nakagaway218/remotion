import importlib.util
import unittest
from datetime import date
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("Extract-Schedule-Table.py")
SPEC = importlib.util.spec_from_file_location("schedule_table", MODULE_PATH)
SCHEDULE_TABLE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(SCHEDULE_TABLE)


class ExtractScheduleTableTest(unittest.TestCase):
    def test_detects_supported_table_schemas(self):
        self.assertEqual(SCHEDULE_TABLE.table_schema(19)[1], (4, 5, 6, None))
        self.assertEqual(SCHEDULE_TABLE.table_schema(22)[3], (12, 13, 14, None))
        self.assertEqual(SCHEDULE_TABLE.table_schema(26)[4], (17, 18, 19, None))
        self.assertEqual(SCHEDULE_TABLE.table_schema(50)[4], (32, 34, 36, 35))

    def test_rejects_unknown_table_schema(self):
        with self.assertRaisesRegex(ValueError, "Unsupported schedule table layout"):
            SCHEDULE_TABLE.table_schema(21)

    def test_reads_mixed_numbers_and_blank_row_continuations(self):
        table = [[None] * 26 for _ in range(45)]
        for row_index, label in ((1, "A"), (12, "B"), (24, "C"), (38, "D")):
            table[row_index][0] = label

        table[31][6] = "TEST"
        table[31][7] = "StudentA"
        table[31][8] = "数学"
        table[32][7] = "StudentB"
        table[32][8] = "数学⑥"
        table[33][6] = "NEXT"

        table[26][17] = "TEST"
        table[26][18] = "StudentC"
        table[26][19] = "英語⑤"
        table[28][18] = "StudentノD"
        table[28][19] = "数学⑥"
        table[29][17] = "NEXT"

        events = SCHEDULE_TABLE.extract_events_from_table(
            table, "TEST", date(2026, 8, 3)
        )
        by_date = {event["date"]: event for event in events}

        mixed = by_date["2026-08-04"]
        self.assertEqual(mixed["start"], "18:30")
        self.assertEqual(mixed["student"], "StudentA / StudentB")
        self.assertEqual(mixed["subject"], "数学 / 数学⑥")
        self.assertEqual(mixed["number"], " / ")

        blank_row = by_date["2026-08-07"]
        self.assertEqual(blank_row["student"], "StudentC / StudentノD")
        self.assertEqual(blank_row["subject"], "英語 / 数学")
        self.assertEqual(blank_row["number"], "⑤ / ⑥")

    def test_reads_shifted_22_column_schedule(self):
        table = [[None] * 22 for _ in range(49)]
        for row_index, label in ((1, "A"), (11, "B"), (21, "C"), (35, "D")):
            table[row_index][0] = label

        table[27][6] = "TEST"
        table[27][7] = "StudentA"
        table[27][8] = "数学"
        table[28][7] = "StudentB"
        table[28][8] = "英語⑤"
        table[29][6] = "NEXT"

        table[19][12] = "TEST"
        table[19][13] = "StudentC"
        table[19][14] = "数学⑥"
        table[20][12] = "NEXT"

        table[30][12] = "TEST"
        table[30][13] = "StudentD"
        table[30][14] = "英語"
        table[31][12] = "NEXT"

        events = SCHEDULE_TABLE.extract_events_from_table(
            table, "TEST", date(2026, 8, 31)
        )
        by_slot = {(event["date"], event["start"]): event for event in events}

        tuesday_c = by_slot[("2026-09-01", "18:30")]
        self.assertEqual(tuesday_c["student"], "StudentA / StudentB")
        self.assertEqual(tuesday_c["subject"], "数学 / 英語⑤")
        self.assertEqual(tuesday_c["number"], " / ")

        thursday_b = by_slot[("2026-09-03", "16:50")]
        self.assertEqual(thursday_b["student"], "StudentC")
        self.assertEqual(thursday_b["subject"], "数学")
        self.assertEqual(thursday_b["number"], "⑥")

        thursday_c = by_slot[("2026-09-03", "18:30")]
        self.assertEqual(thursday_c["student"], "StudentD")
        self.assertEqual(thursday_c["subject"], "英語")
        self.assertEqual(thursday_c["number"], "")


if __name__ == "__main__":
    unittest.main()
