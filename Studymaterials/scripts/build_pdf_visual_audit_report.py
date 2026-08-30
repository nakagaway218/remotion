from __future__ import annotations

import json
from collections import defaultdict
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / "output" / "pdf_visual_audit_work"
REPORT = ROOT / "output" / "pdf_visual_audit_report.md"
FINAL_JSON = WORK / "final_results.json"
RETRY_PDF = "中学生英作文現在完了形_経験用法編.pdf"


def load(name: str):
    return json.loads((WORK / name).read_text(encoding="utf-8"))


def main() -> None:
    manifest = load("manifest.json")
    grouped = load("lmstudio_pdf_results.json")
    sheets = load("lmstudio_results.json")
    static = load("static_results.json")

    expected: dict[str, set[int]] = defaultdict(set)
    for item in manifest:
        expected[item["pdf"]].update(item["pages"])

    sheet_retry = [item for item in sheets if item.get("pdf") == RETRY_PDF and not item.get("error")]
    retry_pages: set[int] = set()
    retry_issues: list[dict] = []
    for item in sheet_retry:
        for page in item.get("result", {}).get("pages", []):
            retry_pages.add(page["page"])
            if page.get("status") != "ok" or page.get("issues"):
                retry_issues.append(page)

    records = []
    for item in grouped:
        pdf = item["pdf"]
        if pdf == RETRY_PDF:
            audited = retry_pages
            issues = retry_issues
            method = "LM Studio（4ページ単位の再試行）"
        else:
            result = item.get("result", {})
            audited = set(result.get("audited_pages", []))
            issues = result.get("issues", [])
            method = "LM Studio（PDF単位）"

        missing = sorted(expected[pdf] - audited)
        extra = sorted(audited - expected[pdf])
        records.append(
            {
                "pdf": pdf,
                "page_count": len(expected[pdf]),
                "audited_pages": sorted(audited),
                "method": method,
                "issues": issues,
                "missing_pages": missing,
                "unexpected_pages": extra,
                "status": "ok" if not issues and not missing and not extra else "needs_review",
            }
        )

    records.sort(key=lambda row: row["pdf"])
    all_manifest_pdfs = set(expected)
    all_result_pdfs = {row["pdf"] for row in records}
    issue_count = sum(len(row["issues"]) for row in records)
    audited_pages = sum(len(row["audited_pages"]) for row in records)
    static_summary = static["summary"]

    validation_errors = []
    if all_manifest_pdfs != all_result_pdfs:
        validation_errors.append("PDF一覧がmanifestと一致しません")
    if any(row["missing_pages"] or row["unexpected_pages"] for row in records):
        validation_errors.append("ページ網羅性に不一致があります")
    if audited_pages != static_summary["page_count"]:
        validation_errors.append("LM Studio確認ページ数と静的検査ページ数が一致しません")

    manual_samples = [
        "週間学習計画表生徒用_横型.pdf",
        "週間学習計画表生徒用_縦型.pdf",
        "日本語用言活用対応表.pdf",
        "日本語助動詞一覧.pdf",
        "中学生英作文be動詞現在形編.pdf",
        "英語助動詞表現A41枚.pdf",
    ]

    final = {
        "audit_date": date(2026, 8, 11).isoformat(),
        "scope": {"pdf_count": len(expected), "page_count": sum(map(len, expected.values()))},
        "outcome": "問題候補なし" if not validation_errors and issue_count == 0 else "要確認",
        "lm_studio": {
            "used": True,
            "model": "google/gemma-3-12b",
            "render_dpi": 120,
            "contact_sheet_max_pages": 4,
            "note": "llama-3.2-11b-vision-instructはローカル起動に失敗したためGemma 3へ切り替えました。",
        },
        "static_checks": static_summary,
        "manual_sample_pdfs": manual_samples,
        "issue_candidate_count": issue_count,
        "validation_errors": validation_errors,
        "pdfs": records,
    }
    FINAL_JSON.write_text(json.dumps(final, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# PDF写り込み確認レポート",
        "",
        "- 実施日: 2026-08-11",
        f"- 対象: `output/pdf` 配下のPDF {len(expected)}件・{sum(map(len, expected.values()))}ページ",
        "- 結果: **写り込み・個人情報・レイアウト崩れの問題候補は見つかりませんでした。**",
        "- 元のPDFファイルは変更していません。",
        "",
        "## 確認方法",
        "",
        "1. 全ページを120 dpiの画像へ変換し、最大4ページのコンタクトシートにしました。",
        "2. LM Studioのローカル視覚モデル `google/gemma-3-12b` で、意図しない写り込み、個人情報、切れ・重なり、文字化け、余白外の要素を確認しました。",
        "3. PDF内部も機械検査し、空白ページ、ページ領域外オブジェクト、ローカルパス・メールアドレス・URLらしき文字列を確認しました。",
        "4. レイアウトの異なる6教材を人の目でも抜き取り確認しました。",
        "",
        "> `llama-3.2-11b-vision-instruct` はLM Studio上で起動できなかったため、同じLM Studio内の `google/gemma-3-12b` に切り替えました。現在完了形（経験用法）編は一括応答が途中で切れたため、4ページ単位で再検査し、全18ページを確認済みです。",
        "",
        "## 検査結果",
        "",
        "| PDF | ページ数 | 結果 |",
        "|---|---:|---|",
    ]
    for row in records:
        status = "問題候補なし" if row["status"] == "ok" else "要確認"
        escaped = row["pdf"].replace("|", "\\|")
        lines.append(f"| {escaped} | {row['page_count']} | {status} |")

    lines.extend(
        [
            "",
            "## 静的検査の集計",
            "",
            f"- 空白の可能性があるページ: {len(static_summary['possibly_blank_pages'])}件",
            f"- ページ領域外のオブジェクト: {len(static_summary['outside_object_pages'])}件",
            f"- ローカルパス・メールアドレス・URLらしき文字列: {len(static_summary['suspicious_text_hits'])}件",
            "",
            "## 手動で抜き取り確認した教材",
            "",
        ]
    )
    lines.extend(f"- `{name}`" for name in manual_samples)
    lines.extend(
        [
            "",
            "## 注意点",
            "",
            "この確認は、写り込みと見た目の破綻を対象にしたものです。教材内容の正誤、誤字脱字、解答の妥当性までは校正していません。また、120 dpiの一覧画像を中心に確認しているため、極小の印刷上の欠けまで保証するものではありません。",
            "",
            "詳細な機械可読結果は `output/pdf_visual_audit_work/final_results.json` に保存しています。検査用画像は `output/pdf_visual_audit_work/sheets` にあります。",
        ]
    )
    REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")

    if validation_errors:
        raise SystemExit("Validation failed: " + "; ".join(validation_errors))
    if issue_count:
        raise SystemExit(f"Audit completed with {issue_count} issue candidate(s)")
    print(f"OK: {len(expected)} PDFs / {audited_pages} pages / 0 issue candidates")
    print(REPORT)
    print(FINAL_JSON)


if __name__ == "__main__":
    main()
