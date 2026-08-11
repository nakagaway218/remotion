from __future__ import annotations

import json
import re
from pathlib import Path

import pdfplumber
from pypdf import PdfReader


ROOT = Path(__file__).resolve().parents[1]
PDF_DIR = ROOT / "output" / "pdf"
OUT = ROOT / "output" / "pdf_visual_audit_work" / "static_results.json"

SUSPICIOUS = {
    "local_path": re.compile(r"(?:[A-Za-z]:\\\\|/Users/|/home/)", re.I),
    "email": re.compile(r"[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}"),
    "url": re.compile(r"https?://|www\.", re.I),
}


def page_images(page) -> list[dict]:
    found: list[dict] = []
    resources = page.get("/Resources") or {}
    xobjects = resources.get("/XObject") or {}
    try:
        xobjects = xobjects.get_object()
    except AttributeError:
        pass
    for name, ref in xobjects.items():
        try:
            obj = ref.get_object()
        except Exception:
            continue
        if obj.get("/Subtype") == "/Image":
            found.append({
                "name": str(name),
                "width": int(obj.get("/Width", 0)),
                "height": int(obj.get("/Height", 0)),
                "filter": str(obj.get("/Filter", "")),
            })
    return found


def audit_pdf(path: Path) -> dict:
    reader = PdfReader(path)
    result = {"pdf": path.name, "pages": len(reader.pages), "page_checks": [], "hits": []}
    with pdfplumber.open(path) as plumber:
        for index, (page, ppage) in enumerate(zip(reader.pages, plumber.pages), 1):
            text = page.extract_text() or ""
            images = page_images(page)
            width, height = float(ppage.width), float(ppage.height)
            outside = []
            for kind in ("chars", "images", "rects", "lines", "curves"):
                for obj in getattr(ppage, kind, []) or []:
                    x0, x1 = obj.get("x0"), obj.get("x1")
                    top, bottom = obj.get("top"), obj.get("bottom")
                    if None not in (x0, x1, top, bottom) and (
                        x0 < -0.5 or x1 > width + 0.5 or top < -0.5 or bottom > height + 0.5
                    ):
                        outside.append({"kind": kind, "box": [x0, top, x1, bottom]})
                        if len(outside) >= 10:
                            break
                if len(outside) >= 10:
                    break
            hits = []
            for label, pattern in SUSPICIOUS.items():
                values = sorted(set(m.group(0) for m in pattern.finditer(text)))
                if values:
                    hits.append({"type": label, "values": values[:10]})
                    result["hits"].append({"page": index, "type": label, "values": values[:10]})
            result["page_checks"].append({
                "page": index,
                "text_chars": len(text.strip()),
                "embedded_images": images,
                "outside_objects": outside,
                "possibly_blank": len(text.strip()) == 0 and not images and not ppage.rects and not ppage.lines and not ppage.curves,
                "suspicious_text": hits,
            })
    return result


def main() -> None:
    results = [audit_pdf(path) for path in sorted(PDF_DIR.glob("*.pdf"))]
    summary = {
        "pdf_count": len(results),
        "page_count": sum(r["pages"] for r in results),
        "possibly_blank_pages": [
            {"pdf": r["pdf"], "page": p["page"]}
            for r in results for p in r["page_checks"] if p["possibly_blank"]
        ],
        "outside_object_pages": [
            {"pdf": r["pdf"], "page": p["page"], "count": len(p["outside_objects"])}
            for r in results for p in r["page_checks"] if p["outside_objects"]
        ],
        "suspicious_text_hits": [
            {"pdf": r["pdf"], **hit} for r in results for hit in r["hits"]
        ],
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({"summary": summary, "results": results}, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
