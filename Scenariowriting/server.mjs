import {createServer} from "node:http";
import {mkdir, readFile, writeFile} from "node:fs/promises";
import {extname, join, normalize} from "node:path";
import {fileURLToPath} from "node:url";

const port = Number(process.env.PORT || 4174);
const modelFallback = process.env.OPENAI_MODEL || "gpt-5-mini";
const costCapUsd = Number(process.env.OPENAI_COST_CAP_USD || "1");
const maxOutputTokensCap = Number(process.env.OPENAI_MAX_OUTPUT_TOKENS || "2600");
const apiKey = process.env.OPENAI_API_KEY;
const root = fileURLToPath(new URL("./public/", import.meta.url));
const dataDir = fileURLToPath(new URL("./data/", import.meta.url));
const scriptProjectsDir = fileURLToPath(new URL("./script-projects/", import.meta.url));
const usageFile = join(dataDir, "usage.json");

const contentTypes = {
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
};

const stepLabels = {
  knowledge: "基礎知識",
  intent: "検索意図",
  audienceInsight: "視聴者理解",
  outline: "目次構成",
  synopsis: "あらすじ",
  synopsisReview: "あらすじ修正",
  preflight: "台本前チェック",
  introEnding: "冒頭・エンディング",
  body: "本文",
  transcriptCleanup: "書き起こし整形",
  rewriteAnalysis: "対話化設計",
  rewriteSynopsis: "リライトあらすじ",
  rewriteSynopsisReview: "リライトあらすじ修正",
  dialogueRewrite: "対話リライト",
};

const stepTokenLimits = {
  knowledge: 1200,
  intent: 1000,
  audienceInsight: 1200,
  outline: 1700,
  synopsis: 1200,
  synopsisReview: 1200,
  preflight: 1500,
  introEnding: 1400,
  body: 2600,
  transcriptCleanup: 2200,
  rewriteAnalysis: 1500,
  rewriteSynopsis: 1200,
  rewriteSynopsisReview: 1200,
  dialogueRewrite: 3000,
};

const modelPrices = {
  "gpt-5-mini": {input: 0.25, output: 2},
  "gpt-5-nano": {input: 0.05, output: 0.4},
};

