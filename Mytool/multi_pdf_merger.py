import sys
import os
import win32com.client
from pypdf import PdfWriter
import tkinter as tk
from tkinter import filedialog, messagebox
from PIL import Image

def get_temp_pdf_path(original_path, index):
    base_name = os.path.splitext(os.path.basename(original_path))[0]
    dir_name = os.path.dirname(original_path)
    return os.path.join(dir_name, f"~temp_{index}_{base_name}.pdf")

def convert_to_pdf(input_path, index=0):
    ext = os.path.splitext(input_path)[1].lower()
    temp_pdf = ""
    
    if ext == '.pdf':
        return input_path, False
        
    elif ext in ['.jpg', '.jpeg', '.png', '.bmp', '.gif', '.tif', '.tiff']:
        temp_pdf = get_temp_pdf_path(input_path, index)
        img = Image.open(input_path).convert('RGB')
        img.save(temp_pdf, "PDF", resolution=100.0)
        return temp_pdf, True
        
    elif ext in ['.xlsx', '.xls', '.csv']:
        temp_pdf = get_temp_pdf_path(input_path, index)
        excel = win32com.client.Dispatch("Excel.Application")
        excel.Visible = False
        excel.DisplayAlerts = False
        try:
            wb = excel.Workbooks.Open(input_path)
            wb.ExportAsFixedFormat(0, temp_pdf)
            wb.Close(False)
        finally:
            excel.Quit()
        return temp_pdf, True
        
    elif ext in ['.docx', '.doc']:
        temp_pdf = get_temp_pdf_path(input_path, index)
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False
        word.DisplayAlerts = False
        try:
            doc = word.Documents.Open(input_path)
            doc.SaveAs(temp_pdf, FileFormat=17)
            doc.Close(False)
        finally:
            word.Quit()
        return temp_pdf, True
        
    elif ext in ['.pptx', '.ppt']:
        temp_pdf = get_temp_pdf_path(input_path, index)
        ppt = win32com.client.Dispatch("PowerPoint.Application")
        try:
            presentation = ppt.Presentations.Open(input_path, WithWindow=False)
            presentation.SaveAs(temp_pdf, 32)
            presentation.Close()
        finally:
            ppt.Quit()
        return temp_pdf, True
        
    else:
        raise ValueError(f"対応していないファイル形式です: {os.path.basename(input_path)}")

def read_state_file(path):
    if not os.path.exists(path):
        return []
    with open(path, 'r', encoding='utf-8') as f:
        lines = [line.strip() for line in f if line.strip() and os.path.exists(line.strip())]
    return lines

def write_state_file(path, lines):
    with open(path, 'w', encoding='utf-8') as f:
        for line in lines:
            f.write(line + "\n")

def main():
    root = tk.Tk()
    root.withdraw()
    
    # 常に手前に表示させる
    root.attributes("-topmost", True)
    
    # PyInstaller化された場合と通常のPythonスクリプト実行の場合で、保存先ディレクトリを分ける
    if getattr(sys, 'frozen', False):
        application_path = os.path.dirname(sys.executable)
    else:
        application_path = os.path.dirname(os.path.abspath(__file__))
        
    state_file = os.path.join(application_path, "multi_merge_state.txt")
    current_list = read_state_file(state_file)
    
    new_files = sys.argv[1:]
    
    # 引数がない場合はダイアログで追加を開く
    if not new_files:
        if not current_list:
            messagebox.showinfo("ファイル選択", "結合したい最初のファイルを選択してください。\n（ドラッグ＆ドロップでも追加できます）")
        
        selected = filedialog.askopenfilenames(
            title="ファイルを追加",
            filetypes=[
                ("対応している全てのファイル", "*.pdf;*.jpg;*.jpeg;*.png;*.bmp;*.xlsx;*.xls;*.docx;*.doc;*.pptx;*.ppt"),
                ("すべてのファイル", "*.*")
            ]
        )
        if selected:
            new_files = list(selected)
    
    if new_files:
        # 新しく追加されたファイルを順にリストの末尾に追加（ドラッグ＆ドロップされた順番を維持）
        for f in new_files:
            f_abs = os.path.abspath(f)
            current_list.append(f_abs)
        write_state_file(state_file, current_list)
    
    if not current_list:
        return

    last_appended = os.path.basename(current_list[-1]) if new_files else ""
    list_files_str = "\n".join([f"{i+1}. {os.path.basename(cf)}" for i, cf in enumerate(current_list)])
    
    msg = f"現在 {len(current_list)} 個のファイルが結合待ちリストにあります。\n\n"
    if last_appended:
        msg += f"最後に追加したファイル: {last_appended}\n\n"
        
    msg += "【現在のリスト】\n" + list_files_str + "\n\n"
    msg += "これらのファイルをこの順番で結合しますか？\n"
    msg += "--------------------------------------\n"
    msg += "[はい] 結合を実行する\n"
    msg += "[いいえ] ウィンドウを閉じて、次のファイルを追加する\n"
    msg += "[キャンセル] リストを全て消去（リセット）する"

    # カスタムダイアログのように見せるためのaskyesnocancel
    choice = messagebox.askyesnocancel("PDF結合の確認", msg)
    
    if choice is None: # キャンセル
        if os.path.exists(state_file):
            os.remove(state_file)
        messagebox.showinfo("リセット", "結合待ちのリストをリセットしました。")
        return
    elif choice is False: # いいえ
        # 何もせず終了し、次のドロップを待機
        return
    else: # はい (結合実行)
        pass # 下の結合処理へ進む

    # ファイルの保存先を選択
    output_dir = os.path.dirname(current_list[0])
    output_pdf = filedialog.asksaveasfilename(
        title="保存先となるPDFファイル名を指定してください",
        initialdir=output_dir,
        initialfile="結合結果.pdf",
        defaultextension=".pdf",
        filetypes=[("PDF files", "*.pdf")]
    )
    
    if not output_pdf:
        # 保存をキャンセルした場合は、とりあえずリストは保持したまま終了する
        return

    merger = PdfWriter()
    temp_files_to_delete = []

    try:
        for i, f in enumerate(current_list):
            pdf_path, is_temp = convert_to_pdf(f, index=i)
            if is_temp:
                temp_files_to_delete.append(pdf_path)
            
            # appendに特定のページを追加することもできるが、デフォルトで全て
            merger.append(pdf_path)
            
        for page in merger.pages:
            try:
                page.compress_content_streams()
            except:
                pass

        merger.write(output_pdf)
        merger.close()
        
        # 成功したらリストを空にする
        if os.path.exists(state_file):
            os.remove(state_file)
            
        messagebox.showinfo("完了", f"{len(current_list)}個のファイルの結合が完了しました！\n\n【保存先】\n{output_pdf}")

    except Exception as e:
        messagebox.showerror("エラーが発生しました", f"結合中にエラーが起きました。\n詳細: {e}")
        
    finally:
        # 一時ファイルの削除
        for temp_file in temp_files_to_delete:
            if os.path.exists(temp_file):
                try:
                    os.remove(temp_file)
                except:
                    pass

if __name__ == '__main__':
    main()
