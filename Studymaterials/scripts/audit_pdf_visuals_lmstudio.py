from __future__ import annotations

import argparse
import base64
import json
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

from PIL import Image, ImageDraw, ImageOps


ROOT = Path(__file__).resolve().parents[1]
PDF_DIR = ROOT / "output" / "pdf"
WORK_DIR = ROOT / "output" / "pdf_visual_audit_work"
PAGES_DIR = WORK_DIR / "pages"
SHEETS_DIR = WORK_DIR / "sheets"
RESULTS_PATH = WORK_DIR / "lmstudio_results.json"
PDF_RESULTS_PATH = WORK_DIR / "lmstudio_pdf_results.json"
PDFTOPPM = Path(
    r"C:\Users\nakag\.cache\codex-runtimes\codex-primary-runtime\dependencies"
    r"\native\poppler\Library\bin\pdftoppm.exe"
)
API_URL = "http://127.0.0.1:1234/v1/chat/completions"
MODEL = "google/gemma-3-12b"


def render_pdf(pdf_path: Path) -> list[Path]:
    target_dir = PAGES_DIR / pdf_path.stem
    target_dir.mkdir(parents=True, exist_ok=True)
    existing = sorted(target_dir.glob("page-*.jpg"))
    if existing:
        return existing

    prefix = target_dir / "page"
    subprocess.run(
        [
            str(PDFTOPPM),
            "-jpeg",
            "-r",
            "120",
            "-jpegopt",
            "quality=88",
            str(pdf_path),
            str(prefix),
        ],
        check=True,
    )
    return sorted(target_dir.glob("page-*.jpg"))


def make_sheet(pdf_path: Path, page_paths: list[Path], group_index: int) -> Path:
    output_dir = SHEETS_DIR / pdf_path.stem
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / f"sheet-{group_index + 1:02d}.jpg"
    if output_path.exists():
        return output_path

    cell_w, cell_h, label_h = 820, 1160, 34
    sheet = Image.new("RGB", (cell_w * 2, cell_h * 2), "#d5d5d5")
    draw = ImageDraw.Draw(sheet)

    for slot, page_path in enumerate(page_paths):
        row, col = divmod(slot, 2)
        x, y = col * cell_w, row * cell_h
        with Image.open(page_path) as original:
            page = ImageOps.contain(original.convert("RGB"), (cell_w - 12, cell_h - label_h - 12))
        page_number = group_index * 4 + slot + 1
        draw.rectangle((x, y, x + cell_w - 1, y + label_h - 1), fill="#222222")
        draw.text((x + 10, y + 8), f"PAGE {page_number}", fill="white")
        px = x + (cell_w - page.width) // 2
        py = y + label_h + (cell_h - label_h - page.height) // 2
        sheet.paste(page, (px, py))
        draw.rectangle((x, y, x + cell_w - 1, y + cell_h - 1), outline="#777777", width=1)

    sheet.save(output_path, "JPEG", quality=90, optimize=True)
    return output_path