const compact = (value) => String(value || "").trim();
const safeSegment = (value, fallback = "script") =>
  (compact(value) || fallback)
    .replace(/[<>:"/\\|?*\u0000-\u001f]/g, "_")
    .replace(/\s+/g, "_")
    .replace(/_+/g, "_")
    .slice(0, 80);
const optionLabel = (value, labels, fallback) => labels[compact(value)] || fallback;
const scriptTypeLabel = (value) =>
  optionLabel(value, {solo: "一人語り系", dialogue: "対談系"}, "一人語り系");

const scriptSettings = (fields) => {
  const targetLength = Math.max(800, Math.min(60000, Number(fields.targetLength) || 6000));
  const audience = compact(fields.audience) || "テーマの知識がない初心者";
  const channelName = compact(fields.channelName) || "チャンネル名未設定";
  const hostName = compact(fields.hostName) || "演者名未設定";
  const bodyLength = Math.max(600, Math.min(12000, Number(fields.bodyLength) || 2000));

  return `# 台本仕様
- 台本タイプ：${scriptTypeLabel(fields.scriptType)}
- チャンネル名：${channelName}
- メイン演者：${hostName}
- 想定視聴者：${audience}
- 台本全体の目標文字数：約${targetLength}文字
- 本文1回あたりの目安：${bodyLength}文字以上
- 動画トーン：${optionLabel(
    fields.videoTone,
    {
      beginner: "初心者にもわかりやすい",
      lively: "テンポよく親しみやすい",
      expert: "専門性があるが噛み砕く",
      dramatic: "問題提起を強めにする",
    },
    "初心者にもわかりやすい",
  )}`;
};

const characterSettings = (fields) => {
  if (fields.scriptType === "dialogue") {
    return `# キャラクター設定
- ${compact(fields.characterAName) || "キャラクターA"}：${compact(fields.characterARole) || "聞き役、視聴者目線で質問する"}。口調：${compact(fields.characterATone) || "自然でリアクションが多い"}
- ${compact(fields.characterBName) || "キャラクターB"}：${compact(fields.characterBRole) || "説明役、初心者にわかるように解説する"}。口調：${compact(fields.characterBTone) || "落ち着いてわかりやすい"}
- 二人の立場の違い：${compact(fields.relationship) || "Aは疑問を持つ初心者、Bは説明できる立場"}
- 会話ルール：専門用語が出たらAが質問し、Bが例えを使って補足する。同じ語尾を続けすぎない。`;
  }

  return `# キャラクター・口調設定
- 話者：${compact(fields.hostName) || "演者"}
- 話者の立場：${compact(fields.soloRole) || "視聴者の悩みに寄り添う解説者"}
- 口調：${compact(fields.soloTone) || "やさしく、わかりやすく、自然な話し言葉"}
- 話し方の注意：${compact(fields.soloRules) || "難しい言葉は言い換え、視聴維持のために問いかけを入れる"}${
    fields.soloSubCharacter === "yes"
      ? `

# サブキャラ設定
- サブキャラ名：${compact(fields.subCharacterName) || "サブキャラ"}
- サブキャラの役割：${compact(fields.subCharacterRole) || "視聴者の疑問を代弁する補助役"}
- サブキャラの口調：${compact(fields.subCharacterTone) || "親しみやすく、短くリアクションする"}
- 登場場面：${compact(fields.subCharacterScenes) || "専門用語、注意点、視聴者がつまずきそうな箇所"}
- 登場頻度：${compact(fields.subCharacterFrequency) || "各中見出しに1から2回まで。出しすぎない"}
- メイン話者との関係：${compact(fields.subCharacterRelationship) || "メイン話者に質問する初心者ポジション"}
- 使用目的：${compact(fields.subCharacterPurpose) || "難しい内容を噛み砕き、視聴者の離脱を防ぐ"}
- 運用ルール：基本はメイン話者の一人語りで進める。サブキャラは常時会話にせず、要所要所の質問、驚き、確認、注意喚起に限定する。`
      : `

# サブキャラ設定
- サブキャラは使わない。全編をメイン話者の一人語りとして書く。`
  }`;
};

const knowledgeSection = (fields) => `# NotebookLMで作成した基礎知識メモ
${fields.knowledgeMemo || "なし"}

# 参考動画
${fields.referenceVideos || "なし"}

# インポートした文献・資料
${fields.sourceMaterials || "なし"}`;
const roundUsd = (value) => Math.round(value * 1_000_000) / 1_000_000;
const priceForModel = (model) => modelPrices[model] || null;
const outputTokenLimit = (step) =>
  Math.max(1, Math.min(stepTokenLimits[step] || maxOutputTokensCap, maxOutputTokensCap));
const estimatedInputTokens = (prompt) =>
  Math.max(1, Math.ceil(`${prompt.instructions}\n${prompt.input}`.length / 2));
const tokenCostUsd = (model, inputTokens, outputTokens) => {
  const price = priceForModel(model);
  if (!price) {
    throw new Error("費用計測対象外のモデルです。低コストモデルを選んでください。");
  }
  return roundUsd((inputTokens * price.input + outputTokens * price.output) / 1_000_000);
};

const emptyUsage = () => ({
  spentUsd: 0,
  requests: 0,
  inputTokens: 0,
  outputTokens: 0,
  updatedAt: null,
});

const readUsage = async () => {
  try {
    return {...emptyUsage(), ...JSON.parse(await readFile(usageFile, "utf8"))};
  } catch {
    return emptyUsage();
  }
};

const writeUsage = async (usage) => {
  await mkdir(dataDir, {recursive: true});
  await writeFile(usageFile, `${JSON.stringify(usage, null, 2)}\n`, "utf8");
};

const usageSummary = (usage) => ({
  ...usage,
  capUsd: costCapUsd,
  remainingUsd: roundUsd(Math.max(0, costCapUsd - usage.spentUsd)),
});

const promptBuilders = {
  knowledge: ({videoTitle, ...fields}) => ({
    target: "NotebookLM",
    instructions:
      "あなたは専門性の高いYouTube台本を作るためのリサーチ担当です。テーマに関係する信頼できる関連記事・資料をもとに、台本作成へ使える基礎知識メモを日本語で作成してください。",
    input: `「${videoTitle}」というテーマでYouTube台本を作成します。

${scriptSettings(fields)}

# インポートした文献・資料
${fields.sourceMaterials || "なし"}

# 参考動画
${fields.referenceVideos || "なし"}

# 調査の観点
- 視聴者が理解しておくべき前提知識
- 台本で誤解を招きやすい点
- 専門用語、制度、仕組み、注意点
- 一人語り、対話形式、対話リライトで触れると説得力が上がる論点
- 断定を避けるべき未確認情報

# 出力形式
基礎知識の要約
300から500文字程度

重要メモ
- 5から10項目

専門用語
- 用語：短い説明

注意点
- 台本化するときに注意すること

台本へ活かす観点
- 冒頭、目次、本文、対話化に反映したいこと`,
  }),
  intent: ({videoTitle, articleTitles, ...fields}) => ({
    instructions:
      "あなたはYouTube台本作成とSEOを理解しているプロの構成作家です。日本語で簡潔に出力してください。",
    input: `「${videoTitle}」というテーマでYouTube台本を作成します。

${scriptSettings(fields)}

${knowledgeSection(fields)}

# 参考にする検索上位記事タイトル
${articleTitles}

# 依頼
検索上位の記事タイトルを、検索するユーザーの目的ごとにグルーピングしてください。

# 条件
- 各グループの記事数を表示する
- 記事数が多い検索意図ほど重要度が高いものとして扱う
- YouTube視聴者の悩みとして言い換える
- 表のあとに、台本で優先すべき検索意図を a、b、c で保存しやすくまとめる

# 出力形式
検索意図グループ表
| 検索意図 | 記事数 | 該当タイトル | 視聴者の悩み |

検索意図保存用
a: ...
b: ...
c: ...
検索意図の重要度は a>b>c とする。`,
  }),
  audienceInsight: ({videoTitle, intent, ...fields}) => ({
    instructions:
      "あなたはYouTube視聴者の悩みを整理するプロの構成作家です。台本作成に使いやすい形で、日本語で簡潔に出力してください。",
    input: `「${videoTitle}」というテーマでYouTube台本を作成します。

${scriptSettings(fields)}

${characterSettings(fields)}

${knowledgeSection(fields)}

# ユーザーの検索意図
${intent}

# 依頼
検索意図をもとに、動画を見る視聴者像とニーズを整理してください。

# 条件
- Web記事の読者ではなく、YouTubeで動画を見る人として考える
- 冒頭30秒で刺さる不安や疑問を明確にする
- 顕在ニーズは視聴者が自覚している悩みにする
- 潜在ニーズは視聴者がまだ言語化できていない本音にする
- 台本の構成、あらすじ、冒頭、本文でそのまま使える表現にする
- 根拠が未確認の属性は断定しすぎない

# 出力形式
ペルソナ
- 年齢・性別・状況：
- 知識レベル：
- 視聴前の悩み：
- 動画に期待していること：

顕在ニーズ
1. ...
2. ...
3. ...

潜在ニーズ
1. ...
2. ...
3. ...

冒頭で刺す不安・疑問
- ...
- ...
- ...

視聴後の理想状態
100文字程度`,
  }),
  outline: ({videoTitle, intent, audienceInsight, competitorOutlines, ...fields}) => ({
    instructions:
      "あなたはYouTube台本の構成作家です。検索意図と競合構成を踏まえ、動画台本の目次構成だけを日本語で出力してください。",
    input: `「${videoTitle}」という動画台本の目次構成を作成してください。

${scriptSettings(fields)}

${knowledgeSection(fields)}

# ユーザーの検索意図
${intent}

# ペルソナ・顕在ニーズ・潜在ニーズ
${audienceInsight}

# 検索上位記事の目次構成
${competitorOutlines}

# 条件
- 重複や似た見出しは統合する
- 検索意図の重要度に沿って、視聴者が知りたい順番に並べる
- 初心者にもわかる流れにする
- 関連性の高い中見出しと小見出しを並べる
- 固有の会社名、商品名、サービス名に依存する見出しは避ける
- 冒頭とエンディングは含めず、本編の目次だけを出力する
- h2、h3 ではなく「中見出し」「小見出し」の表記にする

# 出力形式
中見出し：見出し
小見出し：見出し
小見出し：見出し

中見出し：見出し`,
  }),
  synopsis: ({videoTitle, intent, audienceInsight, outline, ...fields}) => ({
    instructions:
      "あなたはYouTube台本の流れを整理する構成作家です。後続の台本作成で内容がぶれないためのあらすじだけを日本語で出力してください。",
    input: `「${videoTitle}」の台本構成をもとに、動画全体のあらすじを作成してください。

${scriptSettings(fields)}

${characterSettings(fields)}

${knowledgeSection(fields)}

# ユーザーの検索意図
${intent}

# ペルソナ・顕在ニーズ・潜在ニーズ
${audienceInsight}

# 台本全体の目次構成
${outline}

# 条件
- 視聴者の悩み、問題の拡大、解決策、結論までの流れを固定する
- 一人語り系なら話者の口調がぶれないようにする
- 対談系なら二人の立場の違いと会話の役割がぶれないようにする
- 各中見出しで何を伝えるかを短く固定する
- 構成にない論点を勝手に増やしすぎない
- 根拠が未確認の断定は避ける

# 出力形式
動画の中心メッセージ
100文字程度

動画全体のあらすじ
300から500文字程度

キャラクター運用メモ
100から200文字程度

見出しごとの役割
- 中見出し：見出し名
  伝えること：80文字程度`,
  }),
  synopsisReview: ({
    videoTitle,
    intent,
    audienceInsight,
    outline,
    synopsis,
    synopsisRevisionNote,
    ...fields
  }) => ({
    instructions:
      "あなたはYouTube台本の流れを整理する構成作家です。既存のあらすじを修正指示に沿って改善し、採用できる完成版だけを日本語で出力してください。",
    input: `「${videoTitle}」の台本あらすじを修正してください。

${scriptSettings(fields)}

${characterSettings(fields)}

${knowledgeSection(fields)}

# ユーザーの検索意図
${intent}

# ペルソナ・顕在ニーズ・潜在ニーズ
${audienceInsight}

# 台本全体の目次構成
${outline}

# 現在のあらすじ
${synopsis}

# 修正したい点
${synopsisRevisionNote || "内容の流れ、口調、キャラクター設定がぶれないように整える"}

# 条件
- 構成と検索意図から外れない
- キャラクターの口調と立場の違いを明確にする
- 修正理由や解説は出力せず、修正後の完成版だけを出力する

# 出力形式
動画の中心メッセージ
100文字程度

動画全体のあらすじ
300から500文字程度

キャラクター運用メモ
100から200文字程度

見出しごとの役割
- 中見出し：見出し名
  伝えること：80文字程度`,
  }),
  preflight: ({videoTitle, intent, audienceInsight, outline, synopsis, rewriteAnalysis, rewriteSynopsis, cleanedTranscript, ...fields}) => ({
    instructions:
      "あなたはYouTube台本の執筆前チェッカーです。本文や対話リライトを書く前に、動画タイトル、構成、あらすじ、話者設計の整合性を確認し、執筆で迷わないための設計メモだけを日本語で出力してください。",
    input: `「${videoTitle}」の台本について、執筆前チェックを行ってください。

${scriptSettings(fields)}

${characterSettings(fields)}

${knowledgeSection(fields)}

# ユーザーの検索意図
${intent || "なし"}

# ペルソナ・顕在ニーズ・潜在ニーズ
${audienceInsight || "なし"}

# 台本全体の目次構成
${outline || "なし"}

# 採用済みあらすじ
${synopsis || "なし"}

# 対話化設計
${rewriteAnalysis || "なし"}

# 採用済みリライトあらすじ
${rewriteSynopsis || "なし"}

# 整形済み一人語りセリフ
${cleanedTranscript || "なし"}

# チェック観点
1. 動画タイトルの約束
   - タイトルに含まれる数字、理由、手順、注意点、初心者向け、比較などの約束が台本で回収できるか確認する
   - 回収できない場合は、タイトル修正案または構成修正案を出す
2. 導入と結論の対応
   - 冒頭で立てる疑問や不安が、本文とエンディングで回収されるか確認する
3. 中見出しごとの役割
   - 各中見出しについて「話すこと」「話さないこと」「視聴者に残す一文」を明確にする
   - 隣接する中見出しとの重複、抜け漏れ、境界の曖昧さを指摘する
4. 話者・キャラクターの役割
   - 一人語りなら話者の立場と口調が一貫しているか確認する
   - 対談系なら聞き役と説明役の役割がぶれていないか確認する
5. 対話リライトの保持
   - 一人語りから対話形式へ変換する場合、元セリフの主張、順番、具体例が薄まらないか確認する

# 出力形式
台本前チェック結果
- 判定：OK / 修正推奨
- 修正が必要な点：
- タイトル修正案：
- 構成修正案：

中見出しごとの執筆メモ
- 中見出し：見出し名
  話すこと：
  話さないこと：
  視聴者に残す一文：
  話者・キャラの使い方：

冒頭・エンディング設計
- 冒頭で立てる問い：
- 本文で回収する流れ：
- エンディングで振り返る要素：
- 入れないこと：

対話リライト注意点
- 元セリフから保持すること：
- 追加しないこと：
- キャラの役割分担：`,
  }),
  introEnding: ({videoTitle, intent, audienceInsight, outline, synopsis, preflightCheck, ...fields}) => ({
    instructions:
      "あなたはYouTube台本に強いプロのライターです。指定された形式に合わせて、冒頭とエンディングだけを日本語で出力してください。",
    input: `「${videoTitle}」という動画タイトルでYouTube台本を書きます。

${scriptSettings(fields)}

${characterSettings(fields)}

${knowledgeSection(fields)}

# ユーザーの検索意図
${intent}

# ペルソナ・顕在ニーズ・潜在ニーズ
${audienceInsight}

# 台本全体の目次構成
${outline}

# 採用済みあらすじ
${synopsis}

# 台本前チェック結果
${preflightCheck || "なし"}

# 作成するもの
イントロダクションとエンディング

# 条件
- 冒頭ではタイトルコール、問題の特定、問題の拡大、解決策の提案、視聴促進、チャンネル登録誘導を入れる
- エンディングでは動画の要約、チャンネル登録誘導、コメント促進を入れる
- 一人語り系はメイン話者が画面に向かって自然に話す。サブキャラ設定がある場合だけ、要所で短く登場させる
- 対談系は二人の会話で進め、キャラクター名を行頭に付ける
- 冒頭とエンディングはそれぞれ150から300文字程度を目安にする
- あらすじから結論や流れが外れないようにする
- 台本前チェック結果に冒頭・エンディング設計がある場合は、それを優先して問いと回収を対応させる

# 出力形式
## イントロダクション
台本

## エンディング
台本`,
  }),
  body: ({
    videoTitle,
    intent,
    audienceInsight,
    outline,
    synopsis,
    preflightCheck,
    bodyHeadings,
    bodyLength,
    evidenceRules,
    extraRules,
    ...fields
  }) => ({
    instructions:
      "あなたはYouTube台本に強いプロのライターです。指定された見出し部分の本文台本だけを日本語で出力してください。",
    input: `「${videoTitle}」という動画タイトルでYouTube台本を書きます。

${scriptSettings({...fields, bodyLength})}

${characterSettings(fields)}

${knowledgeSection(fields)}

# ユーザーの検索意図
${intent}

# ペルソナ・顕在ニーズ・潜在ニーズ
${audienceInsight}

# 台本全体の目次構成
${outline}

# 採用済みあらすじ
${synopsis}

# 台本前チェック結果
${preflightCheck || "なし"}

# 出力したい目次箇所
${bodyHeadings}

# 根拠・データの扱い
${evidenceRules || "国、公共団体、研究機関など信頼できる根拠がある場合のみ自然に触れる。未確認の数字は断定しない。"}

# 追加ルール
${extraRules || "なし"}

# 条件
- YouTube台本の途中箇所なので、イントロダクションやエンディングは出力しない
- 出力したい目次箇所の文字数は${Math.max(600, Number(bodyLength) || 2000)}文字以上を目安にする
- 結論、理由や根拠、具体例、結論の流れを基本にする
- 「結論」「理由」「具体例」というサブタイトルは、自然な接続詞や話し言葉に置き換える
- 一人語り系はメイン話者が画面に向かって解説する。サブキャラ設定がある場合だけ、専門用語、注意点、視聴者が疑問に思いそうな箇所で短く登場させる
- 対談系は二人の会話で進め、キャラクター名を行頭に付ける
- 初心者でも理解できるように、専門用語は短く言い換える
- 採用済みあらすじから主張や流れが外れないようにする
- 台本前チェック結果がある場合は、各中見出しの「話すこと」「話さないこと」「視聴者に残す一文」を守る
- 同じ語尾を続けすぎない

# 出力形式
中見出し：見出し
台本
小見出し：見出し
台本`,
  }),
  transcriptCleanup: ({videoTitle, transcriptVideoUrls, rawTranscript, transcriptRules, ...fields}) => ({
    instructions:
      "あなたはYouTube台本の書き起こしを整える編集者です。元の意味を変えず、後続のリライトに使える日本語台本へ整形してください。",
    input: `「${videoTitle}」の一人語り系YouTubeセリフを書き起こしから整形します。

${scriptSettings(fields)}

${knowledgeSection(fields)}

# YouTube元動画URL
${transcriptVideoUrls || "なし"}

# 元の書き起こし
${rawTranscript || "なし"}

# 整形ルール
${transcriptRules || "えー、あの、重複、言い直し、不要な相づちは整理する。ただし話の順番、主張、具体例、重要な表現は勝手に変えない。"}

# 条件
- YouTube元動画URLがあり、字幕や文字起こしを参照できる場合は、その内容をもとに整形する
- URLだけで字幕や文字起こしを確認できない場合は、確認できない旨を出力し、元の書き起こし欄の内容を優先する
- 一人語りの内容として読めるように段落を整える
- 意味を変える要約や大幅な補足はしない
- 聞き取りが怪しい箇所は「[要確認: ...]」と残す
- 後で対話形式に分割しやすいように、話題ごとに見出しを付ける
- 固有名詞や数字は、元の書き起こしにないものを追加しない

# 出力形式
## 整形済み一人語りセリフ
見出し
本文

## 要確認箇所
- ...`,
  }),
  rewriteAnalysis: ({videoTitle, cleanedTranscript, rewriteGoal, ...fields}) => ({
    instructions:
      "あなたは一人語り台本を二人語り台本へ変換する構成作家です。リライト前の設計だけを日本語で出力してください。",
    input: `「${videoTitle}」の一人語りセリフを、二人語りの対話形式へリライトします。

${scriptSettings({...fields, scriptType: "dialogue"})}

${characterSettings({...fields, scriptType: "dialogue"})}

${knowledgeSection(fields)}

# 整形済み一人語りセリフ
${cleanedTranscript}

# リライト目的
${rewriteGoal || "一人語りの情報量と主張を保ちながら、二人の会話でわかりやすく、視聴維持しやすい台本にする。"}

# 依頼
元セリフを分析し、対話形式へリライトするための設計を作成してください。

# 条件
- 元セリフの主張、順番、具体例をできるだけ保つ
- 視聴者の検索意図、ペルソナ、顕在ニーズ、潜在ニーズを推定する
- 二人の役割分担を明確にする
- どこで質問、リアクション、補足、注意喚起を入れるか決める
- 元セリフにない事実や数字を追加しない

# 出力形式
動画テーマ
...

推定される検索意図
a: ...
b: ...
c: ...
検索意図の重要度は a>b>c とする。

ペルソナ・ニーズ
- ペルソナ：
- 顕在ニーズ：
- 潜在ニーズ：
- 視聴後の理想状態：

対話化の方針
- ${compact(fields.characterAName) || "キャラクターA"}の役割：
- ${compact(fields.characterBName) || "キャラクターB"}の役割：
- 質問を入れる場面：
- リアクションを入れる場面：
- 補足を入れる場面：

対話用の目次構成
中見出し：...
小見出し：...`,
  }),
  rewriteSynopsis: ({
    videoTitle,
    cleanedTranscript,
    rewriteAnalysis,
    ...fields
  }) => ({
    instructions:
      "あなたは二人語り台本の流れを整理する構成作家です。リライト本文の前に確認するあらすじだけを日本語で出力してください。",
    input: `「${videoTitle}」の一人語りセリフを、二人語り台本へリライトする前のあらすじを作成してください。

${scriptSettings({...fields, scriptType: "dialogue"})}

${characterSettings({...fields, scriptType: "dialogue"})}

${knowledgeSection(fields)}

# 整形済み一人語りセリフ
${cleanedTranscript}

# 対話化設計
${rewriteAnalysis}

# 条件
- 元セリフの主張、順番、具体例を保つ
- 二人の立場の違い、質問の入れ方、解説の流れを固定する
- リライト本文で脱線しないように中心メッセージを明確にする
- 元セリフにない事実や数字を追加しない

# 出力形式
中心メッセージ
100文字程度

リライト全体のあらすじ
300から500文字程度

キャラクター運用メモ
100から200文字程度

見出しごとの役割
- 中見出し：見出し名
  伝えること：80文字程度`,
  }),
  rewriteSynopsisReview: ({
    videoTitle,
    cleanedTranscript,
    rewriteAnalysis,
    rewriteSynopsis,
    rewriteSynopsisRevisionNote,
    ...fields
  }) => ({
    instructions:
      "あなたは二人語り台本の流れを整理する構成作家です。既存のリライトあらすじを修正指示に沿って改善し、完成版だけを日本語で出力してください。",
    input: `「${videoTitle}」の二人語りリライト用あらすじを修正してください。

${scriptSettings({...fields, scriptType: "dialogue"})}

${characterSettings({...fields, scriptType: "dialogue"})}

${knowledgeSection(fields)}

# 整形済み一人語りセリフ
${cleanedTranscript}

# 対話化設計
${rewriteAnalysis}

# 現在のあらすじ
${rewriteSynopsis}

# 修正したい点
${rewriteSynopsisRevisionNote || "元セリフから外れず、二人の役割が明確になるように整える"}

# 条件
- 修正理由や解説は出力しない
- 元セリフにない事実や数字を追加しない
- キャラクターの口調と立場の違いを明確にする

# 出力形式
中心メッセージ
100文字程度

リライト全体のあらすじ
300から500文字程度

キャラクター運用メモ
100から200文字程度

見出しごとの役割
- 中見出し：見出し名
  伝えること：80文字程度`,
  }),
  dialogueRewrite: ({
    videoTitle,
    cleanedTranscript,
    rewriteAnalysis,
    rewriteSynopsis,
    preflightCheck,
    rewriteSourceRange,
    rewriteExtraRules,
    ...fields
  }) => ({
    instructions:
      "あなたは一人語り台本を二人語り台本へリライトするプロのライターです。指定範囲の対話形式台本だけを日本語で出力してください。",
    input: `「${videoTitle}」の一人語りセリフを、二人語りの対話形式へリライトしてください。

${scriptSettings({...fields, scriptType: "dialogue"})}

${characterSettings({...fields, scriptType: "dialogue"})}

${knowledgeSection(fields)}

# 整形済み一人語りセリフ
${cleanedTranscript}

# 対話化設計
${rewriteAnalysis}

# 採用済みリライトあらすじ
${rewriteSynopsis}

# 台本前チェック結果
${preflightCheck || "なし"}

# 今回リライトしたい範囲
${rewriteSourceRange || "整形済み一人語りセリフ全体"}

# 追加ルール
${rewriteExtraRules || "なし"}

# 条件
- 元セリフの主張、順番、具体例、重要な表現をできるだけ保つ
- 二人の会話で進め、キャラクター名を行頭に付ける
- 聞き役は視聴者の疑問、驚き、不安を代弁する
- 説明役は初心者にもわかるように噛み砕いて説明する
- 質問と回答を増やしすぎず、テンポよく進める
- 元セリフにない事実、数字、固有名詞は追加しない
- イントロやエンディングが範囲外なら出力しない
- あらすじと対話化設計から外れない
- 台本前チェック結果がある場合は、対話リライト注意点とキャラの役割分担を守る

# 出力形式
中見出し：見出し
${compact(fields.characterAName) || "キャラクターA"}：セリフ
${compact(fields.characterBName) || "キャラクターB"}：セリフ`,
  }),
};

const requiredFields = {
  knowledge: ["videoTitle"],
  intent: ["videoTitle", "articleTitles"],
  audienceInsight: ["videoTitle", "intent"],
  outline: ["videoTitle", "intent", "audienceInsight", "competitorOutlines"],
  synopsis: ["videoTitle", "intent", "audienceInsight", "outline"],
  synopsisReview: ["videoTitle", "intent", "audienceInsight", "outline", "synopsis"],
  preflight: ["videoTitle"],
  introEnding: ["videoTitle", "intent", "audienceInsight", "outline", "synopsis"],
  body: ["videoTitle", "intent", "audienceInsight", "outline", "synopsis", "bodyHeadings"],
  transcriptCleanup: ["videoTitle"],
  rewriteAnalysis: ["videoTitle", "cleanedTranscript"],
  rewriteSynopsis: ["videoTitle", "cleanedTranscript", "rewriteAnalysis"],
  rewriteSynopsisReview: ["videoTitle", "cleanedTranscript", "rewriteAnalysis", "rewriteSynopsis"],
  dialogueRewrite: ["videoTitle", "cleanedTranscript", "rewriteAnalysis", "rewriteSynopsis"],
};

const buildPromptText = (step, fields) => {
  const missing = requiredFields[step].filter((field) => !compact(fields[field]));
  if (missing.length) {
    throw new Error(`未入力の項目があります: ${missing.join(", ")}`);
  }

  const prompt = promptBuilders[step](fields);
  const target = prompt.target || "ChatGPT";
  return `# ${target}への依頼
${prompt.instructions}

# 入力
${prompt.input}`;
};

const json = (response, status, payload) => {
  response.writeHead(status, {"Content-Type": "application/json; charset=utf-8"});
  response.end(JSON.stringify(payload));
};

const parseBody = async (request) => {
  let body = "";
  for await (const chunk of request) {
    body += chunk;
    if (body.length > 1_000_000) {
      throw new Error("入力が大きすぎます。");
    }
  }
  return JSON.parse(body || "{}");
};

const getOutputText = (payload) =>
  payload.output_text ||
  payload.output
    ?.flatMap((item) => item.content || [])
    .filter((item) => item.type === "output_text")
    .map((item) => item.text)
    .join("\n")
    .trim();

const generate = async (step, fields, model) => {
  const prompt = promptBuilders[step](fields);
  buildPromptText(step, fields);
  const selectedModel = compact(model) || modelFallback;
  const estimatedCostUsd = tokenCostUsd(
    selectedModel,
    estimatedInputTokens(prompt),
    outputTokenLimit(step),
  );
  const usageBefore = await readUsage();

  if (usageBefore.spentUsd + estimatedCostUsd > costCapUsd) {
    throw new Error(
      `費用上限に近いため停止しました。残り上限 $${usageSummary(usageBefore).remainingUsd.toFixed(4)} ではこの生成を開始できません。`,
    );
  }

  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: selectedModel,
      instructions: prompt.instructions,
      input: prompt.input,
      max_output_tokens: outputTokenLimit(step),
    }),
  });
  const payload = await response.json();

  if (!response.ok) {
    throw new Error(payload.error?.message || "OpenAI API の呼び出しに失敗しました。");
  }

  const output = getOutputText(payload);
  if (!output) {
    throw new Error("生成結果を取得できませんでした。");
  }

  const inputTokens = Number(payload.usage?.input_tokens || 0);
  const outputTokens = Number(payload.usage?.output_tokens || 0);
  const actualCostUsd = tokenCostUsd(selectedModel, inputTokens, outputTokens);
  const usageAfter = {
    spentUsd: roundUsd(usageBefore.spentUsd + actualCostUsd),
    requests: usageBefore.requests + 1,
    inputTokens: usageBefore.inputTokens + inputTokens,
    outputTokens: usageBefore.outputTokens + outputTokens,
    updatedAt: new Date().toISOString(),
  };
  await writeUsage(usageAfter);

  return {
    output,
    model: selectedModel,
    outputTokenLimit: outputTokenLimit(step),
    requestCostUsd: actualCostUsd,
    usage: usageSummary(usageAfter),
  };
};

