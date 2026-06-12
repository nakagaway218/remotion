🤖 AIマネージャー導入ガイド（営業＋マーケ）
このファイル1枚で、Claude Code が「営業マネージャー」と「マーケティングマネージャー」をあなたの会社に導入します。 動画「Claude CodeでAI社員と経営を自動化」の視聴特典です。


________________


📋 はじめに読む（必読・3分）
このガイドで完成するもの
導入完了後、あなたの会社では2人のAI社員が毎朝働くようになります。


🏢 営業マネージャー（AI社員）の仕事


* 毎朝7時、スプレッドシート上で「承認済み☑」の営業先に自動でメール送信
* お客様から返信が来たら自動で検知し、返信草案を AI が作成
* あなたは「承認☑」を押すだけ。リサーチ・文面作成・送信・返信検知・草案生成は全自動


📣 マーケティングマネージャー（AI社員）の仕事


* 毎朝7時、あなたのオウンドメディアをチェックして新着記事を検出
* 1記事から YouTube 用台本（20分相当） ＋ TikTok 用台本（1分） ＋ Instagram 用台本（1分） を自動生成
* 台本は Google Drive の所定フォルダに自動保存
* あなたはそれをベースに撮影するだけ
所要時間（正直な見積もり）
導入モード
	所要時間
	内訳
	営業マネだけ
	約60分
	環境確認10分・スプシ作成5分・10社リサーチ＆書込15分・件名本文生成10分・GAS設置15分・テスト送信5分
	マーケマネだけ
	約45分
	環境確認10分・Drive準備5分・GCP/OAuth設定15分・スクリプト設置5分・初回実行10分
	両方
	約90〜120分
	上記の合算
	

技術知識が浅い場合は + 30分 を見込んでください（特に Google OAuth 周り）。
必要なものチェックリスト
事前に揃えてあると詰まりません:


* Mac または Windows のパソコン
* Claude Code（このガイドを読ませる先） — claude.com/claude-code でインストール可
* Google アカウント1つ — 営業マネのスプシ／Gmail、マーケマネの Drive で使う（同じものでOK）
* 営業送信元のメールアドレス — 自社の公開アドレス（info@/contact@ 等が望ましい）
* Anthropic API キー（マーケマネのみ・console.anthropic.com で発行・無料枠あり）
* Gemini API キー（任意・営業マネ返信草案生成用・aistudio.google.com/apikey）
* オウンドメディアURL（マーケマネのみ・WordPress 等の RSS が取れるサイト）
3つの最短ルート
完了率を上げるため、最初は 小さく始める のがおすすめです。


ルート
	向く人
	進め方
	A. 営業マネだけ
	営業電話・営業メールに困っている
	STEP 0 で「A. 営業マネだけ」を選択 → 完了後マーケはまた今度
	B. マーケマネだけ
	オウンドメディアを既に運営している
	STEP 0 で「B. マーケマネだけ」を選択 → SEO記事から動画台本が量産される
	C. 両方（推奨）
	動画と同じ流れを体験したい
	STEP 0 で「C. 両方」を選択 → 90〜120 分で営業＋マーケが揃う
	

🧪 練習モード（任意・上記とは別軸）: 「いきなり本番が怖い」場合は、STEP 1 のヒアリングで 架空会社名（例: 株式会社AIアカデミー） ＋ .example.com ドメインのターゲット で1周してから、本番情報で再実行する手もあります。動画と同じ条件で安全に試せます。
システム構成（テキスト図）
┌───────────────────────────────────────────────┐
│  営業マネージャー（毎朝7時自動実行）              │
├───────────────────────────────────────────────┤
│  📊 Google スプレッドシート                       │
│      ↑↓ チェックボックスで「承認」               │
│  ⚙️ GAS（Google Apps Script）= Google上で動く     │
│      → メール送信（Gmail）                         │
│      → 返信検知（Gmail）                           │
│      → Gemini API で返信草案生成                  │
└───────────────────────────────────────────────┘


┌───────────────────────────────────────────────┐
│  マーケティングマネージャー（毎朝7時自動実行）     │
├───────────────────────────────────────────────┤
│  💻 Python スクリプト（あなたのPCで動く）          │
│      → オウンドメディアの RSS チェック             │
│      → Claude API で 3 種台本生成                 │
│      → Google Drive に Google Docs 形式で保存     │
└───────────────────────────────────────────────┘

なぜ役割を分けるのか:


* 営業マネは GAS = メール送信を Google サーバー上で 24/7 確実に実行
* マーケマネは Python = Claude API 呼び出し・記事処理が必要、cron 化しやすい
* 両方 Claude Code から作る = セットアップは対話的に Claude Code が手伝ってくれる


途中で詰まったら、ガイド末尾の 付録G: トラブルシューティング を見てください。


________________


⚠️ Claude Code へ — 必読の強制ルール
あなた（Claude Code）はこのファイルを読み込んだら、以下のルールを絶対に守って進めること。


1. 各STEPは必ず「① 質問 → ② 要約確認 → ③ 実行 → ④ 動作確認」の4段ループで進めること。
2. ユーザーが「進めて」「OK」「次へ」と返答するまで実行に移らないこと。先回りで処理を始めない。
3. 以下の操作は 高リスク として、実行前に必ずユーザー確認のゲートを置くこと:
   * メール送信（テストでも本番でも）
   * Google Apps Script の認可
   * API キー（特に ANTHROPIC_API_KEY / GEMINI_API_KEY）の保存
   * 自動スケジューラー（cron / GAS time trigger）の設定
4. 質問は AskUserQuestion 形式の選択肢提示 を推奨。自由入力が必要な質問のみ平文で。
5. ユーザーが日本語で話している前提で、すべての応答も日本語で。
6. 「営業マネだけ」「マーケマネだけ」モードのときは、対象外のSTEPをスキップすること。
7. 各STEP終了時に、何をやって、次に何をやるかを 1〜2行で要約 すること。
8. 詰まりやすい場所（後述の各STEPに 💡 ここで詰まりやすい マーク）では、エラーメッセージのスクショや内容をユーザーに送ってもらってから対処すること。


________________


STEP 0: 導入モード選択
Claude Code への指示: 以下の質問をユーザーに投げ、回答を得るまで次に進まないこと。


ユーザーに以下を質問してください:


今回どちらを導入しますか？
A. 営業マネージャーだけ
B. マーケティングマネージャー（オウンドメディア完全自動化）だけ
C. 両方（推奨・所要 90〜120 分）

回答に応じて、進むSTEPを選択:


* A → STEP 1 → STEP 2 → STEP 3 → 完了
* B → STEP 1（マーケ用のみ）→ STEP 4 → 完了
* C → STEP 1 → STEP 2 → STEP 3 → STEP 4 → STEP 5


________________


STEP 1: 前提環境確認（10分）
Claude Code への指示: チェックリスト形式で1項目ずつ確認。すべてOKになるまで次へ進まないこと。
1-1. 共通: Google アカウント
ユーザーに質問:


営業マネのスプレッドシート、マーケマネのDriveを使う Google アカウントは決まっていますか？
A. はい（メールアドレスを教えてください）
B. これから作る

→ アカウント未取得なら https://accounts.google.com/signup を案内して中断。
1-2. 共通: 会社情報ヒアリング（営業マネに必須・マーケマネにも使う）
ユーザーに以下を順に質問:


1. 会社名（実在 or 架空どちら？）
2. 自社のサービス・事業内容（1〜2行で）
3. 営業ターゲット顧客像（業種・規模・所在地）
4. 営業メール送信元アドレス（公開してOKなもの）
5. （マーケマネ導入時のみ）運営中のオウンドメディアURL
6. （マーケマネ導入時のみ）動画台本を保存したい Google Drive フォルダURL


回答を受け取ったら、要約してユーザーに確認:


以下の内容で進めますね？
- 会社名: ○○
- 事業内容: ○○
- ターゲット: ○○業界・○○規模
- 送信元: ○○@○○
- オウンドメディアURL: ○○
- DriveフォルダURL: ○○


「進めて」と返事をください。
1-3. 営業マネ用: GAS が使える環境か
「Google アカウントで Apps Script にアクセスして、新規プロジェクト作成画面が開ければOK」と伝え、開けたら「OK」と返してもらう。
1-4. マーケマネ用: Python 環境
ユーザーのターミナルで以下を実行するよう依頼:


python3 --version

* 3.10 以上が表示されない → Homebrew や pyenv で 3.10+ を導入する手順を案内
* OKなら、依存パッケージを入れる:


pip install requests beautifulsoup4 google-auth-oauthlib google-api-python-client
1-5. マーケマネ用: Anthropic API キー
ユーザーに質問:


Anthropic API キー（sk-ant-... で始まる）は持っていますか？
A. 持っている
B. これから取得する（5分・無料枠あり）

未取得なら https://console.anthropic.com で取得手順を案内。取得後、.env に書く方法を後のSTEPで案内する（まだここでは保存させない）。
1-6. テスト送信先メールアドレス（営業マネのみ）
ユーザーに質問:


