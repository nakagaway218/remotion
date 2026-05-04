import sys
import os
import win32com.client
from pypdf import PdfWriter
import tkinter as tk
from tkinter import filedialog, messagebox

def main():
    root = tk.Tk()
    root.withdraw() # メインウィンドウを隠す

    # 引数がない場合はダイアログで選択
    if len(sys.argv) < 2:
        messagebox.showinfo("手順1/2", "変換する「エクセルファイル」を選択してください。")
        excel_path = filedialog.askopenfilename(
            title="エクセルファイルを選択",
            filetypes=[("Excel files", "*.xlsx;*.xls")]
        )
        if not excel_path:
            return

        messagebox.showinfo("手順2/2", "最後に結合する「PDFファイル」を選択してください。")
        pdf_path = filedialog.askopenfilename(
            title="PDFファイルを選択",
            filetypes=[("PDF files", "*.pdf")]
        )
        if not pdf_path:
            return
    else:
        # ドラッグ＆ドロップされた場合
        files = sys.argv[1:]
        excel_path = None
        pdf_path = None
        
        state_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "merge_state.txt")
        saved_file = None
        if os.path.exists(state_file):
            try:
                with open(state_file, 'r', encoding='utf-8') as sf:
                    saved_file = sf.read().strip()
                if not os.path.exists(saved_file):
                    saved_file = None
            except:
                pass

        if len(files) == 1:
            f = os.path.abspath(files[0])
            is_excel = f.lower().endswith(('.xlsx', '.xls'))
            is_pdf = f.lower().endswith('.pdf')
            
            if not is_excel and not is_pdf:
                messagebox.showerror("エラー", "エクセルファイル(.xlsx/.xls)またはPDFファイルをドロップしてください。")
                return

            if saved_file:
                saved_is_excel = saved_file.lower().endswith(('.xlsx', '.xls'))
                saved_is_pdf = saved_file.lower().endswith('.pdf')
                if is_excel and saved_is_pdf:
                    excel_path = f
                    pdf_path = saved_file
                    os.remove(state_file)
                elif is_pdf and saved_is_excel:
                    pdf_path = f
                    excel_path = saved_file
                    os.remove(state_file)
                else:
                    with open(state_file, 'w', encoding='utf-8') as sf:
                        sf.write(f)
                    type_str = "エクセル" if is_excel else "PDF"
                    other_str = "PDF" if is_excel else "エクセル"
                    messagebox.showinfo("受付1/2", f"新しい{type_str}ファイルを受け付けました。\n\n続けて、結合したい【{other_str}ファイル】をドロップしてください。")
                    return
            else:
                with open(state_file, 'w', encoding='utf-8') as sf:
                    sf.write(f)
                type_str = "エクセル" if is_excel else "PDF"
                other_str = "PDF" if is_excel else "エクセル"
                messagebox.showinfo("受付1/2", f"{type_str}ファイルを受け付けました。\n\n続けて、結合したい【{other_str}ファイル】をドロップしてください。")
                return
        else:
            # 2つ以上の場合（同時に複数ファイルのドロップ）
            for f in files:
                if f.lower().endswith(('.xlsx', '.xls')):
                    excel_path = f
                elif f.lower().endswith('.pdf'):
                    pdf_path = f
            
            if not excel_path or not pdf_path:
                messagebox.showerror("エラー", "エクセルファイルとPDFファイルを正しくドロップしてください。")
                return
            if os.path.exists(state_file):
                os.remove(state_file)

    # 絶対パスに変換
    excel_path = os.path.abspath(excel_path)
    pdf_path = os.path.abspath(pdf_path)

    # 出力ファイル名を作成
    base_name = os.path.splitext(os.path.basename(excel_path))[0]
    dir_name = os.path.dirname(excel_path)
    temp_pdf = os.path.join(dir_name, base_name + "_temp.pdf")
    output_pdf = os.path.join(dir_name, base_name + "_結合.pdf")

    try:
        # エクセルを起動してPDF保存
        excel = win32com.client.Dispatch("Excel.Application")
        excel.Visible = False
        wb = excel.Workbooks.Open(excel_path)
        # 0 = xlTypePDF
        wb.ExportAsFixedFormat(0, temp_pdf)
        wb.Close(False)
        excel.Quit()

        # PDFを結合
        merger = PdfWriter()
        merger.append(temp_pdf)
        merger.append(pdf_path)
        
        # ファイルサイズを圧縮する（ロスレス圧縮）
        for page in merger.pages:
            try:
                page.compress_content_streams()
            except:
                pass

        merger.write(output_pdf)
        merger.close()

        # 一時ファイルの削除
        if os.path.exists(temp_pdf):
            os.remove(temp_pdf)

        messagebox.showinfo("完了", f"ファイルの結合と圧縮が完了しました！\n\n【保存先】\n{output_pdf}")

    except Exception as e:
        messagebox.showerror("エラーが発生しました", f"詳細: {e}")

if __name__ == '__main__':
    main()