const saveScriptProject = async (fields, draftMarkdown) => {
  const now = new Date();
  const stamp = now.toISOString().replace(/[-:]/g, "").replace(/\.\d{3}Z$/, "Z");
  const projectName = `${safeSegment(fields.videoTitle, "script")}_${stamp}`;
  const projectDir = join(scriptProjectsDir, projectName);
  const synopsis = compact(fields.approvedSynopsis) || compact(fields.synopsis) || compact(fields.synopsisOutput);
  const rewriteSynopsis =
    compact(fields.approvedRewriteSynopsis) ||
    compact(fields.rewriteSynopsis) ||
    compact(fields.rewriteSynopsisOutput);
  const scriptPlan = {
    videoTitle: compact(fields.videoTitle),
    scriptType: compact(fields.scriptType),
    channelName: compact(fields.channelName),
    hostName: compact(fields.hostName),
    audience: compact(fields.audience),
    targetLength: compact(fields.targetLength),
    bodyLength: compact(fields.bodyLength),
    videoTone: compact(fields.videoTone),
    createdAt: now.toISOString(),
  };
  const characterPlan = {
    solo: {
      soloRole: compact(fields.soloRole),
      soloTone: compact(fields.soloTone),
      soloRules: compact(fields.soloRules),
      soloSubCharacter: compact(fields.soloSubCharacter),
      subCharacterName: compact(fields.subCharacterName),
      subCharacterRole: compact(fields.subCharacterRole),
      subCharacterTone: compact(fields.subCharacterTone),
      subCharacterScenes: compact(fields.subCharacterScenes),
      subCharacterFrequency: compact(fields.subCharacterFrequency),
      subCharacterRelationship: compact(fields.subCharacterRelationship),
      subCharacterPurpose: compact(fields.subCharacterPurpose),
    },
    dialogue: {
      characterAName: compact(fields.characterAName),
      characterARole: compact(fields.characterARole),
      characterATone: compact(fields.characterATone),
      characterBName: compact(fields.characterBName),
      characterBRole: compact(fields.characterBRole),
      characterBTone: compact(fields.characterBTone),
      relationship: compact(fields.relationship),
    },
  };
  const files = {
    "request.json": JSON.stringify(scriptPlan, null, 2),
    "characters.json": JSON.stringify(characterPlan, null, 2),
    "knowledge.md": `# NotebookLMで作成した基礎知識メモ\n\n${compact(fields.knowledgeMemo) || "なし"}\n\n# NotebookLM用リサーチセット\n\n${compact(fields.notebookResearchSet) || "なし"}\n`,
    "sources.md": `# インポートした文献・資料\n\n${compact(fields.sourceMaterials) || "なし"}\n`,
    "search-intent.md": `# 検索意図\n\n${compact(fields.intent) || "なし"}\n\n# 視聴者理解\n\n${compact(fields.audienceInsight) || "なし"}\n`,
    "serp-analysis.md": `# 検索上位記事の目次構成\n\n${compact(fields.competitorOutlines) || "なし"}\n`,
    "outline.md": `# 目次構成\n\n${compact(fields.outline) || "なし"}\n`,
    "synopsis.md": `# 採用あらすじ\n\n${synopsis || "なし"}\n\n# あらすじ修正メモ\n\n${compact(fields.synopsisRevisionNote) || "なし"}\n`,
    "preflight-check.md": `# 台本前チェック結果\n\n${compact(fields.preflightCheck) || "なし"}\n`,
    "intro-ending.md": `# 冒頭・エンディング\n\n${compact(fields.introEndingOutput) || "なし"}\n`,
    "body.md": `# 本文\n\n${compact(fields.bodyDraft) || "なし"}\n`,
    "transcript.md": `# 元の書き起こし\n\n${compact(fields.rawTranscript) || "なし"}\n\n# 整形ルール\n\n${compact(fields.transcriptRules) || "なし"}\n\n# 整形済み一人語りセリフ\n\n${compact(fields.cleanedTranscript) || "なし"}\n`,
    "rewrite-analysis.md": `# リライト目的\n\n${compact(fields.rewriteGoal) || "なし"}\n\n# 対話化設計\n\n${compact(fields.rewriteAnalysis) || "なし"}\n`,
    "rewrite-synopsis.md": `# 採用リライトあらすじ\n\n${rewriteSynopsis || "なし"}\n\n# リライトあらすじ修正メモ\n\n${compact(fields.rewriteSynopsisRevisionNote) || "なし"}\n`,
    "dialogue-rewrite.md": `# 今回リライトしたい範囲\n\n${compact(fields.rewriteSourceRange) || "なし"}\n\n# 追加ルール\n\n${compact(fields.rewriteExtraRules) || "なし"}\n\n# 対話リライト結果\n\n${compact(fields.dialogueRewriteDraft) || "なし"}\n`,
    "draft.md": compact(draftMarkdown) || "まだ下書きはありません。",
    "review.json": JSON.stringify(
      {
        status: "not_reviewed",
        notes: [],
        createdAt: now.toISOString(),
      },
      null,
      2,
    ),
    "README.md": `# ${compact(fields.videoTitle) || "script"}\n\nこのフォルダーは Scenariowriting から保存した台本プロジェクトです。\n\n## 主なファイル\n\n- request.json: 入力条件\n- characters.json: キャラクター設定\n- knowledge.md: NotebookLMメモとリサーチセット\n- sources.md: 文献・資料\n- search-intent.md: 検索意図と視聴者理解\n- serp-analysis.md: 検索上位記事の目次構成\n- outline.md: 台本目次\n- synopsis.md: 採用あらすじ\n- preflight-check.md: 台本前チェック\n- intro-ending.md: 冒頭・エンディング\n- body.md: 本文\n- transcript.md: 書き起こし整形\n- rewrite-analysis.md: 対話化設計\n- rewrite-synopsis.md: 採用リライトあらすじ\n- dialogue-rewrite.md: 対話リライト\n- draft.md: 台本下書き\n- review.json: レビュー結果の保存先\n`,
  };

  await mkdir(projectDir, {recursive: true});
  await Promise.all(
    Object.entries(files).map(([filename, content]) =>
      writeFile(join(projectDir, filename), `${content.trimEnd()}\n`, "utf8"),
    ),
  );

  return {projectName, projectDir, files: Object.keys(files)};
};