営業マネの動作確認用に、テストメールを受け取れる自分のメールアドレス（営業送信元と別がベター）を1つ教えてください。

→ STEP 2 のテスト送信で使う。
✅ STEP 1 完了確認
全項目チェックOKになったら:


前提環境すべてOKです。


次は STEP 2（営業マネージャー実装・約60分）に進みます。
よろしいですか？「進めて」とお返事ください。

________________


STEP 2: 営業マネージャー実装（約60分）
Claude Code への指示: 各サブステップで質問→確認→実行→動作確認の4段ループを必ず回すこと。
💡 動画ではこう始めた（参考）
動画では、Claude Code に最初にこのメッセージを送って実装をスタートしました:


今から、私たちの新しい会社の営業マネージャーをあなたに任命したいと思っております。
具体的には以下の業務をやってもらいたいです:


1. 営業リストの作成
   (a) ウェブ上で公開されている、私たちのターゲットとなる会社のメールアドレスを収集する
   (b) 収集した情報をスプレッドシートなどにリストアップし、営業の準備を整える


2. メール営業の実施
   (a) リスト作成が完了次第、実際にメールを送っていく


3. 返信対応と管理
   (a) 毎朝必ずメールをチェックし、アウトバウンド営業の対象先から返信が来ていないか確認する
   (b) 返信があった場合は、その返信文の下書きなどを作成する


これらの業務を営業マネージャーとして担当していただきたいので、今から実行に移してください。

このガイドのSTEP 1〜3 は、上記をより構造化・安全化したフローです。動画と同じことを Claude Code が対話的に進めてくれます。
💡 ここで詰まりやすい
* 2-D: GAS の初回認可ダイアログ — Google の警告画面「このアプリは Google で確認されていません」が出ますが、自分で貼り付けたコードの内容を確認済みであれば、自分のアカウントから自分の Apps Script を実行するだけなので進めて構いません。「詳細」→「(安全でないページ)に移動」で進む。
* 2-D: コードの SHEET_ID 書き換え忘れ — テンプレ ID のままだと他人のスプシを開こうとしてエラーになります。
* 2-E: テスト送信での誤送信 — 必ず12行目に「TEST行」を追加して送信してください。既存10社の行（2-11行目）は触らない。
2-A. スプレッドシート作成（5分）
質問
ユーザーに:


営業マネージャー用のスプレッドシートを作成します。タイトルは以下でよろしいですか？


タイトル: 「[会社名] 営業マネージャー DB」


「進めて」と返してもらえれば作成します。
実行
「進めて」と返事を受け取ったら、Claude Code は以下を行うこと:


1. 新規スプシ作成: 利用可能な Google Sheets ツール（MCPサーバー / google-sheets-api / その他）で新規スプシ作成。タイトルは上記。利用可能なツールが無ければ、ユーザーに「https://sheets.new で新規作成して、URLを教えてください」と依頼する。
2. シート名を「リスト」にリネーム
3. もう1つ「凡例・運用ルール」タブを追加
4. 付録D: スプシ20列構造リファレンス の全文を読み込み、A1〜T1にヘッダー行を書き込み
5. 列幅・色・チェックボックス（M列・T列）・条件付き書式は、利用可能な Sheets API の batchUpdate で適用する。ツールが無ければ、ユーザーに「M列とT列を選択→挿入→チェックボックス」を案内する。
6. 完成したら、ユーザーにスプシURLを共有する
動作確認
ユーザーにスプシURLを共有し、「ヘッダー行20列・色付き・M列とT列にチェックボックスが見えますか？」と確認。


________________


2-B. ターゲット企業10社のリサーチ＋書き込み（10分）
質問
STEP 1 でヒアリングした「[ターゲット業種・規模]」に該当するターゲット候補10社をリサーチして、スプレッドシートに書き込みます。


リサーチには以下のソースを使います:
- 業界誌・プレスリリース
- 上場企業の場合は IR・コーポレートサイト
- 公開法人メールアドレス（info@ / contact@ / sales@）のみ収集


実在企業を扱うので、間違えやすい点を確認させてください:
A. 実在企業のみ（動画と違って本番運用）
B. 架空企業で練習（.example.com ドメイン使用）
C. ハイブリッド（実在5社＋架空5社）


どれにしますか？
実行
選んだモードで、Web検索ツール（WebFetch等）を使ってリサーチ。各社について以下を埋める:


* B列 会社名
* C列 URL
* D列 業種
* E列 推定年商
* F列 所在地
* G列 部署（IR/広報/総務 等）
* H列 担当者名（取得できなければ「ご担当者様」）
* I列 公開メール
* J列 取得ソース（プレス・業界誌名 等）


利用可能な Google Sheets ツールで A2:J11 に一括書き込み。ツールが無ければ、CSV形式で提示してユーザーに貼り付けてもらう。
動作確認
書き込み後、ユーザーに:


10社書き込みました。スプシで内容を確認してください。
- 会社名・URLは正しいですか？
- メールアドレスは公開法人アドレスですか？（個人アドレスならNG）
- 業種ミックスは想定通りですか？


「OK」が来たら次の件名・本文草案生成に進みます。

________________


2-C. 件名・本文草案を10社分生成（10分）
質問
件名（K列）と本文（L列）を生成します。各社の事業内容・プレスリリースを反映してカスタマイズします。


ガードレール（必ず守る）:
- 件名30字以内・顧客固有キーワード入り
- 本文に特商法フッター必須（送信元・住所・連絡先・配信停止導線）
- NGワード「必ず」「絶対」「100%」禁止
- 各社の HP / プレスリリース引用を「連絡したきっかけ」に入れる


「進めて」で生成開始します。
実行
各社についてWebFetchで HP / プレス記事を引用元として取得 → 件名・本文を生成 → スプシ K2:L11 に書き込み。


本文テンプレ（付録E 参照）:


[会社名] ご担当者様


突然のご連絡失礼いたします。
[自社名] の [氏名] と申します。


[HP記事タイトル] を拝見し、[業界課題] に対して [自社サービス] でご一緒できる可能性があると感じご連絡しました。


[提案概要 2-3文]


ご興味あれば 30 分のオンライン面談をお願いできますと幸いです。


----
※本メールは公開メールアドレス宛にお送りしています
※配信停止希望は本メールに「停止希望」とご返信ください


[自社名] / [代表者] / [住所] / [TEL] / [Mail]
動作確認
ユーザーにスプシ K列・L列の確認を依頼:


件名・本文ともに10社分入りました。最低1社、件名と本文を読んで以下チェックしてください:
- 顧客固有のキーワードが入っているか？
- 特商法フッターが付いているか？
- NGワードが入っていないか？


OK なら次の GAS 設置に進みます。

________________


2-D. GAS（Google Apps Script）の設置（10分）
質問
営業マネのコア機能（承認☑送信 → 返信検知 → Gemini草案生成 → 返信送信☑送信）を担うGAS（Google Apps Script）を設置します。


これは手作業が一部必要です（Apps Scriptへの貼り付けと初回認可）。所要約8分。
「進めて」で手順を順に案内します。
実行
ユーザーに以下を順に案内（1ステップずつ「できました」を待つ）:


1. スプシを開いた状態で 拡張機能 → Apps Script をクリック
2. 既存の function myFunction() {} を全削除
3. このファイル末尾の 付録A: GAS Code.gs（全文） を Claude Code が読み込み、全文をユーザーにコピー用コードブロックとして提示する。ユーザーは全選択コピーしてエディタに貼り付け
4. コード冒頭の以下4箇所を、ユーザー会社情報に置換するよう依頼:
   * SHEET_ID ← ユーザーのスプシIDに置換
   * FROM_NAME ← ユーザー会社名＋差出人名に置換
   * REPLY_TO ← ユーザー送信元アドレスに置換
   * SEND_LIMIT_PER_DAY ← 50 のままで OK（必要なら調整）
5. 左サイドの ⚙ プロジェクトの設定 → 「appsscript.json マニフェストファイルをエディタで表示する」にチェック
6. エディタに戻って appsscript.json を開き、Claude Code が 付録B: appsscript.json（全文） を読み込んでコピー用コードブロックを提示。ユーザーはそれで現在の内容を上書き
7. 💾 保存（Ctrl/Cmd+S）
認可ゲート（高リスク操作）
ユーザーに確認:


次に Apps Script の初回認可を行います。これは「あなたのGmailに送信・読み取り権限を与える」操作です。


具体的な手順:
1. エディタ上部の関数選択メニューで `sendApprovedEmails` を選択
2. **実行** をクリック
3. 「権限を確認」 → アカウント選択 → 「詳細」 → 「(安全でないページ)に移動」 → **許可**
4. 完了後、エディタを閉じてスプシをリロード
5. スプシのメニューバーに **「営業マネ」** が出現すれば成功


「終わりました」と返してもらえれば次に進みます。
動作確認
ユーザーにスプシで:


スプシのメニューバーに「営業マネ」が出現していますか？
A. 出ている → 次に進みます
B. 出ていない → 付録G トラブルシューティングを案内

