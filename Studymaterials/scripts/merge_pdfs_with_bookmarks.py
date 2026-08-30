import json
import sys
from pathlib import Path

try:
    from pypdf import PdfReader, PdfWriter
except ImportError as exc:
    raise SystemExit(
        "pypdf が見つかりません。しおり付きPDFを作るには `python -m pip install pypdf` を実行してください。"
    ) from exc


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python merge_pdfs_with_bookmarks.py manifest.json", file=sys.stderr)
        return 2

    manifest_path = Path(sys.argv[1])
    manifest = json.loads(manifest_path.read_text(encoding="utf-8-sig"))
    output_path = Path(manifest["output"])
    output_path.parent.mkdir(parents=True, exist_ok=True)

    writer = PdfWriter()

    for entry in manifest["entries"]:
        source_path = Path(entry["pdf"])
        title = str(entry["title"])
        reader = PdfReader(str(source_path))
        start_page = len(writer.pages)

        for page in reader.pages:
            writer.add_page(page)

        if len(reader.pages) > 0:
            writer.add_outline_item(title, start_page)

    with output_path.open("wb") as output_file:
        writer.write(output_file)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
