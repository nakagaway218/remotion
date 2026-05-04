from html import escape
from pathlib import Path
from zipfile import ZipFile

from lxml import etree


ROOT = Path(__file__).resolve().parent
DOCX_PATH = ROOT / "頭皮アートメイク_痛み記事_Googleドキュメント提出用.docx"
OUT_PATH = ROOT / "頭皮アートメイク_痛み記事_WordPress本文_再現.html"

W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
A = "http://schemas.openxmlformats.org/drawingml/2006/main"
PIC = "http://schemas.openxmlformats.org/drawingml/2006/picture"
R = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
NS = {"w": W, "a": A, "pic": PIC, "r": R}

ALT_TEXT = {
    "1348113_s.jpg": "鏡を持って肌や髪を確認する女性",
    "32101762_s.jpg": "頭皮ケアを受けている施術イメージ",
    "26555623.jpg": "頭皮の状態を確認するカウンセリングイメージ",
    "22465802.jpg": "不安そうに悩む女性のイラスト",
    "4637646_s.jpg": "医療スタッフに相談する女性",
}


def text_of(element):
    parts = element.xpath(".//w:t/text()", namespaces=NS)
    return "".join(parts).strip()


def paragraph_style(p):
    style = p.xpath("./w:pPr/w:pStyle/@w:val", namespaces=NS)
    return style[0] if style else ""


def picture_name(p):
    names = p.xpath(".//pic:cNvPr/@name", namespaces=NS)
    return names[0] if names else ""


def html_p(text):
    return f"<p>{escape(text)}</p>"


def close_ul(lines, in_ul):
    if in_ul:
        lines.append("</ul>")
    return False


def add_figure(lines, image_name, caption):
    src = f"頭皮アートメイク_痛み記事_images/{image_name}"
    alt = ALT_TEXT.get(image_name, "")
    lines.append("<figure>")
    lines.append(f'<img src="{escape(src)}" alt="{escape(alt)}">')
    lines.append(f"<figcaption>{escape(caption)}</figcaption>")
    lines.append("</figure>")
    lines.append("")


def main():
    with ZipFile(DOCX_PATH) as zf:
        document_xml = zf.read("word/document.xml")

    root = etree.fromstring(document_xml)
    body = root.find("w:body", namespaces=NS)

    lines = []
    in_ul = False
    in_toc = False
    in_faq = False
    pending_image = None
    skipped_hero_image = False
    started_body = False

    for block in body:
        tag = etree.QName(block).localname

        if tag == "tbl":
            text = text_of(block)
            if text.startswith("ポイント"):
                in_ul = close_ul(lines, in_ul)
                body_text = text.replace("ポイント", "", 1).strip()
                lines.append(f"<p><strong>ポイント：</strong>{escape(body_text)}</p>")
                lines.append("")
            continue

        if tag != "p":
            continue

        style = paragraph_style(block)
        text = text_of(block)
        image_name = picture_name(block)

        if image_name:
            if not started_body:
                skipped_hero_image = True
                pending_image = None
            else:
                pending_image = image_name
            continue

        if not started_body:
            if skipped_hero_image:
                started_body = True
            continue

        if pending_image and text:
            add_figure(lines, pending_image, text)
            pending_image = None
            continue

        if not text:
            continue

        if text == "目次":
            in_toc = True
            continue

        if in_toc and style == "Heading1":
            in_toc = False

        if in_toc:
            continue

        if style == "Heading1":
            in_ul = close_ul(lines, in_ul)
            in_faq = "よくある質問" in text
            lines.append(f"<h2>{escape(text)}</h2>")
            if in_faq:
                lines.append("")
            continue

        if style == "Heading2":
            in_ul = close_ul(lines, in_ul)
            lines.append(f"<h3>{escape(text)}</h3>")
            continue

        if style == "ListBullet":
            if not in_ul:
                lines.append("<ul>")
                in_ul = True
            lines.append(f"<li>{escape(text)}</li>")
            continue

        in_ul = close_ul(lines, in_ul)

        if in_faq and text.startswith("Q. "):
            question = text.replace("Q. ", "", 1)
            lines.append(f"<h3>{escape(question)}</h3>")
        elif in_faq and text.startswith("A. "):
            answer = text.replace("A. ", "", 1)
            lines.append(html_p(answer))
            lines.append("")
        else:
            lines.append(html_p(text))

    close_ul(lines, in_ul)
    OUT_PATH.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    print(OUT_PATH)


if __name__ == "__main__":
    main()