________________


2-E. テスト送信（5分）
⚠️ 高リスク操作。必ず確認ゲートを通すこと。 ⚠️ 既存10社の行は触らない。専用のテスト行を末尾に追加して送信し、テスト後に削除する。
質問
動作確認のため、テスト送信を1通だけ行います。


【ポイント】既存10社の行は一切触りません。スプシ最終行の次（12行目）に専用テスト行を1行追加して、その行だけを送信します。
テスト完了後、12行目はまるごと削除します。


「進めて」で12行目にテスト行を追加します。
実行
「進めて」を受けたら、Claude Code は以下を実行:


1. スプシ12行目（既存10社の次の行）に以下を書き込み:
   * A12: TEST
   * B12: テスト送信用
   * I12: STEP 1-6 で教えてもらった「[テスト送信先]」
   * K12: [件名] テスト送信 - [今日の日付]
   * L12: 簡単なテスト本文（特商法フッター付き・以下サンプル）


これは営業マネ動作確認のテストメールです。


----
※本メールは営業マネ動作確認用テストです
[自社名] / [代表者] / [住所] / [TEL] / [Mail]
動作確認
書き込み完了後、ユーザーに以下を依頼:


次の手順を順に行ってください:
1. スプシ M12（12行目の承認☑）を ON にする
2. メニュー「営業マネ → ① 承認済み営業メールを送信」をクリック
3. トースト「送信: 1 / 保留: 0 / 失敗: 0」が出たら成功
4. N12 に送信日時、O12 に「送信完了」が入っているか確認
5. 自分の Gmail 送信トレイにメールが残っているか確認
6. テスト送信先の受信箱に到着しているか確認


すべてOKなら「OK」と返してください。
失敗していたら、失敗ステータスを教えてください。
後始末（必須）
OK を受け取ったら:


テスト行（12行目）を**まるごと削除**します。これで本番送信時の誤送信を防止できます。
「削除して」と返してもらえれば削除します。

「削除して」を受けたら、Claude Code は12行目を削除（A12:T12 をクリアしてから行自体を削除）。


重要: 既存10社の行（2-11行目）の M列・N列・O列は一切触らないこと。これらに送信履歴が誤って入ると、本番運用時にその行が送信対象外になる。


________________


✅ STEP 2 完了確認
営業マネージャーの実装と動作確認が完了しました 🎉


現状で出来ること:
- スプシ M列 ON → 営業メール自動送信
- メニュー「② 返信を検知 + 草案生成」→ 返信検知して S列に草案生成
- スプシ T列 ON → 承認済み返信送信
- メニュー「④ 毎朝ルーティンを今すぐ実行」で①②③を一括実行


次は STEP 3 で「毎朝7時の自動実行」をONにします。「進めて」と返してください。

________________


STEP 3: 営業マネ稼働確認＋自動スケジュール（5分）
3-A. Gemini API キー（任意・返信草案生成）
質問
Gemini API キーを設定すると、返信検知時に S列に AI 草案が自動生成されます（無料枠あり）。


A. 今すぐ設定する
B. あとで設定する（送信・返信検知は API なしでも動きます）

「A」なら以下を案内:


1. https://aistudio.google.com/apikey にアクセス
2. キーを発行
3. Apps Script エディタ → ⚙ プロジェクトの設定 → スクリプト プロパティ
4. プロパティを追加:
   * 名前: GEMINI_API_KEY
   * 値: （取得したキー）
5. 保存
3-B. 毎朝7時の自動実行をON
⚠️ 高リスク操作。確認ゲートを通すこと。
質問
毎朝7時に「営業メール送信→返信検知→返信送信」を自動実行するトリガーをONにします。


注意: M列の承認☑がONの行のみ送信されます。OFFなら送信されません。
誤送信が心配なら、最初は OFF のまま運用して、慣れたら ON にする選択も可能です。


A. 今ONにする
B. 今はOFFのまま、手動メニュー実行で運用

「A」なら:


スプシのメニュー「営業マネ → ⚙ 毎朝7時の自動実行をON」をクリックしてください。
トースト「毎朝7時の自動実行をONにしました」が出れば設定完了です。
✅ STEP 3 完了
営業マネージャーの導入がすべて完了しました 🎉🎉


このあとは:
- 毎日スプシでターゲットを追加（A〜L列）
- 内容OKなら M列 ON で承認
- 翌朝7時に自動送信→返信検知→草案生成
- 草案OKなら T列 ON で返信送信


次は STEP 4 でマーケティングマネージャーを導入します。
営業マネを当面動かして慣れてから、後日改めてマーケマネを入れることもできます。


A. 今すぐマーケマネ導入に進む
B. 後日にする（このガイドを保存しておけば後で再開可能）

________________


STEP 4: マーケティングマネージャー実装（約45分）
Claude Code への指示: マーケマネは Python スクリプトで動く構成。営業マネと違ってブラウザ操作は最小。
💡 ここで詰まりやすい
* 4-C: GCPプロジェクト作成 — 初めての人は GCP コンソールが複雑に感じます。「OAuth consent screen」の設定で、自分のメールアドレスを「テストユーザー」に追加するのを忘れないこと。
* 4-C: Drive の u/3 別アカウント問題 — 複数 Google アカウントを使っている場合、認証アカウントと Drive フォルダの所有者が違うと「File not found」エラーが出ます。同じアカウントで認証するか、フォルダの共有設定で「編集者」権限を追加してください。
* 4-D: ANTHROPIC_API_KEY が反映されない — export で設定した場合、シェルを再起動するか source ~/.zshrc を実行しないと反映されません。
* 4-F: API 料金リスク — claude-sonnet-4-6 を使うと1記事あたり約 $0.05〜0.20（Anthropic 公式料金表）。1日3記事上限なので月 $5〜18 程度。本番運用前に料金プランを確認してください。
4-A. オウンドメディアの RSS 確認（3分）
質問
あなたのオウンドメディア「[URL]」の RSS フィードを確認します。
通常 WordPress なら「URL + /feed/」で取得できます。
実行
WebFetch で [URL]/feed/ を取得して、最新3件の記事タイトルと URL が取れるか確認。


* 取れた → ユーザーに最新記事タイトル3件を表示して確認:


RSS取得OK。最新記事3件:
1. [タイトル1]
2. [タイトル2]
3. [タイトル3]

* 取れなかった → 別のRSSパス（/atom.xml / /rss.xml）を試す。


________________


4-B. プロジェクトディレクトリの作成（3分）
実行
ユーザーのターミナルで:


mkdir -p ~/marketing-manager/output/{YouTube台本,TikTok台本,Instagram台本}
cd ~/marketing-manager

Claude Code は、このファイル末尾の 付録C: run_daily.py（全文） を読み込み、~/marketing-manager/run_daily.py として Write ツールでそのまま書き出すこと（ユーザーは手作業不要）。


________________


4-C. Google Drive 認証＋フォルダ準備（5分）
質問
Google Drive にアクセスするための認証ファイルを準備します。


A. すでに Google API の credentials.json を持っている
B. これから取得する（GCPプロジェクト作成・約8分）

「B」なら以下を案内:


1. https://console.cloud.google.com/ で新規プロジェクト作成
2. APIs & Services → Library で以下を有効化:
   * Google Drive API
   * Google Docs API
3. OAuth consent screen を設定（External / テスト ユーザーに自分を追加）
4. Credentials → Create Credentials → OAuth Client ID → Desktop app
5. JSONダウンロード → ~/marketing-manager/credentials.json にリネームして保存
実行（認証）
ユーザーに以下を実行してもらう:


cd ~/marketing-manager
python3 << 'PY'
from google_auth_oauthlib.flow import InstalledAppFlow
SCOPES = [
    "https://www.googleapis.com/auth/drive",
    "https://www.googleapis.com/auth/documents",
]
flow = InstalledAppFlow.from_client_secrets_file("credentials.json", SCOPES)
creds = flow.run_local_server(port=0)
with open("token.json", "w") as f:
    f.write(creds.to_json())
print("✅ 認証完了")
PY

→ ブラウザが開いてGoogleログイン→許可→token.json が生成される。
動作確認
~/marketing-manager/ に credentials.json と token.json が両方ありますか？
「ある」と返してくれたら次に進みます。

________________


4-D. ANTHROPIC_API_KEY の保存（2分）
⚠️ 高リスク操作（APIキー保存）
質問
Anthropic API キーをスクリプトから読めるように保存します。


保存方法は以下の2択:
A. シェル環境変数（推奨・export）
B. .env ファイル（プロジェクト内・誤コミット注意）


どちらにしますか？

選択に応じた手順案内:


* A: ~/.zshrc または ~/.bash_profile に export ANTHROPIC_API_KEY=sk-ant-... を追加 → source ~/.zshrc
* B: ~/marketing-manager/.env に ANTHROPIC_API_KEY=sk-ant-... を保存
実行＆動作確認
設定後、ターミナルで:


echo $ANTHROPIC_API_KEY | head -c 20

で sk-ant-... の先頭20文字が見えるか確認。


