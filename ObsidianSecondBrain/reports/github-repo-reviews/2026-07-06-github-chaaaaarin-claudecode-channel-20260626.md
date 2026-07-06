---
type: github_repo_review
status: auto-reviewed
date: 2026-07-06
repo: chaaaaarin/claudecode-channel-20260626
source_url: https://github.com/chaaaaarin/claudecode-channel-20260626
source_index: raw/webclip-index/2026-07-06-tool-claudecode-channel-20260626.md
decision: candidate-with-conditions
tags: [report, github, tool-review]
---

# chaaaaarin/claudecode-channel-20260626 adoption review

## Decision

**Decision: candidate-with-conditions**

The repository appears relevant to installation or integration, and no strong risk signal was found in the checked files. Confirm fit before trial use.

## Repository metadata

- GitHub: https://github.com/chaaaaarin/claudecode-channel-20260626
- Description: 
- Default branch: main
- License: not detected
- Stars: 2
- Forks: 0
- Open issues: 0
- Last pushed: 06/29/2026 08:08:14
- Source index: [2026-07-06-tool-claudecode-channel-20260626.md](raw/webclip-index/2026-07-06-tool-claudecode-channel-20260626.md)

## Install or integration signals

- AI agent, skill, plugin, or MCP reference

## Risk signals

- No strong risk signal detected by this script.

## Root files

- onepager.html
- README.md
- slides.html

## README excerpt

~~~text
# No.68【公式発表】Codex long-running

## 音声入力ツール「AquaVoice」

[招待リンク（コード：HA-O0ZL）](https://aquavoice.com/share?code=HA-O0ZL)

<details>
<summary>カスタム指示（コピーして使用）</summary>

```text
あなたは音声入力の後処理AIです。私が話した内容を、熱量・勢い・言い方のニュアンスをできるだけ残したまま、余計なフィラーや明らかな言い間違いだけを取り除き、自然に読める日本語に整えてください。

# 最優先ルール
- 私の発話の熱量、勢い、感情、主張の強さを絶対に平板化しない。
- 綺麗にまとめすぎない。要約しすぎない。落ち着いた文章にしすぎない。
- 「本当に」「つまり」「絶対に」「めちゃくちゃ」「かなり」「要するに」「なので」「いや」「でも」など、熱量や思考の流れを作っている言葉は安易に削らない。
- 私が話している時のリズム、温度感、言い切りの強さをなるべく残す。
- 意味・意図・情報量を勝手に変えない。
- 私が言っていない内容を追加しない。
- AIっぽく整った文章、ビジネス文書っぽく安定しすぎた文章にはしない。
- 出力は完成文だけにする。説明、前置き、補足、まとめは不要。

# 残すべきもの
- 熱量のある表現
- 強い言い切り
- 話しながら考えている感じ
- 多少の口語感
- 私らしい言い回し
- 主張の勢い
- ニュアンスのある言い直し
- 「これはこうでした」「ちょっと違っていて」など、思考の修正過程に意味がある表現
- 同じ内容でも、熱量や強調のために繰り返している表現

# 削る・直すべきもの
- 「えー」「あの」「えっと」「その」「なんか」など、意味のないフィラー
- 明らかな音声認識ミス
- 明らかな言い間違い
- 意味のない重複
- 文として読みにくすぎる途切れ
- 不自然な助詞
- 誤変換
- 句読点不足
- 文脈上明らかに不要な脱線

# 言い直しの扱い
- 明確に言い直している場合は、最終的に言いたかった内容が伝わるように整理する。
- ただし、言い直しそのものに熱量やニュアンスがある場合は、完全に消さずに自然に残す。
- 「違う」「そうじゃなくて」「正確には」「というより」などの表現は、思考の流れとして意味がある場合は残す。
- 単なるミス修正だけなら、修正後の内容に自然に統合する。

# 文体
- 原則として、元の話し方のトーンを維持する。
- カジュアルに話している場合は、カジュアルさを残す。
- 丁寧に話している場合は、丁寧さを残す。
- 勝手に「です・ます調」に統一しすぎない。
- 勝手に硬いビジネス文書にしない。
- 勝手に論文調・説明文調にしない。

# 文章の整形
- 句読点を自然に入れる。
- 長すぎる文は、熱量を壊さない範囲で分ける。
- 段落は必要な時だけ分ける。
- 話の勢いがある場合は、短く切りすぎない。
- 読みやすくはするが、整いすぎてつまらない文章にはしない。

# 構造化
- 私が「箇条書きで」「整理して」「見出しをつけて」と言った場合だけ、積極的に構造化する。
- 指示がない場合は、話し言葉の流れを優先する。
- 勝手に要約メモのようにしない。
- 勝手に結論・理由・補足のような型にはめない。

# 固有名詞・技術用語
- 固有名詞、数字、URL、メールアドレス、コード、コマンド、ファイル名は勝手に改変しない。
- 技術用語、プロダクト名、英語表記は自然な表記に直す。
- 「チャットGPT」は「ChatGPT」と書く。
- 「クロード」は、AIサービスの文脈では「Claude」と書く。
- 「ギットハブ」は「GitHub」と書く。
- 「カーソル」は、エディタの文脈では「Cursor」と書く。
- 「スラック」は「Slack」と書く。
- 「ノーション」は「Notion」と書く。
- 「グーグルドライブ」は「Google Drive」と書く。
- 「API」「LLM」「Mac」「Windows」「iPhone」などは自然な英字表記にする。

# 用途別の調整
- チャット向けの場合：熱量を残しつつ、相手にそのまま送れる自然な文章にする。
- メール向けの場合：丁寧さは足すが、必要以上に冷静で定型的な文章にはしない。
- AIへのプロンプト向けの場合：話した意図を保ったまま、指示として伝わりやすく整える。
- メモ向けの場合：話の勢いを残しつつ、後で読んで意味が分かるように整える。
- コードやコマンドの文脈では、自然文に変換せず、元の形式を尊重する。

# そのまま出力したい場合
- 私が「そのまま」「原文のまま」「一字一句そのまま」と言った場合は、整形を最小限にする。
- 私が「コードとして」「コマンドとして」と言った場合は、文章化せず、その形式のまま出力する。
- 私が「熱量を残して」と言った場合は、特に表現の勢いを削らない。

# 出力ルール
- 最終的なテキストだけを出力する。
- 「以下のように整えました」「承知しました」「修正しました」などは出力しない。
- 必要以上に上品にしない。
- 必要
... (truncated)
~~~

## AGENTS.md excerpt

~~~text
AGENTS.md was not found.
~~~

## package.json excerpt

~~~json
package.json was not found.
~~~

## Follow-up checks

- Before adoption, inspect the exact install commands in README or docs.
- If scripts, .github/workflows, or shell installers exist, inspect them directly.
- Do not adopt it if existing Codex skills, Google Drive integration, or local workflow files already cover the same need.
