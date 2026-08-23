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


def table_schema(column_count):
    if column_count >= 45:
        return (
            (1, 3, 6, 5),
            (10, 12, 14, 13),
            (17, 19, 22, 21),
            (25, 27, 29, 28),
            (32, 34, 36, 35),
            (39, 41, 44, 43),
        )
    if column_count >= 24:
        return (
            (1, 2, 4, None),
            (6, 7, 8, None),
            (9, 10, 12, None),
            (14, 15, 16, None),
            (17, 18, 19, None),
            (20, 21, 23, None),
        )
    if column_count == 22:
        return tuple(
            (3 + day * 3, 4 + day * 3, 5 + day * 3, None)
            for day in range(6)
        )
    if column_count == 19:
        return tuple(
            (1 + day * 3, 2 + day * 3, 3 + day * 3, None)
            for day in range(6)
        )
    raise ValueError(
        f"Unsupported schedule table layout: {column_count} columns"
    )


def extract_events_from_table(table, instructor, start_date):
    events = []
    starts = period_starts(table)
    schema = table_schema(max(len(row) for row in table))
    for row_index, row in enumerate(table):
        for day_index, columns in enumerate(schema):
            column_index, student_column, subject_column, number_column = columns
            if column_index >= len(row):
                continue
            cell = row[column_index]
            if not cell or instructor not in str(cell):
                continue
            if student_column >= len(row) or subject_column >= len(row):
                continue

            period_index = period_for_row(row_index, starts)
            if period_index is None or period_index >= len(PERIOD_TIMES):
                continue

            students = clean_lines(row[student_column])
            subject_lines = clean_lines(row[subject_column])
            number_lines = (
                clean_lines(row[number_column])
                if number_column is not None and number_column < len(row)
                else []
            )
            continuation_index = row_index + 1
            while continuation_index < len(table):
                continuation = table[continuation_index]
                if max(column_index, student_column, subject_column) >= len(continuation):
                    break
                if clean_lines(continuation[column_index]):
                    break
                next_students = clean_lines(continuation[student_column])
                next_subjects = clean_lines(continuation[subject_column])
                if not next_students and not next_subjects:
                    if period_for_row(continuation_index, starts) != period_index:
                        break
                    continuation_index += 1
                    continue
                students.extend(next_students)
                subject_lines.extend(next_subjects)
                if number_column is not None and number_column < len(continuation):
                    number_lines.extend(clean_lines(continuation[number_column]))
                continuation_index += 1

            subjects, numbers = split_subjects("\n".join(subject_lines))
            if number_lines:
                numbers = number_lines
            if not students and not subjects:
                continue
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
    return events


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
                events.extend(extract_events_from_table(table, instructor, start_date))

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