________________


4-E. run_daily.py の設定書き換え（3分）
質問
スクリプト内の3箇所をあなたの環境に合わせて書き換えます。Claude Code が直接書き換えるので「進めて」と返してください。
実行
~/marketing-manager/run_daily.py の以下を Edit ツールで書き換え:


* RSS_URL ← ユーザーのオウンドメディアRSS
* DRIVE_PARENT_ID ← ユーザーの台本格納先 Drive フォルダID（URLの末尾）
* SITE_NAME / SITE_URL ← ユーザーのサイト名・URL


________________


4-F. 初回手動実行（5分）
⚠️ 高リスク操作（API呼び出し料金発生・Drive書き込み）
質問
初回手動実行します。所要約2-3分（1記事につき Claude API で約30秒×3スクリプト分）。
最大3記事まで処理します（コスト管理）。


「進めて」で実行します。
実行
ユーザーのターミナルで:


cd ~/marketing-manager
python3 run_daily.py
動作確認
実行後、ユーザーに以下を確認:


処理ログに以下が表示されましたか？
- ✅ Google Drive/Docs API 接続OK
- 📡 RSSフィード取得中... 取得: N件 / 未処理: M件
- 📁 フォルダ作成: YouTube台本 / TikTok台本 / Instagram台本
- 📄 各台本の Google Docs URL（3つずつ × 記事数）


Drive を開いて、台本3種が「YouTube台本/」「TikTok台本/」「Instagram台本/」サブフォルダに保存されているか確認してください。

________________


4-G. 毎朝の自動実行スケジュール設定（2分）
質問
毎朝7時に自動実行する方法は以下の2択:


A. macOS の launchd（再起動しても自動再開・推奨）
B. cron（シンプル）


どちらにしますか？

A の場合: まずユーザーのPython実行パスを確定する:


which python3

表示されたパス（例: /opt/homebrew/bin/python3 または /usr/local/bin/python3）を控える。 ~/Library/LaunchAgents/com.user.marketing-manager.plist を Claude Code が Write で作成（テンプレートは付録G・Python パスをユーザー環境のものに置換）。


launchctl load ~/Library/LaunchAgents/com.user.marketing-manager.plist

B の場合: まず Python パスを確認:


which python3   # 結果を控える（例: /opt/homebrew/bin/python3）

crontab を編集:


crontab -e
# 以下を追加（PYTHON_PATH を上で確認したパスに置換）
0 7 * * * cd ~/marketing-manager && PYTHON_PATH run_daily.py >> ~/marketing-manager/cron.log 2>&1

完成例（Apple Silicon Mac で Homebrew Python の場合）:


0 7 * * * cd ~/marketing-manager && /opt/homebrew/bin/python3 run_daily.py >> ~/marketing-manager/cron.log 2>&1

⚠️ PYTHON_PATH の文字列はそのまま貼らないこと。実際のパス（/opt/homebrew/bin/python3 や /usr/local/bin/python3 等）に必ず置換してください。
✅ STEP 4 完了
マーケティングマネージャーの導入が完了しました 🎉🎉


このあとは:
- 毎朝7時、オウンドメディアの新着記事を検出
- 1記事につき YouTube/TikTok/Instagram の3種台本を自動生成
- Google Drive の所定フォルダに Google Docs で保存
- 処理済み記事は重複処理されません（processed.json で管理）


あとは生成された台本をベースに動画を撮るだけです。

________________


STEP 5: 全体確認とガードレール（5分）
動作確認チェックリスト
最終チェックです。すべてONか確認してください:


【営業マネ】
- [ ] スプシのメニュー「営業マネ」が出ている
- [ ] M2ONで送信成功（テスト送信完了）
- [ ] 毎朝7時の自動実行ON（または手動運用と決めた）


【マーケマネ】
- [ ] run_daily.py を手動実行 → Drive に3種台本が作成された
- [ ] launchd または cron に登録済み
- [ ] processed.json が生成されている


【共通ガードレール】
- [ ] 営業: 公開法人アドレスのみ・特商法フッター・NGワード禁止
- [ ] マーケ: 自社が権利を持つ素材のみ・自動公開しない（人間レビュー必須）
- [ ] 配信停止希望は最優先対応
法務確認チェックリスト
動画でも触れた「同意・契約・最小化」の3ゲート:


- [ ] NDA・利用規約に「外部AI委託」条項を追加（または既にある）
- [ ] 採用フォームに「AI選考補助の同意」を入れた（採用にも展開する場合）
- [ ] 顧客機密ノウハウをAIに渡さない運用ルールが社内にある
- [ ] APIキーの権限分離（個人キーと業務キーを分ける）

________________


🎉 導入完了
お疲れさまでした！


これで「営業マネ」と「マーケマネ」の2人があなたの会社で稼働しはじめます。


次にやることリスト:
1. 1週間運用してみる（営業送信件数・返信率・台本生成数を計測）
2. 毎週末にスプシのリストを更新（ターゲット追加・除外）
3. オウンドメディアの記事を増やす（マーケマネが台本生成してくれる）


困ったときは:
- このガイドの「付録G トラブルシューティング」を参照

________________




________________


📎 付録A: GAS Code.gs（全文）
営業マネのコア機能。Apps Script エディタの Code.gs に全文貼り付け。 冒頭の SHEET_ID / FROM_NAME / REPLY_TO は必ずユーザー環境に書き換えること。


/**
 * 営業マネージャー DB バインドスクリプト
 *
 * 機能:
 *  ① 承認☑ ON行を一括送信（M列 → N/O列に記録）
 *  ② 送信済み行のGmail返信を検知 → P/Q/R に転記
 *  ③ Gemini API で返信草案を S列に自動生成
 *  ④ 返信送信☑ ON行を一括送信（T列 → O列末尾に返信送信時刻を追記）
 *  ⑤ 毎朝7:00 自動実行トリガー（① + ② + ④）
 *
 * 設定:
 *  Apps Script の「プロジェクトの設定 > スクリプトのプロパティ」で
 *    GEMINI_API_KEY を設定すると S列の返信草案生成が有効化される（未設定でも他機能は動作）
 */


// ---- 定数（★ユーザー環境に書き換える） ----
const SHEET_ID = 'YOUR_SHEET_ID_HERE';           // スプシURLの /d/.../edit の ID
const SHEET_NAME = 'リスト';
const FROM_NAME = '株式会社○○○ 担当者名';        // 差出人表示名
const REPLY_TO = 'you@your-company.example';     // 返信先アドレス
const SEND_LIMIT_PER_DAY = 50;                    // 1日あたりの送信上限
const GEMINI_API_KEY_PROP = 'GEMINI_API_KEY';
const GEMINI_MODEL = 'gemini-2.0-flash-exp';


// 列番号（1-based）
const COL = {
  NO: 1, COMPANY: 2, URL: 3, INDUSTRY: 4, REVENUE: 5,
  LOCATION: 6, DEPT: 7, CONTACT: 8, EMAIL: 9, SOURCE: 10,
  SUBJECT: 11, BODY: 12,
  APPROVE_SEND: 13, SEND_AT: 14, SEND_STATUS: 15,
  REPLY_DETECTED: 16, REPLY_AT: 17, REPLY_BODY: 18, REPLY_DRAFT: 19,
  APPROVE_REPLY: 20
};


// ---- メニュー（onOpenで自動装着）----
function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('営業マネ')
    .addItem('① 承認済み営業メールを送信', 'sendApprovedEmails')
    .addItem('② 返信を検知 ＋ 草案生成', 'checkRepliesAndDraft')
    .addItem('③ 承認済み返信を送信', 'sendApprovedReplies')
    .addSeparator()
    .addItem('④ 毎朝ルーティンを今すぐ実行', 'runDailyRoutine')
    .addSeparator()
    .addItem('⚙ 毎朝7時の自動実行をON', 'setupDailyTrigger')
    .addItem('⚙ 自動実行をOFF', 'removeDailyTrigger')
    .addToUi();
}


// ---- ① 承認済み営業メール送信 ----
function sendApprovedEmails() {
  const sheet = _getSheet();
  const lastRow = sheet.getLastRow();
  if (lastRow < 2) {
    _toast('リストが空です');
    return;
  }


  const data = sheet.getRange(2, 1, lastRow - 1, COL.SEND_STATUS).getValues();
  const now = _nowJST();
  let sent = 0;
  let skipped = 0;
  let failed = 0;


  for (let i = 0; i < data.length; i++) {
    const rowNum = i + 2;
    const r = data[i];
    const approved = r[COL.APPROVE_SEND - 1];
    const sendStatus = r[COL.SEND_STATUS - 1];


    // 承認OFF or 既に処理済みはスキップ
    if (approved !== true || sendStatus !== '') {
      continue;
    }


    const email = String(r[COL.EMAIL - 1] || '').trim();
    const subject = String(r[COL.SUBJECT - 1] || '').trim();
    const body = String(r[COL.BODY - 1] || '').trim();


    if (!email || !subject || !body) {
      sheet.getRange(rowNum, COL.SEND_STATUS).setValue('失敗: 必須項目不足');
      failed++;
      continue;
    }


    if (sent >= SEND_LIMIT_PER_DAY) {
      sheet.getRange(rowNum, COL.SEND_STATUS).setValue('保留: 日次上限');
      skipped++;
      continue;
    }


    try {
      GmailApp.sendEmail(email, subject, body, {
        name: FROM_NAME,
        replyTo: REPLY_TO
      });
      sheet.getRange(rowNum, COL.SEND_AT).setValue(now);
      sheet.getRange(rowNum, COL.SEND_STATUS).setValue('送信完了');
      sent++;
    } catch (e) {
      sheet.getRange(rowNum, COL.SEND_STATUS).setValue('失敗: ' + e.message);
      failed++;
    }
  }


  _toast(`送信: ${sent} / 保留: ${skipped} / 失敗: ${failed}`);
}


