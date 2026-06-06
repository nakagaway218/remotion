import {createServer} from "node:http";
import {mkdir, readFile, writeFile} from "node:fs/promises";
import {extname, join, normalize} from "node:path";
import {fileURLToPath} from "node:url";

const port = Number(process.env.PORT || 4173);
const modelFallback = process.env.OPENAI_MODEL || "gpt-5-mini";
const costCapUsd = Number(process.env.OPENAI_COST_CAP_USD || "1");
const maxOutputTokensCap = Number(process.env.OPENAI_MAX_OUTPUT_TOKENS || "2400");
const apiKey = process.env.OPENAI_API_KEY;
const rakkoApiKey = process.env.RAKKO_API_KEY;
const rakkoApiUrl = "https://api.rakkokeyword.com/v1/headline";
const root = fileURLToPath(new URL("./public/", import.meta.url));
const dataDir = fileURLToPath(new URL("./data/", import.meta.url));
const articleProjectsDir = fileURLToPath(new URL("./article-projects/", import.meta.url));
const usageFile = join(dataDir, "usage.json");

const contentTypes = {
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
};

const stepLabels = {
  sourceDiscovery: "情報ソース候補",
  knowledge: "基礎知識",
  rakkoGpts: "ラッコGPTs連携",
  intent: "検索意図",
  outline: "構成",
  synopsis: "あらすじ",
  synopsisReview: "あらすじ修正",
  preflight: "本文前チェック",
  titles: "タイトル",
  lead: "リード文",
  body: "本文",
  summary: "まとめ文",
};

const stepTokenLimits = {
  sourceDiscovery: 1200,
  knowledge: 1200,
  rakkoGpts: 1200,
  intent: 1000,
  outline: 1700,
  synopsis: 1100,
  synopsisReview: 1100,
  preflight: 1400,
  titles: 900,
  lead: 550,
  body: 2200,
  summary: 850,
};

const modelPrices = {
  "gpt-5-mini": {input: 0.25, output: 2},
  "gpt-5-nano": {input: 0.05, output: 0.4},
};

