import argparse
import json
import re
from datetime import datetime, timedelta

import pdfplumber


PERIOD_TIMES = (
    ("15:10", "16:40"),
    ("16:50", "18:20"),
    ("18:30", "20:00"),
    ("20:10", "21:40"),
)
DEFAULT_PERIOD_ROWS = (1, 10, 22, 36)
NUMBER_PATTERN = re.compile(r"^(.*?)[\s\u3000]*([0-9]+|[\u2460-\u2473])$")


def clean_lines(value):
    if value is None:
        return []
    return [
        re.sub(r"[\t \u3000]+", " ", line).strip()
        for line in str(value).splitlines()
        if line.strip()
    ]


def split_subjects(value):
    raw_lines = clean_lines(value)
    subjects = []
    numbers = []
    all_numbered = True
    for line in raw_lines:
        match = NUMBER_PATTERN.match(line)
        if match and match.group(1).strip():
            subjects.append(match.group(1).strip())
            numbers.append(match.group(2))
        else:
            subjects.append(line)
            numbers.append("")
            all_numbered = False
    if not all_numbered:
        return raw_lines, [""] * len(raw_lines)
    return subjects, numbers


def period_starts(table):
    starts = list(DEFAULT_PERIOD_ROWS)
    labels = {"A": 0, "B": 1, "C": 2, "D": 3, "Ａ": 0, "Ｂ": 1, "Ｃ": 2, "Ｄ": 3}
    for row_index, row in enumerate(table):
        if not row:
            continue
        label = str(row[0] or "").strip()
        if label in labels:
            starts[labels[label]] = row_index
    return starts


def period_for_row(row_index, starts):
    result = None
    for index, start in enumerate(starts):
        if row_index >= start:
            result = index
    return result


def extract_events(pdf_path, config_path, start_date):
    with open(config_path, encoding="utf-8-sig") as config_file:
        instructor = str(json.load(config_file).get("instructorName", "")).strip()
    if not instructor:
        raise ValueError("Instructor name is not configured")

    events = []
    table_found = False
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            for table in page.extract_tables():
                if not table or len(table) < 10:
                    continue
                table_found = True
                starts = period_starts(table)
                for row_index, row in enumerate(table):
                    for column_index, cell in enumerate(row):
                        if not cell or instructor not in str(cell):
                            continue
                        if column_index < 1 or (column_index - 1) % 3 != 0:
                            continue
                        if column_index + 2 >= len(row):
                            continue

                        day_index = (column_index - 1) // 3
                        if day_index < 0 or day_index > 5:
                            continue
                        period_index = period_for_row(row_index, starts)
                        if period_index is None or period_index >= len(PERIOD_TIMES):
                            continue

                        students = clean_lines(row[column_index + 1])
                        subject_lines = clean_lines(row[column_index + 2])
                        continuation_index = row_index + 1
                        while continuation_index < len(table):
                            continuation = table[continuation_index]
                            if column_index + 2 >= len(continuation):
                                break
                            if clean_lines(continuation[column_index]):
                                break
                            next_students = clean_lines(continuation[column_index + 1])
                            next_subjects = clean_lines(continuation[column_index + 2])
                            if not next_students and not next_subjects:
                                break
                            students.extend(next_students)
                            subject_lines.extend(next_subjects)
                            continuation_index += 1

                        subjects, numbers = split_subjects("\n".join(subject_lines))
                        event_date = start_date + timedelta(days=day_index)
                        events.append(
                            {
                                "date": event_date.isoformat(),
                                "start": PERIOD_TIMES[period_index][0],
                                "end": PERIOD_TIMES[period_index][1],
                                "student": " / ".join(students),
                                "subject": " / ".join(subjects),
                                "number": " / ".join(numbers),
                                "confidence": "embedded-table",
                            }
                        )

    unique = {}
    for event in events:
        key = (event["date"], event["start"])
        unique[key] = event
    return {"supported": table_found, "events": list(unique.values())}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--pdf", required=True)
    parser.add_argument("--config", required=True)
    parser.add_argument("--start-date", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    result = extract_events(
        args.pdf,
        args.config,
        datetime.strptime(args.start_date, "%Y-%m-%d").date(),
    )
    with open(args.output, "w", encoding="utf-8") as output_file:
        json.dump(result, output_file, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    main()