// ---- ② 返信検知 + 草案生成 ----
function checkRepliesAndDraft() {
  const sheet = _getSheet();
  const lastRow = sheet.getLastRow();
  if (lastRow < 2) return;


  const data = sheet.getRange(2, 1, lastRow - 1, COL.APPROVE_REPLY).getValues();
  const apiKey = PropertiesService.getScriptProperties().getProperty(GEMINI_API_KEY_PROP);
  let detected = 0;
  let drafted = 0;
  let draftSkipped = 0;


  for (let i = 0; i < data.length; i++) {
    const rowNum = i + 2;
    const r = data[i];
    const sendStatus = String(r[COL.SEND_STATUS - 1] || '');
    const replyDetected = r[COL.REPLY_DETECTED - 1];


    // 未送信 or 既検知はスキップ
    if (!sendStatus.startsWith('送信完了') || replyDetected === true) {
      continue;
    }


    const email = String(r[COL.EMAIL - 1] || '').trim();
    const sendAt = r[COL.SEND_AT - 1];
    if (!email || !sendAt) continue;


    const query = `from:${email} after:${_gmailDate(sendAt)}`;
    const threads = GmailApp.search(query, 0, 5);
    if (threads.length === 0) continue;


    // 最新スレッドの最新メッセージ
    const latestMsg = threads[0].getMessages().slice(-1)[0];
    const replyBody = (latestMsg.getPlainBody() || '').substring(0, 5000);
    const replyAt = Utilities.formatDate(latestMsg.getDate(), 'JST', 'yyyy-MM-dd HH:mm');


    sheet.getRange(rowNum, COL.REPLY_DETECTED).setValue(true);
    sheet.getRange(rowNum, COL.REPLY_AT).setValue(replyAt);
    sheet.getRange(rowNum, COL.REPLY_BODY).setValue(replyBody);
    detected++;


    // 返信草案生成
    if (!apiKey) {
      sheet.getRange(rowNum, COL.REPLY_DRAFT).setValue('草案生成スキップ（GEMINI_API_KEY 未設定）');
      draftSkipped++;
      continue;
    }
    try {
      const draft = _generateReplyDraft(r, replyBody, apiKey);
      sheet.getRange(rowNum, COL.REPLY_DRAFT).setValue(draft);
      drafted++;
    } catch (e) {
      sheet.getRange(rowNum, COL.REPLY_DRAFT).setValue('草案生成失敗: ' + e.message);
    }
  }


  _toast(`返信検知: ${detected} / 草案生成: ${drafted} / API未設定スキップ: ${draftSkipped}`);
}


// ---- ③ 承認済み返信送信 ----
function sendApprovedReplies() {
  const sheet = _getSheet();
  const lastRow = sheet.getLastRow();
  if (lastRow < 2) return;


  const data = sheet.getRange(2, 1, lastRow - 1, COL.APPROVE_REPLY).getValues();
  const now = _nowJST();
  let sent = 0;
  let skipped = 0;


  for (let i = 0; i < data.length; i++) {
    const rowNum = i + 2;
    const r = data[i];
    const replyApproved = r[COL.APPROVE_REPLY - 1];
    const replyDetected = r[COL.REPLY_DETECTED - 1];
    if (replyApproved !== true || replyDetected !== true) continue;


    const email = String(r[COL.EMAIL - 1] || '').trim();
    const origSubject = String(r[COL.SUBJECT - 1] || '').trim();
    const draft = String(r[COL.REPLY_DRAFT - 1] || '').trim();


    if (!email || !draft) { skipped++; continue; }
    if (draft.indexOf('草案生成失敗') === 0 || draft.indexOf('草案生成スキップ') === 0) {
      skipped++;
      continue;
    }


    const subject = origSubject.indexOf('Re:') === 0 ? origSubject : 'Re: ' + origSubject;


    try {
      GmailApp.sendEmail(email, subject, draft, {
        name: FROM_NAME,
        replyTo: REPLY_TO
      });
      // 既存のO列ステータスに返信送信時刻を追記（履歴として残す）
      const cur = sheet.getRange(rowNum, COL.SEND_STATUS).getValue();
      sheet.getRange(rowNum, COL.SEND_STATUS).setValue(cur + ' / 返信送信: ' + now);
      // 二重送信防止: 返信送信☑ をOFFに戻す
      sheet.getRange(rowNum, COL.APPROVE_REPLY).setValue(false);
      sent++;
    } catch (e) {
      const cur = sheet.getRange(rowNum, COL.SEND_STATUS).getValue();
      sheet.getRange(rowNum, COL.SEND_STATUS).setValue(cur + ' / 返信送信失敗: ' + e.message);
    }
  }


  _toast(`返信送信: ${sent} / スキップ: ${skipped}`);
}


// ---- ④ 毎朝ルーティン ----
function runDailyRoutine() {
  sendApprovedEmails();
  Utilities.sleep(1500);
  checkRepliesAndDraft();
  Utilities.sleep(1500);
  sendApprovedReplies();
}


// ---- ⑤ 自動トリガー ----
function setupDailyTrigger() {
  removeDailyTrigger();
  ScriptApp.newTrigger('runDailyRoutine')
    .timeBased()
    .atHour(7)
    .everyDays(1)
    .inTimezone('Asia/Tokyo')
    .create();
  _toast('毎朝7時の自動実行をONにしました');
}


function removeDailyTrigger() {
  let removed = 0;
  ScriptApp.getProjectTriggers().forEach(t => {
    if (t.getHandlerFunction() === 'runDailyRoutine') {
      ScriptApp.deleteTrigger(t);
      removed++;
    }
  });
  if (removed > 0) _toast(`自動実行を解除しました（${removed}件）`);
}


// ---- 内部ヘルパー ----
function _getSheet() {
  return SpreadsheetApp.openById(SHEET_ID).getSheetByName(SHEET_NAME);
}


function _nowJST() {
  return Utilities.formatDate(new Date(), 'JST', 'yyyy-MM-dd HH:mm');
}


function _gmailDate(d) {
  let dt;
  if (d instanceof Date) {
    dt = d;
  } else {
    dt = new Date(d);
  }
  return Utilities.formatDate(dt, 'JST', 'yyyy/MM/dd');
}


function _toast(msg) {
  SpreadsheetApp.getActiveSpreadsheet().toast(msg, '営業マネ', 5);
}


