---
type: source_summary
status: 整理済み
date: 2026-07-12
source_type: youtube_batch
tags: [youtube, codex, websites, chatgpt-work, workflow, duplicate-triage]
---

# 2026-07-12 YouTube追加分 / Codex・ChatGPT Work・Web制作 横断要約

## 対象

- [[raw/webclip-index/2026-07-11-youtube-gpt-5-6を徹底解説-chatgpt-workとcodexの違い-ai活用事例]]
- [[raw/webclip-index/2026-07-11-youtube-codexの-sites-機能でwebサイトを作ってみた-そのまま公開まで出来るじゃん]]
- [[raw/webclip-index/2026-07-11-youtube-神アプデ-ついにchatgptが50万円の案件をし続ける永久機関になりました]]
- [[raw/webclip-index/2026-07-11-youtube-ai時代のwordpressサイトの作り方-claude-x-codex-x-wp]]
- [[raw/webclip-index/2026-07-11-youtube-codex-gpt-image2-0でlpが爆速完成-aiでlp制作する方法]]
- [[raw/webclip-index/2026-07-11-youtube-fable5超え-新モデル-gpt-5-6-登場-驚きの神アプデ連発でclaudecodeはオワコンになりました-codex-openai]]

## 横断要約

今回の6本は、CodexとChatGPT Workを「Webサイト、LP、WordPress、資料、アプリ制作の作業環境」として使う話に集約される。

主なまとまりは次の通り。

- **ChatGPT WorkとCodexの使い分け**: 動画内では、ChatGPT Workはスライド、シート、ドキュメント、Webサイトなどの納品物作成寄り、Codexは開発、検証、レビュー、Git連携寄りとして説明されている。
- **Codex Sites**: Codex内でWebサイトを生成し、そのまま公開・共有まで進める機能の実演。環境変数やシークレット管理に触れているが、公開URLやAPIキーの扱いは慎重に確認する必要がある。
- **LP制作**: Codexで要件整理、GPT Image系でラフ案を複数作成、人間が採用案を選び、HTML初稿へ進める流れ。完成品ではなく、クライアント確認用の初稿・叩き台として使うのが現実的。
- **WordPress化**: 仕様書、design.md、画像API、Codex/Claudeを組み合わせ、静的HTMLをWordPressテーマや動的サイトへ近づける流れ。Contact Form 7や投稿ループなど、WP固有の動的化が論点。
- **収益化・案件化の主張**: 高単価案件、永久機関、収益化といった表現は営業色が強い。実務では、公開、納品、請求、顧客提案、APIキー設定に人間承認を残す。
- **モデル・新機能ニュース**: 動画内ではGPT-5.6、ChatGPT/Codex統合、Work、Sites、追加プラグインなどの話が出るが、名称、料金、提供範囲、性能は変わりやすいため公式情報で確認する。

## 自分の運用への反映

- Web制作系の素材は、要件定義、仕様書、design.md、画像素材、APIキー、公開先を分けて管理する。
- Codexには「最終納品物を丸投げ」ではなく、要件整理、複数案作成、初稿作成、差分修正、検証を任せる。
- SitesやWordPress公開を扱う場合、公開URL、環境変数、シークレット、フォーム送信、問い合わせ先、商用素材の権利を確認する。
- `ObsidianSecondBrain` では、動画本文やZip展開物は保存せず、要約・判断・導入前チェックだけを残す。

## 重複判断

- ChatGPT/Codex新機能ニュースは [[reports/source-summaries/2026-07-11-youtube-codex-content-creation-batch|2026-07-11 YouTube追加分 / Codexコンテンツ制作・業務自動化 横断要約]] と強く重複するため、仕様確認前の参考情報として扱う。
- Web/LP/WordPress制作は今回の新規Zip素材 [[reports/source-summaries/2026-07-12-tool-website-spec-prompts|Webサイト仕様書とプロンプトZip 導入判断メモ]] と関連する。実装テンプレート化するなら、Zip素材の仕様書を先に整理する。
- Codex Sitesは既存のローカルWeb制作やSitesプラグイン運用と関連するが、公開を伴うため自動実行対象にはしない。

## 注意点

- 動画内のモデル名、料金、機能名、提供範囲はTranscript由来であり、公式確認済みではない。
- APIキーやOAuthトークンはGitに保存しない。
- 公開、投稿、納品、請求、外部フォーム送信、WordPress本番反映は人間承認を残す。