def prepare() -> list[dict]:
    PAGES_DIR.mkdir(parents=True, exist_ok=True)
    SHEETS_DIR.mkdir(parents=True, exist_ok=True)
    manifest: list[dict] = []
    pdf_paths = sorted(PDF_DIR.glob("*.pdf"), key=lambda p: p.name)
    for pdf_index, pdf_path in enumerate(pdf_paths, start=1):
        print(f"Preparing {pdf_index}/{len(pdf_paths)}: {pdf_path.name}", flush=True)
        page_paths = render_pdf(pdf_path)
        for group_start in range(0, len(page_paths), 4):
            group = page_paths[group_start : group_start + 4]
            sheet = make_sheet(pdf_path, group, group_start // 4)
            manifest.append(
                {
                    "pdf": pdf_path.name,
                    "sheet": str(sheet),
                    "pages": list(range(group_start + 1, group_start + len(group) + 1)),
                }
            )
    (WORK_DIR / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    return manifest


def image_data_url(path: Path) -> str:
    encoded = base64.b64encode(path.read_bytes()).decode("ascii")
    return f"data:image/jpeg;base64,{encoded}"


def extract_json(text: str) -> dict:
    cleaned = text.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.split("\n", 1)[1]
        cleaned = cleaned.rsplit("```", 1)[0]
    return json.loads(cleaned)


def audit_sheet(item: dict) -> dict:
    pages = item["pages"]
    prompt = f"""
あなたは教材PDFの厳格な目視検査担当です。画像はPDF「{item['pdf']}」のページ
{pages}を2×2に並べた検査シートで、各区画上部にPAGE番号があります。

各ページについて次を確認してください。
1. 意図しない人物、部屋、撮影機材、別画面、通知、カーソル、透かし、写真などの写り込み
2. 氏名、メール、アカウント名、住所、電話番号など、教材に不要な個人情報
3. 文字・表・枠線の切れ、重なり、余白外へのはみ出し、崩れ
4. □や文字化けなどのフォント異常、極端に薄い・読めない文字
5. 不自然な空白ページ、重複、教材として明らかに意図しない要素

通常の教材本文、問題番号、ページ番号、表の罫線、記入欄は問題にしないでください。
画像から明確に判断できない細かな誤字脱字は対象外です。推測で問題を作らず、疑わしい場合は
confidenceを低くしてください。

必ず次のJSONオブジェクトだけを返してください。
{{
  "pages": [
    {{
      "page": 1,
      "status": "ok|warning|problem",
      "summary": "短い所見",
      "issues": [
        {{
          "category": "unintended_content|personal_information|clipping|overlap|broken_layout|font_glyph|other",
          "location": "ページ内の位置",
          "description": "具体的な問題",
          "confidence": 0.0
        }}
      ]
    }}
  ]
}}
""".strip()
    payload = {
        "model": MODEL,
        "temperature": 0,
        "max_tokens": 1400,
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {
                        "type": "image_url",
                        "image_url": {"url": image_data_url(Path(item["sheet"]))},
                    },
                ],
            }
        ],
    }
    request = urllib.request.Request(
        API_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=180) as response:
            data = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"LM Studio HTTP {exc.code}: {body}") from exc
    raw = data["choices"][0]["message"]["content"]
    parsed = extract_json(raw)
    return {**item, "model": MODEL, "result": parsed, "raw": raw}


def audit_pdf_group(items: list[dict]) -> dict:
    pdf_name = items[0]["pdf"]
    pages = [page for item in items for page in item["pages"]]
    prompt = f"""
あなたは教材PDFの厳格な目視検査担当です。添付画像はPDF「{pdf_name}」の全ページ
{pages}を、4ページずつ2×2に並べた検査シートです。各区画上部にPAGE番号があります。

全ページを確認し、次の問題が実際に見えるページだけを報告してください。
- 意図しない人物、部屋、撮影機材、別画面、通知、カーソル、透かし、写真などの写り込み
- 教材に不要な氏名、メール、アカウント名、住所、電話番号などの個人情報
- 文字・表・枠線の切れ、重なり、余白外へのはみ出し、崩れ
- □や文字化けなどのフォント異常、極端に薄い・読めない文字
- 不自然な空白ページ、重複、教材として明らかに意図しない要素

通常の教材本文、問題番号、ページ番号、表の罫線、記入欄は問題にしないでください。
推測で問題を作らず、疑わしいだけならconfidenceを低くしてください。

出力を短くするため、問題のないページは個別に列挙しないでください。必ず次のJSONだけを返してください。
{{
  "audited_pages": {pages},
  "issues": [
    {{
      "page": 1,
      "severity": "warning|problem",
      "category": "unintended_content|personal_information|clipping|overlap|broken_layout|font_glyph|other",
      "location": "ページ内の位置",
      "description": "具体的な問題",
      "confidence": 0.0
    }}
  ]
}}
問題がなければissuesを空配列にしてください。
""".strip()
    content = [{"type": "text", "text": prompt}]
    content.extend(
        {
            "type": "image_url",
            "image_url": {"url": image_data_url(Path(item["sheet"]))},
        }
        for item in items
    )
    payload = {
        "model": MODEL,
        "temperature": 0,
        "max_tokens": 700,
        "messages": [{"role": "user", "content": content}],
    }
    request = urllib.request.Request(
        API_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=600) as response:
            data = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"LM Studio HTTP {exc.code}: {body}") from exc
    raw = data["choices"][0]["message"]["content"]
    parsed = extract_json(raw)
    return {
        "pdf": pdf_name,
        "pages": pages,
        "sheets": [item["sheet"] for item in items],
        "model": MODEL,
        "result": parsed,
        "raw": raw,
    }


