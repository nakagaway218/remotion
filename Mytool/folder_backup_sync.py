import json
import re
import subprocess
import threading
import tkinter as tk
from pathlib import Path
from tkinter import filedialog, messagebox, ttk


APP_TITLE = "フォルダ同期バックアップツール"
SETTINGS_FILE = Path(__file__).with_name("folder_backup_sync_settings.json")


def load_settings():
    if not SETTINGS_FILE.exists():
        return {}
    try:
        return json.loads(SETTINGS_FILE.read_text(encoding="utf-8"))
    except Exception:
        return {}


def save_settings(source, destination):
    SETTINGS_FILE.write_text(
        json.dumps(
            {"source": source, "destination": destination},
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )


def decode_output(data):
    for encoding in ("utf-8", "cp932", "mbcs"):
        try:
            return data.decode(encoding)
        except UnicodeDecodeError:
            continue
    return data.decode(errors="replace")


def build_robocopy_command(source, destination, dry_run):
    command = [
        "robocopy",
        source,
        destination,
        "/MIR",
        "/COPY:DAT",
        "/DCOPY:DAT",
        "/XJ",
        "/R:2",
        "/W:2",
        "/NP",
    ]
    if dry_run:
        command.append("/L")
    return command


def summarize_robocopy_exit(code):
    if code == 0:
        return "差分はありません。すでに同じ状態です。"
    if code == 1:
        return "コピー対象があります。処理は正常に完了しています。"
    if code < 8:
        return "一部差分または追加処理がありましたが、Robocopy上は成功扱いです。"
    return "エラーが発生しました。出力内容を確認してください。"


def detect_file_access_warnings(output):
    warning_words = [
        "ERROR 5",
        "ERROR 32",
        "ERROR 33",
        "access is denied",
        "being used by another process",
        "process cannot access",
        "アクセスが拒否",
        "別のプロセス",
        "使用中",
    ]
    path_pattern = re.compile(r"[A-Za-z]:\\[^\r\n]+")
    warnings = []
    recent_paths = []

    for line in output.splitlines():
        line_lower = line.lower()
        found_paths = path_pattern.findall(line)
        if found_paths:
            recent_paths = found_paths

        if any(word.lower() in line_lower for word in warning_words):
            if recent_paths:
                for path in recent_paths:
                    if path not in warnings:
                        warnings.append(path)
            else:
                stripped = line.strip()
                if stripped and stripped not in warnings:
                    warnings.append(stripped)

    return warnings[:10]


def build_access_warning_message(paths):
    message = (
        "一部のファイルをコピーできなかった可能性があります。\n\n"
        "よくある原因は、対象ファイルをアプリが開いたままにしていることです。\n"
        "Outlookの .pst、Excel、Word、PowerPoint、動画編集ソフトのプロジェクトなどで起こります。\n\n"
        "関連するアプリを閉じてから、もう一度「同期を実行」してください。"
    )
    if paths:
        message += "\n\n確認された候補:\n" + "\n".join(paths)
    return message


class BackupSyncApp:
    def __init__(self, root):
        self.root = root
        self.root.title(APP_TITLE)
        self.root.geometry("820x620")
        self.root.minsize(720, 520)

        settings = load_settings()
        self.source_var = tk.StringVar(value=settings.get("source", ""))
        self.destination_var = tk.StringVar(value=settings.get("destination", ""))
        self.status_var = tk.StringVar(value="元フォルダとバックアップ先を選んでください。")
        self.running = False

        self.build_ui()

    def build_ui(self):
        main = ttk.Frame(self.root, padding=16)
        main.pack(fill="both", expand=True)

        title = ttk.Label(main, text=APP_TITLE, font=("", 16, "bold"))
        title.pack(anchor="w")

        note = ttk.Label(
            main,
            text="バックアップ先を元フォルダと同じ状態にします。先にだけあるファイルは削除されます。",
            foreground="#a33",
        )
        note.pack(anchor="w", pady=(6, 14))

        self.add_folder_row(main, "元フォルダ", self.source_var, self.choose_source)
        self.add_folder_row(main, "バックアップ先", self.destination_var, self.choose_destination)

        button_row = ttk.Frame(main)
        button_row.pack(fill="x", pady=(10, 12))

        self.preview_button = ttk.Button(
            button_row,
            text="事前確認",
            command=lambda: self.start_sync(dry_run=True),
        )
        self.preview_button.pack(side="left")

        self.sync_button = ttk.Button(
            button_row,
            text="同期を実行",
            command=lambda: self.start_sync(dry_run=False),
        )
        self.sync_button.pack(side="left", padx=(8, 0))

        self.clear_button = ttk.Button(button_row, text="結果を消す", command=self.clear_output)
        self.clear_button.pack(side="left", padx=(8, 0))

        status = ttk.Label(main, textvariable=self.status_var)
        status.pack(anchor="w", pady=(0, 8))

        output_frame = ttk.Frame(main)
        output_frame.pack(fill="both", expand=True)

        self.output = tk.Text(output_frame, wrap="word", height=18)
        self.output.pack(side="left", fill="both", expand=True)

        scrollbar = ttk.Scrollbar(output_frame, command=self.output.yview)
        scrollbar.pack(side="right", fill="y")
        self.output.configure(yscrollcommand=scrollbar.set)

        self.write_output(
            "使い方:\n"
            "1. 元フォルダを選びます。\n"
            "2. バックアップ先を選びます。\n"
            "3. まず「事前確認」を押します。\n"
            "4. 内容に問題がなければ「同期を実行」を押します。\n\n"
            "注意:\n"
            "同期前に、Outlook、Excel、Word、PowerPoint、動画編集ソフトなど、\n"
            "バックアップ対象のファイルを開いているアプリは閉じてください。\n\n"
        )

    def add_folder_row(self, parent, label, variable, command):
        frame = ttk.Frame(parent)
        frame.pack(fill="x", pady=5)

        ttk.Label(frame, text=label, width=14).pack(side="left")
        entry = ttk.Entry(frame, textvariable=variable)
        entry.pack(side="left", fill="x", expand=True, padx=(0, 8))
        ttk.Button(frame, text="選択", command=command).pack(side="left")

    def choose_source(self):
        path = filedialog.askdirectory(title="元フォルダを選択")
        if path:
            self.source_var.set(path)

    def choose_destination(self):
        path = filedialog.askdirectory(title="バックアップ先フォルダを選択")
        if path:
            self.destination_var.set(path)

    def validate_paths(self):
        source = self.source_var.get().strip()
        destination = self.destination_var.get().strip()

        if not source or not destination:
            messagebox.showwarning(APP_TITLE, "元フォルダとバックアップ先を両方選んでください。")
            return None

        source_path = Path(source)
        destination_path = Path(destination)

        if not source_path.exists() or not source_path.is_dir():
            messagebox.showwarning(APP_TITLE, "元フォルダが見つかりません。")
            return None

        if source_path.resolve() == destination_path.resolve():
            messagebox.showwarning(APP_TITLE, "元フォルダとバックアップ先が同じです。")
            return None

        try:
            destination_path.mkdir(parents=True, exist_ok=True)
        except Exception as error:
            messagebox.showerror(APP_TITLE, f"バックアップ先を作成できませんでした。\n\n{error}")
            return None

        return str(source_path), str(destination_path)

    def start_sync(self, dry_run):
        if self.running:
            return

        paths = self.validate_paths()
        if paths is None:
            return

        source, destination = paths
        if not dry_run:
            answer = messagebox.askyesno(
                APP_TITLE,
                "バックアップ先を元フォルダと同じ状態にします。\n\n"
                "バックアップ先にだけあるファイルやフォルダは削除されます。\n"
                "開いているファイルはコピーできないことがあります。\n"
                "Outlook、Excel、Word、PowerPointなどは閉じておくのがおすすめです。\n\n"
                "実行してよろしいですか？",
            )
            if not answer:
                return

        save_settings(source, destination)
        self.running = True
        self.set_buttons_enabled(False)
        self.clear_output()

        mode_text = "事前確認" if dry_run else "同期"
        self.status_var.set(f"{mode_text}を実行中です...")
        self.write_output(f"{mode_text}を開始します。\n\n")
        self.write_output(f"元フォルダ: {source}\n")
        self.write_output(f"バックアップ先: {destination}\n\n")

        thread = threading.Thread(
            target=self.run_robocopy,
            args=(source, destination, dry_run),
            daemon=True,
        )
        thread.start()

    def run_robocopy(self, source, destination, dry_run):
        command = build_robocopy_command(source, destination, dry_run)
        try:
            process = subprocess.run(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                shell=False,
                check=False,
            )
            output = decode_output(process.stdout)
            code = process.returncode
            self.root.after(0, self.finish_run, code, output, dry_run)
        except Exception as error:
            self.root.after(0, self.finish_error, error)

    def finish_run(self, code, output, dry_run):
        access_warnings = detect_file_access_warnings(output)

        self.write_output(output)
        self.write_output("\n")
        self.write_output(f"結果: {summarize_robocopy_exit(code)}\n")
        self.write_output(f"Robocopy終了コード: {code}\n")

        if access_warnings:
            self.write_output("\n注意: 使用中またはアクセス不可の可能性がある項目があります。\n")
            for path in access_warnings:
                self.write_output(f"- {path}\n")

        if dry_run:
            self.status_var.set("事前確認が完了しました。内容を確認してください。")
        elif code < 8:
            self.status_var.set("同期が完了しました。")
        else:
            self.status_var.set("同期中にエラーが発生しました。")

        self.running = False
        self.set_buttons_enabled(True)

        if access_warnings:
            messagebox.showwarning(APP_TITLE, build_access_warning_message(access_warnings))

    def finish_error(self, error):
        self.write_output(f"エラーが発生しました:\n{error}\n")
        self.status_var.set("エラーが発生しました。")
        self.running = False
        self.set_buttons_enabled(True)

    def set_buttons_enabled(self, enabled):
        state = "normal" if enabled else "disabled"
        self.preview_button.configure(state=state)
        self.sync_button.configure(state=state)
        self.clear_button.configure(state=state)

    def clear_output(self):
        self.output.delete("1.0", "end")

    def write_output(self, text):
        self.output.insert("end", text)
        self.output.see("end")


def main():
    root = tk.Tk()
    BackupSyncApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