const compact = (value) => String(value || "").trim();
const safeSegment = (value, fallback = "article") =>
  (compact(value) || fallback)
    .replace(/[<>:"/\\|?*\u0000-\u001f]/g, "_")
    .replace(/\s+/g, "_")
    .replace(/_+/g, "_")
    .slice(0, 80);
const optionLabel = (value, labels, fallback) => labels[compact(value)] || fallback;
const articleSettings = (fields) => {
  const targetLength = Math.max(800, Math.min(30000, Number(fields.targetLength) || 4000));
  const bodyAllocation = optionLabel(
    fields.bodyAllocation,
    {
      auto: "構成と検索意図に応じて自動配分",
      balanced: "h2ごとに本文量をおおむね均等配分",
      priority: "重要度が高い見出しを厚く配分",
      manual: "追加ルールに書かれた見出し別文字数を優先",
    },
    "構成と検索意図に応じて自動配分",
  );
  const articlePurpose = optionLabel(
    fields.articlePurpose,
    {
      "seo-blog": "SEOブログ",
      column: "コラム",
      comparison: "比較記事",
      experience: "体験談寄りの記事",
    },
    "SEOブログ",
  );
  const articleTone = optionLabel(
    fields.articleTone,
    {
      beginner: "初心者向け",
      gentle: "やさしい語り口",
      concise: "端的で読みやすい語り口",
      expert: "専門家向けだが読みやすい語り口",
    },
    "初心者向け",
  );

  return `# 記事仕様
- 用途：${articlePurpose}
- 目標文字数：記事全体で約${targetLength}文字
- 本文の分量配分：${bodyAllocation}
- トーン：${articleTone}`;
};
const knowledgeSection = (fields) => `# 重要情報ソースリスト
${fields.trustedSources || "なし"}

# NotebookLMで作成した基礎知識メモ
${fields.knowledgeMemo || "なし"}

# インポートした文献・資料
${fields.sourceMaterials || "なし"}`;
const roundUsd = (value) => Math.round(value * 1_000_000) / 1_000_000;
const priceForModel = (model) => modelPrices[model] || null;
const outputTokenLimit = (step) =>
  Math.max(1, Math.min(stepTokenLimits[step] || maxOutputTokensCap, maxOutputTokensCap));
const estimatedInputTokens = (prompt) =>
  Math.max(1, Math.ceil(`${prompt.instructions}\n${prompt.input}`.length));
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
  sourceDiscovery: ({keyword, ...fields}) => ({
    instructions:
      "あなたはWeb記事のリサーチ設計者です。NotebookLMに読み込ませるための、重要で信頼性の高い情報ソース候補を日本語で整理してください。",
    input: `「${keyword}」の記事を書く前に、NotebookLMへ読み込ませるべき重要情報ソースをリストアップしてください。

${articleSettings(fields)}

# 既にある文献・資料
${fields.sourceMaterials || "なし"}

# 検索上位記事の構成・URL
${fields.competitorOutlines || "なし"}

# 選定方針
- 公的機関、専門団体、学会、法律・制度の一次情報、メーカー公式、専門家監修ページなどを優先する
- 医療、美容、法律、金融、育児、教育など高い正確性が必要な分野では、古い情報や出典不明のまとめ記事を避ける
- SEO上位記事は参考にしてよいが、事実確認の根拠としては一次情報や専門性の高い資料を優先する
- NotebookLMに読み込ませる価値が低い広告ページ、商品一覧、口コミだけのページ、出典不明記事は除外する
- URLが不明な場合は、探すべき資料名や組織名を示す

# 出力形式
重要情報ソースリスト
- ソース名：
  URL：
  種別：公的機関 / 専門団体 / 一次情報 / 専門家解説 / その他
  信頼できる理由：
  記事で使う観点：
  NotebookLMへ読み込ませる優先度：高 / 中 / 低

除外した方がよいソース
- ソースの種類：
  理由：

追加で探すべきキーワード
- ...`,
  }),
  knowledge: ({keyword, ...fields}) => ({
    target: "NotebookLM",
    instructions:
      "あなたは専門性の高い記事を書くためのリサーチ担当です。キーワードに関係する信頼できる関連記事・資料をもとに、記事執筆へ使える基礎知識メモを日本語で作成してください。",
    input: `「${keyword}」について、関連記事や信頼できる資料を確認し、Web記事の執筆前に押さえるべき基礎知識を整理してください。

# インポートした文献・資料
${fields.sourceMaterials || "なし"}

# 重要情報ソースリスト
${fields.trustedSources || "なし"}

# 調査の観点
- 読者が理解しておくべき前提知識
- 記事で誤解を招きやすい点
- 専門用語、制度、仕組み、注意点
- 記事内で触れると説得力が上がる論点
- 断定を避けるべき未確認情報

# 出力形式
基礎知識の要約
300から500文字程度

重要メモ
- 5から10項目

専門用語
- 用語：短い説明

注意点
- 執筆時に注意すること

記事へ活かす観点
- 構成や本文に反映したいこと`,
  }),
  rakkoGpts: ({keyword, ...fields}) => ({
    target: "ラッコキーワード連携GPTs",
    instructions:
      "あなたはラッコキーワードAPIと接続されたGPTsです。キーワードの検索上位記事から、SEO記事構成に使うh2/h3見出しだけを取得し、指定形式のJSONだけで返してください。",
    input: `「${keyword}」について、ラッコキーワードAPIの見出し抽出を使い、検索上位5記事のh2/h3を取得してください。

${articleSettings(fields)}

# API取得条件
- 対象キーワード：${keyword}
- 取得件数：上位5記事
- 見出し：h2、h3のみ
- h1、h4、h5、h6、本文文字数、不要な本文データは含めない
- 検索順位の昇順で並べる

# 除外する見出し
以下のような、記事本文ではないサイト共通パーツや回遊導線は除外してください。
- 関連記事、おすすめ記事、人気記事、新着記事、記事一覧
- カテゴリー、タグ、キーワード一覧、検索フォーム
- ランキング、商品一覧、買い物情報、ショッピングガイド
- SNSフォロー、メニュー、会社情報、アクセス、問い合わせ、資料請求
- ブランドサイト、キャンペーン、応募、参加

# 出力形式
説明文や補足は入れず、以下のJSONだけを返してください。

{
  "data": {
    "items": [
      {
        "metrics": {"position": 1},
        "page": {
          "title": "記事タイトル",
          "url": "https://example.com/article"
        },
        "headlines": [
          {"level": "h2", "text": "見出し"},
          {"level": "h3", "text": "見出し"}
        ]
      }
    ]
  }
}`,
  }),
  intent: ({keyword, ...fields}) => ({
    instructions:
      "あなたはSEOを十分に理解しているプロのWebライターです。日本語で簡潔に出力してください。",
    input: `「${keyword}」というキーワードでSEO記事を書きます。

${articleSettings(fields)}

${knowledgeSection(fields)}

このキーワードのペルソナ、顕在ニーズ、潜在ニーズを調査してください。

# 制約条件
- ペルソナには年齢、性別、年収、生活スタイルなどを含める
- 顕在ニーズと潜在ニーズはそれぞれ2つずつ書く
- 記号だけの見出しにはせず、読み返して使いやすい形にする

# 出力形式
ペルソナ
100文字程度

顕在ニーズ
1. 80文字程度
2. 80文字程度

潜在ニーズ
1. 80文字程度
2. 80文字程度`,
  }),
  outline: ({keyword, intent, competitorOutlines, ...fields}) => ({
    instructions:
      "あなたはSEOを十分に理解しているプロのWebライターです。検索意図と競合構成を踏まえ、記事構成だけを日本語で出力してください。",
    input: `「${keyword}」というキーワードの記事構成を作成してください。

# ペルソナ、顕在ニーズ、潜在ニーズ
${intent}

${articleSettings(fields)}

${knowledgeSection(fields)}

# 検索上位記事の構成
${competitorOutlines}

# 制約条件
- 上位記事の見出しをそのまま使わず、言い回しを変える
- 検索上位記事の構成には、記事本文ではないサイト共通パーツや回遊導線が含まれるため、以下は参考から除外する
- 除外対象：関連記事、おすすめ記事、人気記事、新着記事、記事一覧、カテゴリー、タグ、キーワード一覧、検索フォーム、ランキング、商品一覧、買い物情報、ショッピングガイド、SNSフォロー、メニュー、会社情報、アクセス、ブランドサイト、キャンペーン、応募、参加、問い合わせ、資料請求
- 顕在ニーズと潜在ニーズに応え、抜け、漏れ、重複を抑える
- 上位記事にはないオリジナルな見出しを最低1つ含める
- h2見出しには自然な形でキーワードを含める
- 読者がスムーズに読み進められる順番にする
- h3は親のh2に包含される内容にする
- 1つの見出しで伝えることは1つに絞る
- 最後の見出しは「h2：まとめ｜...」とし、キーワードを含めて行動喚起を促す
- 固有の会社名、商品名、サービス名の見出しは含めない
- h1タイトルは出力しない
- 目標文字数に対して見出し数が多すぎたり少なすぎたりしないようにする
- 出力前に制約条件とのずれを再確認する

# 出力形式
h2：見出し
h3：見出し
h3：見出し

h2：見出し`,
  }),
  synopsis: ({keyword, intent, outline, ...fields}) => ({
    instructions:
      "あなたは記事の主張と流れを整理する編集者です。後続の執筆で内容がぶれないためのあらすじだけを日本語で出力してください。",
    input: `「${keyword}」の記事構成をもとに、記事全体のあらすじを作成してください。

${articleSettings(fields)}

${knowledgeSection(fields)}

# ペルソナ、顕在ニーズ、潜在ニーズ
${intent}

# 記事構成
${outline}

# 制約条件
- 読者の悩みから記事の結論までの流れがわかるようにする
- 各h2で何を伝えるかを短く固定する
- 本文で主張がぶれないよう、記事全体の中心メッセージを明示する
- 構成にない論点を勝手に増やしすぎない
- 固有名詞や根拠が未確認の断定は避ける

# 出力形式
記事の中心メッセージ
100文字程度

記事全体のあらすじ
250から400文字程度

見出しごとの役割
- h2：見出し名
  伝えること：80文字程度`,
  }),
  synopsisReview: ({keyword, intent, outline, synopsis, synopsisRevisionNote, ...fields}) => ({
    instructions:
      "あなたは記事の主張と流れを整理する編集者です。既存のあらすじを修正指示に沿って改善し、採用できる完成版だけを日本語で出力してください。",
    input: `「${keyword}」の記事あらすじを修正してください。

${articleSettings(fields)}

${knowledgeSection(fields)}

# ペルソナ、顕在ニーズ、潜在ニーズ
${intent}

# 記事構成
${outline}

# 現在のあらすじ
${synopsis}

# 修正したい点
${synopsisRevisionNote || "現在のあらすじを確認し、記事内容がぶれないように必要な改善を行う"}

# 制約条件
- 構成と検索意図から外れない
- 記事の中心メッセージをより明確にする
- 各h2の役割が本文執筆時に迷わないようにする
- 修正理由や解説は出力せず、修正後の完成版だけを出力する
- 固有名詞や根拠が未確認の断定は避ける

# 出力形式
記事の中心メッセージ
100文字程度

記事全体のあらすじ
250から400文字程度

見出しごとの役割
- h2：見出し名
  伝えること：80文字程度`,
  }),
  preflight: ({keyword, intent, outline, synopsis, title, ...fields}) => ({
    instructions:
      "あなたはSEO記事の本文前チェッカーです。本文を書く前に、タイトル、構成、あらすじの整合性を確認し、本文執筆で迷わないための設計メモだけを日本語で出力してください。",
    input: `「${keyword}」の記事について、本文を書き始める前のチェックを行ってください。

# 採用タイトル
${title || "未定"}

${articleSettings(fields)}

${knowledgeSection(fields)}

# ペルソナ、顕在ニーズ、潜在ニーズ
${intent}

# 記事構成
${outline}

# 採用済みあらすじ
${synopsis}

# チェック観点
1. タイトルの約束
   - タイトルに含まれる数字、強い言葉、対象読者、注意点、比較、手順などの約束が構成と本文で回収できるか確認する
   - 回収できない場合は、タイトル修正案または構成修正案を出す
2. 見出しごとの役割
   - 各h2について「書くこと」「書かないこと」「読者に残す一文」を明確にする
   - 隣接h2との重複、抜け漏れ、境界の曖昧さを指摘する
3. まとめの設計
   - まとめで何を振り返り、どんな行動へつなげるかを先に決める
   - タイトルに数字や手順がある場合は、まとめで再提示すべき項目を明示する

# 出力形式
本文前チェック結果
- 判定：OK / 修正推奨
- 修正が必要な点：
- タイトル修正案：
- 構成修正案：

見出しごとの執筆メモ
- h2：見出し名
  書くこと：
  書かないこと：
  読者に残す一文：

まとめ設計
- 振り返る要素：
- 行動喚起：
- 入れないこと：`,
  }),
  titles: ({keyword, intent, outline, synopsis, ...fields}) => ({
    instructions:
      "あなたはSEOを十分に理解しているプロのWebライターです。タイトル案だけを日本語で出力してください。",
    input: `構成をもとに「${keyword}」というキーワードのSEO記事タイトル案を10個考えてください。

# ペルソナ、顕在ニーズ、潜在ニーズ
${intent}

${articleSettings(fields)}

${knowledgeSection(fields)}

# 構成
${outline}

# 記事のあらすじ
${synopsis}

# 制約条件
- タイトルは28から32文字を目安にする
- タイトルには必ずキーワードを含める
- 読者がクリックしたくなる内容にする
- 自然に入れられる場合は数字を含める

# 出力形式
1. タイトル
2. タイトル`,
  }),
  lead: ({keyword, intent, outline, synopsis, title, ...fields}) => ({
    instructions:
      "あなたは読者の不安をほどきながら記事へ案内するプロのライターです。リード文だけを日本語で出力してください。",
    input: `「${keyword}」の記事リード文を書いてください。

# 記事タイトル
${title}

${articleSettings(fields)}

${knowledgeSection(fields)}

# ペルソナ、顕在ニーズ、潜在ニーズ
${intent}

# 本文の構成
${outline}

# 記事のあらすじ
${synopsis}

# 制約条件
- 読者の悩みや課題への共感から入る
- 記事を読んで得られることを明示する
- 読了後の未来を示す
- 150から200文字を目安にする
- リード文だけを出力する`,
  }),
  body: ({keyword, intent, outline, synopsis, preflightCheck, bodyHeadings, headingLengthPlan, extraRules, ...fields}) => ({
    instructions:
      "あなたはSEOを十分に理解しているプロのWebライターです。指定された見出しの本文だけを日本語で出力してください。",
    input: `「${keyword}」というキーワードの記事本文を書いてください。

# ペルソナ、顕在ニーズ、潜在ニーズ
${intent}

${articleSettings(fields)}

${knowledgeSection(fields)}

# 記事全体の構成
${outline}

# 記事のあらすじ
${synopsis}

# 本文前チェック結果
${preflightCheck || "なし"}

# 出力したい見出し
${bodyHeadings}

# 見出し別文字数指定
${headingLengthPlan || "指定なし"}

# 追加ルール
${extraRules || "なし"}

# 制約条件
- PREP法を基本にする。ただし「結論」「理由」などのラベルは出力しない
- PREP法が不自然な場合はわかりやすさを優先する
- 必要に応じてリスト、表、箇条書きを使う
- 敬体で出力する
- 記事の途中なのでリード文やまとめ文は出力しない
- 中学生でも理解できるわかりやすさにする
- 見出しに沿って書き、1見出しで伝えることは1つに絞る
- 記事のあらすじから主張や流れが外れないようにする
- 本文前チェック結果がある場合は、各h2の「書くこと」「書かないこと」「読者に残す一文」を守る
- 記事全体の目標文字数と分量配分を意識し、指定された見出し群が担う本文量に収める
- 見出し別文字数指定がある場合は、追加ルールと矛盾しない範囲で優先する
- 1文は60文字程度を目安にする
- 同じ文末を3回以上続けない
- 事実らしさに不安が残る断定は避ける

# 出力ルール
- h2とh3をまとめて出力する場合、h2本文は100文字程度、h3本文は200から300文字程度を目安にする
- h2のみの場合、本文は200から300文字程度を目安にする
- 見出しは1行ずつ残す

# 出力形式
h2：見出し
本文
h3：見出し
本文`,
  }),
  summary: ({keyword, intent, outline, synopsis, title, summaryHeading, preflightCheck, ...fields}) => ({
    instructions:
      "あなたはSEOを十分に理解しているプロのWebライターです。まとめ見出しとまとめ文だけを日本語で出力してください。",
    input: `「${keyword}」の記事まとめを書いてください。

# 記事タイトル
${title}

# まとめの見出し
${summaryHeading}

${articleSettings(fields)}

${knowledgeSection(fields)}

# ペルソナ、顕在ニーズ、潜在ニーズ
${intent}

# 記事の構成
${outline}

# 記事のあらすじ
${synopsis}

# 本文前チェック結果
${preflightCheck || "なし"}

# 制約条件
- 200から300文字を目安にする
- 記事の重要な部分をわかりやすくまとめる
- 本文前チェック結果にまとめ設計がある場合は、それを優先して記事全体を振り返る
- 必要に応じて読者の行動を促す
- 中学生でも理解できるわかりやすさにする
- 1文は60文字程度を目安にする
- 同じ文末を3回以上続けない
- 堅苦しくしすぎない`,
  }),
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

const requiredFields = {
  sourceDiscovery: ["keyword"],
  knowledge: ["keyword"],
  rakkoGpts: ["keyword"],
  intent: ["keyword"],
  outline: ["keyword", "intent", "competitorOutlines"],
  synopsis: ["keyword", "intent", "outline"],
  synopsisReview: ["keyword", "intent", "outline", "synopsis"],
  preflight: ["keyword", "intent", "outline", "synopsis"],
  titles: ["keyword", "intent", "outline", "synopsis"],
  lead: ["keyword", "intent", "outline", "synopsis", "title"],
  body: ["keyword", "intent", "outline", "synopsis", "bodyHeadings"],
  summary: ["keyword", "intent", "outline", "synopsis", "title", "summaryHeading"],
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

const formatRakkoHeadlines = (items) =>
  items
    .slice(0, 5)
    .map((item, index) => {
      const title = compact(item.page?.title) || "タイトルなし";
      const url = compact(item.page?.url);
      const headlines = (item.headlines || [])
        .filter((headline) => ["h2", "h3"].includes(compact(headline.level).toLowerCase()))
        .map((headline) => `${compact(headline.level).toLowerCase()}：${compact(headline.text)}`)
        .filter((line) => !line.endsWith("："));

      return [
        `${index + 1}位の記事`,
        `タイトル：${title}`,
        url ? `URL：${url}` : "",
        ...headlines,
      ]
        .filter(Boolean)
        .join("\n");
    })
    .filter(Boolean)
    .join("\n\n");

const fetchRakkoHeadlines = async (keyword) => {
  if (!rakkoApiKey) {
    throw new Error("RAKKO_API_KEY が未設定です。ラッコキーワード API キーを設定してください。");
  }
  if (!compact(keyword)) {
    throw new Error("見出し取得にはキーワードが必要です。");
  }

  const response = await fetch(rakkoApiUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-API-Key": rakkoApiKey,
    },
    body: JSON.stringify({
      keyword: compact(keyword),
      lessHeadlines: true,
      lessCharacters: true,
      h1: false,
      h2: true,
      h3: true,
      h4: false,
      h5: false,
      h6: false,
      sortBy: "position",
      orderBy: "asc",
      limit: 5,
    }),
  });
  const payload = await response.json();

  if (!response.ok || !payload.result) {
    throw new Error(payload.errors?.join(" / ") || "ラッコキーワードの見出し取得に失敗しました。");
  }

  const outlines = formatRakkoHeadlines(payload.data?.items || []);
  if (!outlines) {
    throw new Error("上位見出しを取得できませんでした。手入力で続けてください。");
  }

  return {
    outlines,
    consumedCredit: Number(payload.meta?.consumedCredit || 0),
    returnedCount: Number(payload.data?.summary?.returnedCount || 0),
  };
};

const saveArticleProject = async (fields, draftMarkdown) => {
  const now = new Date();
  const stamp = now.toISOString().replace(/[-:]/g, "").replace(/\.\d{3}Z$/, "Z");
  const projectName = `${safeSegment(fields.keyword, "article")}_${stamp}`;
  const projectDir = join(articleProjectsDir, projectName);
  const synopsis = compact(fields.approvedSynopsis) || compact(fields.synopsis) || compact(fields.synopsisOutput);
  const articlePlan = {
    keyword: compact(fields.keyword),
    targetLength: compact(fields.targetLength),
    bodyAllocation: compact(fields.bodyAllocation),
    articlePurpose: compact(fields.articlePurpose),
    articleTone: compact(fields.articleTone),
    selectedTitle: compact(fields.title),
    summaryHeading: compact(fields.summaryHeading),
    createdAt: now.toISOString(),
  };
  const files = {
    "request.json": JSON.stringify(
      {
        keyword: compact(fields.keyword),
        targetLength: compact(fields.targetLength),
        bodyAllocation: compact(fields.bodyAllocation),
        articlePurpose: compact(fields.articlePurpose),
        articleTone: compact(fields.articleTone),
        createdAt: now.toISOString(),
      },
      null,
      2,
    ),
    "trusted-sources.md": `# 重要情報ソースリスト\n\n${compact(fields.trustedSources) || "なし"}\n`,
    "knowledge.md": `# NotebookLMで作成した基礎知識メモ\n\n${compact(fields.knowledgeMemo) || "なし"}\n\n# NotebookLM用リサーチセット\n\n${compact(fields.notebookResearchSet) || "なし"}\n`,
    "sources.md": `# インポートした文献・資料\n\n${compact(fields.sourceMaterials) || "なし"}\n`,
    "rakko-gpts.md": `# ラッコGPTs結果\n\n${compact(fields.rakkoGptsResult) || "なし"}\n`,
    "search-intent.md": `# 検索意図\n\n${compact(fields.intent) || "なし"}\n`,
    "serp-analysis.md": `# 検索上位記事の構成\n\n${compact(fields.competitorOutlines) || "なし"}\n`,
    "outline.md": `# 記事構成\n\n${compact(fields.outline) || "なし"}\n`,
    "synopsis.md": `# 採用あらすじ\n\n${synopsis || "なし"}\n\n# あらすじ修正メモ\n\n${compact(fields.synopsisRevisionNote) || "なし"}\n`,
    "preflight-check.md": `# 本文前チェック結果\n\n${compact(fields.preflightCheck) || "なし"}\n`,
    "article-plan.json": JSON.stringify(articlePlan, null, 2),
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
    "README.md": `# ${compact(fields.keyword) || "article"}\n\nこのフォルダーは Webarticle から保存した記事プロジェクトです。\n\n## 主なファイル\n\n- request.json: 入力条件\n- trusted-sources.md: 重要情報ソースリスト\n- knowledge.md: NotebookLMメモとリサーチセット\n- sources.md: 文献・資料\n- rakko-gpts.md: ラッコGPTs結果\n- search-intent.md: 検索意図\n- serp-analysis.md: 検索上位記事の構成\n- outline.md: 記事構成\n- synopsis.md: 採用あらすじ\n- preflight-check.md: 本文前チェック\n- article-plan.json: タイトルなどの記事計画\n- draft.md: 記事下書き\n- review.json: レビュー結果の保存先\n`,
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
      rakkoReady: Boolean(rakkoApiKey),
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

  if (request.method === "POST" && request.url === "/api/rakko/headlines") {
    try {
      const body = await parseBody(request);
      json(response, 200, await fetchRakkoHeadlines(body.keyword));
    } catch (error) {
      json(response, 400, {error: error.message || "見出し取得に失敗しました。"});
    }
    return;
  }

  if (request.method === "POST" && request.url === "/api/project/save") {
    try {
      const body = await parseBody(request);
      json(response, 200, await saveArticleProject(body.fields || {}, body.draftMarkdown || ""));
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
  console.log(`Web article writer: http://localhost:${port}`);
});