def audit_by_pdf(manifest: list[dict]) -> list[dict]:
    groups: dict[str, list[dict]] = {}
    for item in manifest:
        groups.setdefault(item["pdf"], []).append(item)

    prior: list[dict] = []
    if PDF_RESULTS_PATH.exists():
        prior = json.loads(PDF_RESULTS_PATH.read_text(encoding="utf-8"))
    by_name = {item["pdf"]: item for item in prior if "error" not in item}

    for index, (pdf_name, items) in enumerate(groups.items(), start=1):
        if pdf_name in by_name:
            print(f"Skipping completed PDF {index}/{len(groups)}: {pdf_name}", flush=True)
            continue
        print(f"Auditing PDF {index}/{len(groups)}: {pdf_name}", flush=True)
        try:
            result = audit_pdf_group(items)
        except Exception as exc:
            result = {
                "pdf": pdf_name,
                "pages": [page for item in items for page in item["pages"]],
                "error": f"{type(exc).__name__}: {exc}",
            }
        by_name[pdf_name] = result
        PDF_RESULTS_PATH.write_text(
            json.dumps(list(by_name.values()), ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
        time.sleep(0.15)
    return list(by_name.values())


def audit(manifest: list[dict]) -> list[dict]:
    prior: list[dict] = []
    if RESULTS_PATH.exists():
        prior = json.loads(RESULTS_PATH.read_text(encoding="utf-8"))
    by_key = {(x["pdf"], tuple(x["pages"])): x for x in prior}
    completed = {key for key, value in by_key.items() if "error" not in value}

    for index, item in enumerate(manifest, start=1):
        key = (item["pdf"], tuple(item["pages"]))
        if key in completed:
            print(f"Skipping completed {index}/{len(manifest)}", flush=True)
            continue
        print(
            f"Auditing {index}/{len(manifest)}: {item['pdf']} pages {item['pages']}",
            flush=True,
        )
        try:
            result = audit_sheet(item)
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError, KeyError) as exc:
            result = {**item, "error": f"{type(exc).__name__}: {exc}"}
        by_key[key] = result
        results = list(by_key.values())
        RESULTS_PATH.write_text(
            json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8"
        )
        time.sleep(0.15)
    return list(by_key.values())


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--prepare-only", action="store_true")
    parser.add_argument("--sheet-mode", action="store_true")
    parser.add_argument("--pdf", help="Only audit the named PDF")
    args = parser.parse_args()
    manifest = prepare()
    if args.pdf:
        manifest = [item for item in manifest if item["pdf"] == args.pdf]
    print(f"Prepared {len(manifest)} inspection sheets.", flush=True)
    if not args.prepare_only:
        results = audit(manifest) if args.sheet_mode else audit_by_pdf(manifest)
        errors = sum(1 for item in results if "error" in item)
        print(f"Audit complete: {len(results)} sheets, {errors} errors.", flush=True)
        return 1 if errors else 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
