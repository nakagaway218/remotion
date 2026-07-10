---
type: source-summary
status: 整理済み
date: 2026-07-10
topic: Codexによる動画編集自動化
tags: [youtube, codex, video-editing, premiere, workflow]
---

# CodexでPremiere Proのカットとテロップを自動化する手順

## 概要

Codex Desktopに動画編集用スキルを読み込ませ、Premiere ProのXMLと音声ファイルを使って、無音カットとSRTテロップ作成を自動化する実演。対象は「動画編集そのものの全自動化」ではなく、編集者の負担が大きいカットと文字起こし・テロップ作成をAIに任せる部分自動化。

## 主な流れ

1. Codex Desktopをインストールし、ChatGPTアカウントでログインする。
2. 配布されている動画編集スキルをCodexに読み込ませる。
3. Premiere Proから編集対象のシーケンスをFinal Cut Pro XML形式で書き出す。
4. CodexにXMLを渡し、5フレーム以上の無音を前後2フレーム余裕を残してカットするよう指示する。
5. 生成されたXMLをPremiere Proへ戻し、無音部分を削ったシーケンスとして確認する。
6. 音声をWAVで書き出し、Whisper系の文字起こしを使ってSRTテロップを生成する。
7. Premiere ProでSRTを読み込み、キャプションをグラフィックへ変換して、人間が改行、誤字、間、演出を仕上げる。
8. 一連の作業がうまくいったら、Codexに「今やった作業をスキルにして」と依頼し、次回以降の作業を定型化する。

## 実務上の要点

- 無音カットは、言い直し、不要語、構成判断までは自動では処理しない。まず作業量を減らし、その後に人間が編集判断をする前提で使う。
- テロップ生成は省力化できるが、改行位置、文字量、表記ゆれ、演出上の間は最終確認が必要。
- XML、WAV、SRTという中間ファイルを使うため、大容量の動画本体をGitに入れずに運用できる。
- 配布スキルや外部ツールは便利だが、このリポジトリでは外部コードの実行やインストールを自動では行わない。導入前にZip検査、GitHubレビュー、権限、保存先を確認する。

## このVaultでの扱い

- 既存のAI動画制作ノートとは関連するが、今回は生成AI動画ではなく、Premiere Pro編集工程の自動化が主題なので独立要約として残す。
- `ObsidianSecondBrain` では、動画本体や作業ファイルはDrive側、軽量索引と判断メモだけGit側に置く。
- 関連:
  - [[reports/source-summaries/2026-07-03-youtube-ai動画制作sjinn-skills|AI動画制作 / SJinn Skills 要約]]
  - [[reports/source-summaries/2026-07-04-youtube-codex-workflows-batch|2026-07-04 YouTube追加分 / Codexワークフロー横断要約]]
  - [[reports/source-summaries/2026-07-09-youtube-ai-music-video-workflow|AIで一発撮り風ミュージックビデオを作る手順]]
- 元索引: [[raw/webclip-index/2026-07-09-youtube-2026年最新版-codexで動画編集を自動化-インストールから書き出しまで全部解説|元動画索引]]

## 注意点

- 動画内のCodex、ChatGPT、外部スキル、Whisper、Premiere Proまわりの料金や仕様は変わりやすい。導入時には公式情報または配布元の最新情報を確認する。
- 「フルアクセス」「毎回許可しない」系の操作は、信頼できるローカル作業フォルダと検査済みスキルに限定する。