function _generateReplyDraft(row, replyBody, apiKey) {
  const company = row[COL.COMPANY - 1];
  const ourSubject = row[COL.SUBJECT - 1];
  const ourBody = String(row[COL.BODY - 1] || '').substring(0, 1500);


  const prompt = [
    'あなたは法人向けサービスを提供する営業担当です。',
    '以下の文脈で、顧客企業からの返信に対する返信案を作成してください。',
    '',
    '【弊社が送ったメール】',
    `件名: ${ourSubject}`,
    `本文:\n${ourBody}`,
    '',
    `【顧客企業】 ${company}`,
    '',
    '【顧客からの返信】',
    replyBody.substring(0, 2500),
    '',
    '【返信案の要件】',
    '- 250〜450字程度',
    '- 返信内容に応じて、面談日程提案 / 質問への回答 / 礼儀対応 を判断',
    '- 「必ず」「絶対」「100%」などの断定表現NG（景表法）',
    '- 末尾に署名と特商法フッターを付与',
    '- 配信停止希望の返信であれば、お詫び＋配信停止対応の確約のみを返す',
    '',
    '返信案本文のみを出力してください（前置きや解説は不要）。'
  ].join('\n');


  const url = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${apiKey}`;
  const res = UrlFetchApp.fetch(url, {
    method: 'post',
    contentType: 'application/json',
    payload: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { temperature: 0.5, maxOutputTokens: 1024 }
    }),
    muteHttpExceptions: true
  });
  const code = res.getResponseCode();
  const json = JSON.parse(res.getContentText());
  if (code !== 200 || json.error) {
    throw new Error((json.error && json.error.message) || `HTTP ${code}`);
  }
  const text = json.candidates && json.candidates[0] &&
               json.candidates[0].content && json.candidates[0].content.parts &&
               json.candidates[0].content.parts[0] && json.candidates[0].content.parts[0].text;
  if (!text) throw new Error('Geminiから返信案を取得できませんでした');
  return text.trim();
}

________________


📎 付録B: appsscript.json（全文）
Apps Script の appsscript.json に全文貼り付け（OAuthスコープ宣言用）。


{
  "timeZone": "Asia/Tokyo",
  "dependencies": {},
  "exceptionLogging": "STACKDRIVER",
  "runtimeVersion": "V8",
  "oauthScopes": [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/gmail.send",
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/script.scriptapp",
    "https://www.googleapis.com/auth/script.external_request"
  ]
}

________________


📎 付録C: run_daily.py（全文）
マーケマネの日次ルーティン Python スクリプト。~/marketing-manager/run_daily.py に保存。 冒頭の RSS_URL / DRIVE_PARENT_ID / SITE_NAME / SITE_URL はユーザー環境に書き換える。


#!/usr/bin/env python3
"""
マーケティングマネージャー 日次ルーティン
オウンドメディアの新記事を検出し、YouTube/TikTok/Instagram 台本を生成して Google Docs に保存する。
"""


import json
import os
import re
import sys
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path


import requests
from bs4 import BeautifulSoup
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
from googleapiclient.discovery import build


# ── 設定（★ユーザー環境に書き換える） ─────────────────────────────
SCRIPT_DIR = Path(__file__).parent


RSS_URL = "https://your-site.example.com/feed/"           # オウンドメディアのRSS
DRIVE_PARENT_ID = "YOUR_DRIVE_FOLDER_ID_HERE"             # 台本格納先 Drive フォルダID
SITE_NAME = "あなたのオウンドメディア名"
SITE_URL = "https://your-site.example.com/"


# 認証ファイル（このスクリプトと同じディレクトリ）
TOKEN_PATH = SCRIPT_DIR / "token.json"
CREDS_PATH = SCRIPT_DIR / "credentials.json"


LOG_PATH = SCRIPT_DIR / "processed.json"
SUBFOLDER_CACHE = SCRIPT_DIR / "subfolder_ids.json"
OUTPUT_DIR = SCRIPT_DIR / "output"   # Drive 未認証時のフォールバック


# ★ 利用可能なモデルIDは時期で変わります。エラー時は以下から選択して書き換え:
#    - 公式モデル一覧: https://docs.anthropic.com/en/docs/about-claude/models/all-models
#    - 推奨候補: "claude-sonnet-4-6" (バランス) / "claude-opus-4-7" (高品質) / "claude-haiku-4-5-20251001" (高速・低コスト)
CLAUDE_MODEL = "claude-sonnet-4-6"
ANTHROPIC_API = "https://api.anthropic.com/v1/messages"


SCOPES = [
    "https://www.googleapis.com/auth/drive",
    "https://www.googleapis.com/auth/documents",
]




# ── 認証 ──────────────────────────────────────────────────────────
def get_google_creds():
    if not TOKEN_PATH.exists():
        return None
    creds = Credentials.from_authorized_user_file(str(TOKEN_PATH), SCOPES)
    if creds and creds.expired and creds.refresh_token:
        try:
            creds.refresh(Request())
            TOKEN_PATH.write_text(creds.to_json())
        except Exception as e:
            print(f"  ⚠️  トークンリフレッシュ失敗: {e}")
    return creds




def get_anthropic_key():
    key = os.environ.get("ANTHROPIC_API_KEY")
    if key:
        return key
    env_path = SCRIPT_DIR / ".env"
    if env_path.exists():
        for line in env_path.read_text().splitlines():
            if line.startswith("ANTHROPIC_API_KEY="):
                return line.split("=", 1)[1].strip().strip('"').strip("'")
    return None




# ── RSS ───────────────────────────────────────────────────────────
def fetch_rss(limit=10):
    resp = requests.get(RSS_URL, timeout=30, headers={"User-Agent": "Mozilla/5.0"})
    resp.raise_for_status()
    root = ET.fromstring(resp.content)
    ns = {"content": "http://purl.org/rss/1.0/modules/content/"}
    articles = []
    for item in root.findall(".//item")[:limit]:
        title = item.findtext("title", "").strip()
        link = item.findtext("link", "").strip()
        pub_date = item.findtext("pubDate", "").strip()
        articles.append({"title": title, "url": link, "pub_date": pub_date})
    return articles




# ── 記事テキスト抽出（URL直接フェッチ） ──────────────────────────
def extract_article_text(url):
    resp = requests.get(url, timeout=30, headers={"User-Agent": "Mozilla/5.0"})
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, "html.parser")
    container = soup.find("article") or soup.find("main")
    if not container:
        return soup.get_text(separator="\n", strip=True)
    for tag in container.find_all(["nav", "aside", "script", "style", "figure", "footer"]):
        tag.decompose()
    return container.get_text(separator="\n", strip=True)




# ── 台本生成 (Claude API) ─────────────────────────────────────────
def generate_scripts(api_key, title, article_text):
    prompt = f"""あなたは「{SITE_NAME}（{SITE_URL}）」のマーケティングマネージャーです。
以下の記事を元に、3種類の動画台本をJSON形式で作成してください。


【記事タイトル】
{title}


【記事内容】
{article_text[:8000]}


---


以下のJSON構造で返してください（コードブロックで囲む）:


```json
{{
  "youtube": {{
    "title": "YouTube動画タイトル（検索されやすいSEO最適化タイトル）",
    "script": "YouTube台本全文（20分相当・8000〜10000字）"
  }},
  "tiktok": {{
    "title": "TikTok動画タイトル（短くキャッチー）",
    "script": "TikTok台本全文（1分相当・350〜450字）"
  }},
  "instagram": {{
    "title": "Instagram動画タイトル",
    "script": "Instagram台本全文（1分相当・350〜450字）"
  }}
}}
各台本のガイドライン
YouTube（20分・8000〜10000字）
* オープニング（30秒）: 挨拶 + この動画で学べること
* 導入（2分）: 視聴者の課題・疑問を提示
* メインコンテンツ（15分）: 記事の内容を見出しごとに章立てして詳しく解説
* 実践デモ（2分）: 具体的な使い方・応用例
* まとめ + CTA（30秒）: 要点整理 + チャンネル登録 + 関連動画紹介
* 自然な話し言葉、視聴者への語りかけ口調
TikTok（1分・350〜450字）
* 冒頭3秒で強いフック
* 3つのポイントを簡潔に
* ラスト5秒でフォロー誘導 + 「続きはリンクから」
Instagram（1分・350〜450字）
* 視覚的なイントロ（何を話すか1文）


* ポイント2〜3個を具体的に


* ストーリー性のある語り口


* ラストにフォロー + プロフのリンク誘導"""


headers = { "x-api-key": api_key, "anthropic-version": "2023-06-01", "content-type": "application/json", } body = { "model": CLAUDE_MODEL, "max_tokens": 8192, "messages": [{"role": "user", "content": prompt}], } resp = requests.post(ANTHROPIC_API, headers=headers, json=body, timeout=180) resp.raise_for_status() text = resp.json()["content"][0]["text"]


m = re.search(r"json\s*(.*?)\s*", text, re.DOTALL) if m: return json.loads(m.group(1)) return json.loads(text)
── Google Drive / Docs ───────────────────────────────────────────
def get_or_create_subfolders(drive_svc): if SUBFOLDER_CACHE.exists(): cached = json.loads(SUBFOLDER_CACHE.read_text()) try: first_id = next(iter(cached.values())) drive_svc.files().get(fileId=first_id, fields="id", supportsAllDrives=True).execute() return cached except Exception: pass


subfolder_ids = {}
for name in ["YouTube台本", "TikTok台本", "Instagram台本"]:
    q = (
        f"name='{name}' and '{DRIVE_PARENT_ID}' in parents "
        "and mimeType='application/vnd.google-apps.folder' and trashed=false"
    )
    res = drive_svc.files().list(
        q=q, fields="files(id,name)",
        supportsAllDrives=True, includeItemsFromAllDrives=True
    ).execute()
    files = res.get("files", [])
    if files:
        subfolder_ids[name] = files[0]["id"]
    else:
        meta = {
            "name": name,
            "mimeType": "application/vnd.google-apps.folder",
            "parents": [DRIVE_PARENT_ID],
        }
        f = drive_svc.files().create(body=meta, fields="id", supportsAllDrives=True).execute()
        subfolder_ids[name] = f["id"]
        print(f"  📁 フォルダ作成: {name}")


SUBFOLDER_CACHE.write_text(json.dumps(subfolder_ids, ensure_ascii=False, indent=2))
return subfolder_ids

def create_google_doc(docs_svc, drive_svc, title, body_text, folder_id): doc = docs_svc.documents().create(body={"title": title}).execute() doc_id = doc["documentId"] docs_svc.documents().batchUpdate( documentId=doc_id, body={"requests": [{"insertText": {"location": {"index": 1}, "text": body_text}}]}, ).execute() drive_svc.files().update( fileId=doc_id, addParents=folder_id, removeParents="root", fields="id,parents", supportsAllDrives=True, ).execute() return f"https://docs.google.com/document/d/{doc_id}/edit"
── テキスト整形 ──────────────────────────────────────────────────
def format_doc(platform, title, script, article_url): today = datetime.now().strftime("%Y-%m-%d") platform_label = {"youtube": "YouTube（20分）", "tiktok": "TikTok（1分）", "instagram": "Instagram（1分）"} return ( f"# {title}\n\n" f"> 生成日: {today}\n" f"> プラットフォーム: {platform_label.get(platform, platform)}\n" f"> 元記事: {article_url}\n" f"> サイト: {SITE_URL}\n\n" "---\n\n" f"{script}\n" )
── ログ ──────────────────────────────────────────────────────────
def load_log(): return json.loads(LOG_PATH.read_text()) if LOG_PATH.exists() else {}


def save_log(data): LOG_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2))
── メイン ────────────────────────────────────────────────────────
def main(): print("=" * 60) print(f"🎯 マーケティングマネージャー 朝ルーティン") print(f"   {datetime.now().strftime('%Y-%m-%d %H:%M')}") print("=" * 60)


processed = load_log()


api_key = get_anthropic_key()
if not api_key:
    print("❌ ANTHROPIC_API_KEY が見つかりません")
    print("   export ANTHROPIC_API_KEY=sk-... を設定してください")
    sys.exit(1)


creds = get_google_creds()
drive_svc = docs_svc = None
if creds and creds.valid:
    try:
        drive_svc = build("drive", "v3", credentials=creds)
        docs_svc = build("docs", "v1", credentials=creds)
        print("✅ Google Drive/Docs API 接続OK")
    except Exception as e:
        print(f"⚠️  Google API 初期化失敗: {e} → ローカル保存に切り替え")


subfolder_ids = {}
if drive_svc:
    try:
        subfolder_ids = get_or_create_subfolders(drive_svc)
        print(f"✅ Drive フォルダ確認: {list(subfolder_ids.keys())}")
    except Exception as e:
        print(f"⚠️  Drive フォルダ操作失敗: {e} → ローカル保存に切り替え")
        drive_svc = docs_svc = None


if not drive_svc:
    for name in ["YouTube台本", "TikTok台本", "Instagram台本"]:
        (OUTPUT_DIR / name).mkdir(parents=True, exist_ok=True)


print("\n📡 RSSフィード取得中...")
articles = fetch_rss(limit=10)
new_articles = [a for a in articles if a["url"] not in processed]
print(f"   取得: {len(articles)}件 / 未処理: {len(new_articles)}件")


if not new_articles:
    print("\n✅ 新しい記事はありません。本日の処理完了。")
    return


results = []
for i, article in enumerate(new_articles[:3]):  # 1日最大3記事（コスト管理）
    print(f"\n[{i + 1}/{min(len(new_articles), 3)}] {article['title'][:50]}...")
    try:
        text = extract_article_text(article["url"])
        print(f"   記事テキスト: {len(text)}字")
    except Exception as e:
        print(f"   ⚠️  記事フェッチ失敗: {e}")
        continue


    print("   台本生成中（Claude API）...")
    try:
        scripts = generate_scripts(api_key, article["title"], text)
    except Exception as e:
        print(f"   ❌ 台本生成失敗: {e}")
        continue


    today = datetime.now().strftime("%Y-%m-%d")
    slug = article["url"].rstrip("/").split("/")[-1][:30]
    doc_urls = {}


    for platform, folder_name in [
        ("youtube", "YouTube台本"),
        ("tiktok", "TikTok台本"),
        ("instagram", "Instagram台本"),
    ]:
        s = scripts.get(platform, {})
        doc_title = f"[{today}] {s.get('title', article['title'])[:50]}"
        content = format_doc(platform, s.get("title", article["title"]), s.get("script", ""), article["url"])


        if drive_svc and docs_svc and folder_name in subfolder_ids:
            try:
                url = create_google_doc(docs_svc, drive_svc, doc_title, content, subfolder_ids[folder_name])
                doc_urls[platform] = url
                print(f"   📄 {folder_name}: {url}")
            except Exception as e:
                print(f"   ⚠️  Docs 保存失敗 ({platform}): {e}")
                fpath = OUTPUT_DIR / folder_name / f"{today}_{slug}.md"
                fpath.write_text(content, encoding="utf-8")
                doc_urls[platform] = str(fpath)
        else:
            fpath = OUTPUT_DIR / folder_name / f"{today}_{slug}.md"
            fpath.write_text(content, encoding="utf-8")
            doc_urls[platform] = str(fpath)
            print(f"   💾 ローカル: {fpath.name}")


    processed[article["url"]] = {
        "title": article["title"],
        "processed_at": datetime.now(timezone.utc).isoformat(),
        "docs": doc_urls,
    }
    save_log(processed)
    results.append({"title": article["title"], "docs": doc_urls})


print("\n" + "=" * 60)
print(f"📊 本日のサマリー: {len(results)}記事を処理")
for r in results:
    print(f"\n  ✅ {r['title'][:50]}")
    for platform, url in r["docs"].items():
        print(f"     {platform:12s}: {url}")
print("=" * 60)

if name == "main": main()



---


# 📎 付録D: スプシ20列構造リファレンス


> 営業マネ用スプレッドシートの列定義。Claude Code はこの仕様で1行目を作成すること。


| 列 | ヘッダー | 用途 | 入力ルール |
|:---|:---|:---|:---|
| A | No | 通し番号 | 手入力 or 自動採番 |
| B | 会社名 | ターゲット企業名 | 必須 |
| C | URL | 企業HP TOPページ | https:// から |
| D | 業種 | 業界カテゴリ | 自由記述 |
| E | 推定年商 | 公開IRから推定 | 「5億〜10億」等 |
| F | 所在地 | 本社都道府県+市区 | 自由記述 |
| G | 部署 | 想定窓口 | 「広報」「営業企画」等 |
| H | 担当者名 | 公開取得できれば | なければ「ご担当者様」 |
| I | 公開メール | info@/contact@/sales@ | **個人アドレス禁止** |
| J | 取得ソース | HP/プレス/業界誌名 | 出典明記 |
| K | 件名草案 | 営業メール件名 | **30字以内・固有キーワード** |
| L | 本文草案 | 営業メール本文 | **特商法フッター必須** |
| M | 承認☑ | 送信承認 | チェックボックス |
| N | 送信日時 | 自動入力（GAS） | 編集不可 |
| O | 送信ステータス | 自動入力 | 「送信完了」「失敗: ...」 |
| P | 返信検知 | 自動入力（GAS） | TRUE/FALSE |
| Q | 返信日時 | 自動入力 | Gmail検知 |
| R | 返信本文 | 自動入力 | 最大5000字 |
| S | 返信草案 | Gemini自動生成 | 編集可（人間チェック） |
| T | 返信送信☑ | 返信承認 | チェックボックス（送信後自動OFF） |


**フェーズ別の色分け（任意）**:
- A-L列（手作業＋AI生成）: 白
- M列（人間ゲート）: 緑系
- N-R列（自動）: グレー系
- S列（AI生成＋人間チェック）: 黄系
- T列（人間ゲート）: 緑系


---


# 📎 付録E: 共通会社憲法（CLAUDE.md相当）


> 営業マネ・マーケマネが守る共通ルール。プロジェクト直下に `CLAUDE.md` として配置するとClaude Codeが自動読み込み。


```markdown
# [会社名] AI社員 共通憲法


## あなたの役割
あなたは [会社名] の各マネージャーとして振る舞います。
社長（あなた=ユーザー）からの指示に応じて、自分の領域の業務を実行します。


## マネージャー編成
- 営業マネージャー（マネージャー/営業/）
- マーケティングマネージャー（マネージャー/マーケティング/）


## 全マネージャー共通の3つのゲート


### ① 同意ゲート
本人/顧客に「AI処理を使う」旨の同意を取得済みかを必ず確認する。
未取得の場合は実行を停止し、社長に同意取得を促す。


### ② 契約ゲート
NDA・利用規約・採用要項に「外部AI委託」の条項があるかを確認する。
無い場合は実行を停止し、社長に契約整備を促す。


### ③ 最小化ゲート
必要最小限のデータのみを処理する。氏名・社名・金額・機密ノウハウを過剰に投入しない。


## 共通NGワード
- 「必ず」「絶対」「100%」（景表法・優良誤認）
- 顧客・候補者・取引先の実名を勝手に公開しない


## 共通フォーマット
- 文書はMarkdown
- 数値は全桁表記（¥1,000,000 ○ / 1M ✗）
- 日付はYYYY-MM-DD


## 不明な指示への対応
領域外の指示を受けた場合は「これは○○マネージャーの担当領域です」と返し、自分は実行しない。
営業マネージャー固有ルール（マネージャー/営業/CLAUDE.md）
# 営業マネージャー 行動規範


## ミッション
公開法人アドレスへのアウトバウンド営業を、特商法を守りながら自動化する。


## 営業送信のガードレール
- **公開法人アドレスのみ**（info@ / contact@ / sales@）
- **特商法フッター必須**（送信元・住所・連絡先・配信停止導線）
- **NGワード禁止**: 必ず・絶対・100%・最大限・劇的に改善
- **件名30字以内**、顧客固有キーワード入り
- **送信は人間承認後**（M列☑ ON のみ）
- **1日あたり50通上限**
- **配信停止希望は最優先対応**（停止して個別お詫び返信）


## リサーチのソース
- HP/コーポレートサイト
- プレスリリース（PR TIMES等）
- 業界誌・新聞オンライン
- 上場企業ならIR資料


## NG行動
- 個人メールアドレス（@gmail.com等）への送信
- 顧客の機密ノウハウをプロンプトに入れる
- 「営業」「セールス」「マーケ」等を件名に入れて自動フィルタに引っかかる
マーケティングマネージャー固有ルール（マネージャー/マーケティング/CLAUDE.md）
# マーケティングマネージャー 行動規範


## ミッション
オウンドメディアの新着記事から、YouTube/TikTok/Instagram の動画台本を毎朝自動生成する。


## ガードレール5箇条


### 1. 自社で権利を持つ素材のみ
他人のYouTube動画を文字起こしして他媒体に転用しない。
画像・音声・BGMも商用利用可・SNS再投稿可・広告利用可まで確認。


### 2. AI生成物の他社著作物混入チェック
公開前に固有表現・画像・歌詞・台詞・商標っぽい要素を確認。


### 3. 出演者の他媒体二次利用同意
YouTubeで出演した人の声・顔を Instagram/TikTok に転用する場合は事前同意。


### 4. ステマ規制対応
報酬・提供・関係性がある投稿は「PR」「広告」「提供」を冒頭に明記。
AIで加工した映像・音声は各SNSのAI生成表示を使う。


### 5. 完全自動公開せず人間レビュー
AIで作るのは効率化。公開前に人間が著作権・誇大広告・各SNS規約を確認。
Google Helpful Content 対応で価値のない量産はしない。


## 処理上限
- 1日最大3記事（API コスト管理）
- 処理済み記事は `processed.json` に記録（重複処理防止）


## YouTube台本構成
1. オープニング（30秒）: 挨拶 + この動画で学べること
2. 導入（2分）: 視聴者の課題・疑問を提示
3. メインコンテンツ（15分）: 記事を見出しごとに章立て
4. 実践デモ（2分）: 具体的な使い方・応用例
5. まとめ + CTA（30秒）: 要点整理 + チャンネル登録誘導


## TikTok / Instagram 台本構成
- 冒頭3秒で強いフック
- 3ポイントを簡潔に
- ラストはフォロー誘導 + 「続きはリンクから」

________________


📎 付録F: ガードレール条文集（同意・契約・最小化）
法務対応の条文サンプル。自社の NDA・利用規約・採用要項に追記する。法務確認推奨。
利用規約への追記（営業マネ・顧客対応）
第○条（外部AI委託・自動処理）
当社は、お客様からのお問い合わせ対応・商談記録の要約・返信草案作成等の業務において、
外部AI事業者（Anthropic, OpenAI, Google等）のAPIを利用することがあります。
これらのAPI利用にあたっては、お客様の機密情報を最小限とし、AI事業者の学習データに
利用されない設定を選択します。
NDA への追記（取引先対応）
第○条（外部AIの利用）
受領者は、本契約に基づき取得した秘密情報を外部AIサービスに入力する場合、
事前に開示者へ書面（メールを含む）で通知し、開示者の同意を得るものとする。
採用要項への追記（採用マネ展開時）
■ 応募にあたっての同意事項
ご応募内容（履歴書・職務経歴書）は、当社採用担当者および採用補助AI（Anthropic Claude等）
により書類選考に利用させていただきます。
AI単独で不採用判断を行うことはなく、最終判断は必ず人間が行います。
同意いただけない場合は、本フォーム下部の「AI処理に同意しない」をチェックしてください。
配信停止対応の社内ルール
* 配信停止希望のメールは 48時間以内に対応
* スプシの該当行に「配信停止」ステータスを記録
* 同一企業の別アドレスにも送信しない（社内DB更新）
* 担当者からお詫びの個別返信を1通必ず送る


________________


📎 付録G: トラブルシューティング
営業マネ
症状
	原因
	対処
	スプシのメニュー「営業マネ」が出ない
	onOpen未実行
	スプシをリロード or Apps Scriptで onOpen() を手動実行
	「Service invoked too many times: gmail」エラー
	1日上限超過
	SEND_LIMIT_PER_DAY を下げる or 翌日まで待つ
	「返信を検知」が動かない
	Gmailスコープ未認可
	appsscript.json の gmail.readonly を確認・再認可
	「Gemini草案生成失敗」
	API キー未設定 or quota超過
	スクリプトプロパティ GEMINI_API_KEY を確認
	メールが届かない
	公開アドレス側で受信拒否
	スプシO列のステータスで失敗詳細を確認
	自動トリガーが動かない
	タイムゾーン違い
	Apps Script → ⚙ → タイムゾーンを Asia/Tokyo に
	マーケマネ
症状
	原因
	対処
	ANTHROPIC_API_KEY が見つかりません
	env未設定
	export ANTHROPIC_API_KEY=sk-ant-... を実行 or .env 作成
	File not found: [DRIVE_PARENT_ID]
	フォルダID間違い or 権限なし
	DriveのフォルダURLから ID 確認・編集者権限あるアカウントで再認証
	model: ... not_found_error / 404 model not found
	モデルIDが時期によって変わった
	CLAUDE_MODEL を https://docs.anthropic.com/en/docs/about-claude/models/all-models の最新IDに書き換え
	RSS取得失敗
	URLが間違い
	URL/feed/を直接ブラウザで開いて確認
	台本生成失敗（JSON parse error）
	Claude が JSON 形式で返さなかった
	リトライ or プロンプトのJSON指定を強化
	Drive保存失敗 → ローカル保存に
	スコープ不足
	token.json を削除して再認証（Drive/Docs スコープ追加）
	同じ記事が毎日処理される
	processed.json の書き込み失敗
	スクリプトディレクトリの書き込み権限を確認
	launchd plist テンプレ（macOS自動実行）
~/Library/LaunchAgents/com.user.marketing-manager.plist:


<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.marketing-manager</string>
    <key>ProgramArguments</key>
    <array>
        <!-- ★ `which python3` の結果に置換すること（例: /opt/homebrew/bin/python3） -->
        <string>YOUR_PYTHON3_PATH_HERE</string>
        <string>/Users/YOUR_USERNAME/marketing-manager/run_daily.py</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key><integer>7</integer>
        <key>Minute</key><integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/Users/YOUR_USERNAME/marketing-manager/cron.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/YOUR_USERNAME/marketing-manager/cron.err</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>ANTHROPIC_API_KEY</key>
        <string>sk-ant-YOUR_KEY_HERE</string>
    </dict>
</dict>
</plist>

登録: launchctl load ~/Library/LaunchAgents/com.user.marketing-manager.plist
解除: launchctl unload ~/Library/LaunchAgents/com.user.marketing-manager.plist


________________


📎 付録H: 用語集（非技術者向け）
用語
	一言で
	このガイドでの使われ方
	Claude Code
	Anthropic公式のCLIツール。AIにコードを書かせたりタスクを実行させたりできる
	このガイドを「読ませる」先
	GAS（ジーエーエス）
	Google Apps Script の略。Google のサーバー上で動く JavaScript
	営業メール送信・返信検知を担当
	API キー
	サービス（OpenAI/Anthropic等）を使うための鍵
	流出させると料金を不正使用される。GitHubに置かない
	cron（クーロン）
	「毎朝7時に実行」のような定期実行の仕組み
	マーケマネの朝ルーティンに使用
	launchd（ローンチドゥー）
	macOS版の cron。Macを再起動しても自動再開
	マーケマネ朝ルーティンの推奨方式
	OAuth（オーオース）
	「このアプリにこの権限を与える」と認証する仕組み
	GAS の Gmail送信権限、Python の Drive 書き込み権限で必要
	Drive API
	Google Drive をプログラムから操作する仕組み
	マーケマネが Google Docs を Drive に保存するため
	RSS（アールエスエス）
	サイトの新着記事を機械可読な形で配信するフィード
	マーケマネが新着記事を検出するため
	MCP（エムシーピー）
	Claude Code が外部サービス（Google Sheets等）を使うための仕組み
	スプシ作成・Drive 操作で利用（環境による）
	特商法フッター
	特定商取引法に基づく送信者情報の表示
	営業メール末尾に必須（送信元・住所・連絡先・配信停止導線）
	NDA（エヌディーエー）
	秘密保持契約
	「外部AI委託」条項を追加する必要あり
	

________________




このファイルは Claude Codeチャンネル「Claude CodeでAI社員と経営を自動化」動画の視聴特典です。 商用利用OK・改変OK・再配布NG（オリジナルのままLINE登録特典として配布してください）。