const serveAsset = async (request, response) => {
  const requestPath = new URL(request.url, `http://${request.headers.host}`).pathname;
  const relativePath = requestPath === "/" ? "index.html" : requestPath.slice(1);
  const safePath = normalize(relativePath).replace(/^(\.\.[/\\])+/, "");
  const assetPath = join(root, safePath);

  try {
    const asset = await readFile(assetPath);
    response.writeHead(200, {
      "Content-Type": contentTypes[extname(assetPath)] || "application/octet-stream",
    });
    response.end(asset);
  } catch {
    response.writeHead(404, {"Content-Type": "text/plain; charset=utf-8"});
    response.end("Not found");
  }
};

createServer(async (request, response) => {
  if (request.method === "GET" && request.url === "/api/health") {
    json(response, 200, {
      ready: Boolean(apiKey),
      defaultModel: modelFallback,
      supportedModels: Object.keys(modelPrices),
      usage: usageSummary(await readUsage()),
    });
    return;
  }

  if (request.method === "POST" && request.url === "/api/generate") {
    if (!apiKey) {
      json(response, 500, {
        error: "OPENAI_API_KEY が未設定です。サーバー起動時に環境変数へ設定してください。",
      });
      return;
    }

    try {
      const body = await parseBody(request);
      const step = compact(body.step);
      if (!promptBuilders[step]) {
        json(response, 400, {error: "生成ステップが不正です。"});
        return;
      }
      const generated = await generate(step, body.fields || {}, body.model);
      json(response, 200, {...generated, stepLabel: stepLabels[step]});
    } catch (error) {
      json(response, 400, {error: error.message || "生成に失敗しました。"});
    }
    return;
  }

  if (request.method === "POST" && request.url === "/api/prompt") {
    try {
      const body = await parseBody(request);
      const step = compact(body.step);
      if (!promptBuilders[step]) {
        json(response, 400, {error: "プロンプト作成ステップが不正です。"});
        return;
      }
      json(response, 200, {
        prompt: buildPromptText(step, body.fields || {}),
        stepLabel: stepLabels[step],
      });
    } catch (error) {
      json(response, 400, {error: error.message || "プロンプト作成に失敗しました。"});
    }
    return;
  }

  if (request.method === "POST" && request.url === "/api/project/save") {
    try {
      const body = await parseBody(request);
      json(response, 200, await saveScriptProject(body.fields || {}, body.draftMarkdown || ""));
    } catch (error) {
      json(response, 400, {error: error.message || "プロジェクト保存に失敗しました。"});
    }
    return;
  }

  if (request.method === "GET") {
    await serveAsset(request, response);
    return;
  }

  response.writeHead(405, {"Content-Type": "text/plain; charset=utf-8"});
  response.end("Method not allowed");
}).listen(port, () => {
  console.log(`YouTube script workflow: http://localhost:${port}`);
});
