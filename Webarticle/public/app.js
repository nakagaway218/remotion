const ids = [
  "keyword",
  "model",
  "targetLength",
  "bodyAllocation",
  "articlePurpose",
  "articleTone",
  "chatgptPrompt",
  "trustedSources",
  "knowledgeMemo",
  "sourceMaterials",
  "notebookResearchSet",
  "intentOutput",
  "rakkoGptsResult",
  "competitorOutlines",
  "outlineOutput",
  "synopsisOutput",
  "synopsisRevisionNote",
  "approvedSynopsis",
  "titlesOutput",
  "selectedTitle",
  "preflightCheck",
  "leadOutput",
  "bodyHeadings",
  "headingLengthPlan",
  "extraRules",
  "bodyDraft",
  "summaryHeading",
  "summaryOutput",
];

const elements = Object.fromEntries(ids.map((id) => [id, document.getElementById(id)]));
const preview = document.getElementById("articlePreview");
const toast = document.getElementById("toast");
const statusDot = document.getElementById("statusDot");
const statusText = document.getElementById("statusText");
const budgetText = document.getElementById("budgetText");
const budgetMeta = document.getElementById("budgetMeta");
const rakkoStatus = document.getElementById("rakkoStatus");
const fetchRakkoButton = document.getElementById("fetchRakko");
const rakkoCsv = document.getElementById("rakkoCsv");
const sourceMaterialsFile = document.getElementById("sourceMaterialsFile");
const copyPromptButton = document.getElementById("copyPrompt");
const buildResearchSetButton = document.getElementById("buildResearchSet");
const applyRakkoGptsResultButton = document.getElementById("applyRakkoGptsResult");
const apiDetails = document.getElementById("apiDetails");
const adoptSynopsisButton = document.getElementById("adoptSynopsis");
const synopsisAdoptStatus = document.getElementById("synopsisAdoptStatus");
const storageKey = "web-article-writer-state-v1";
let rakkoSourcePages = [];

const readState = () => {
  try {
    return JSON.parse(localStorage.getItem(storageKey) || "{}");
  } catch {
    return {};
  }
};

const saveState = () => {
  localStorage.setItem(
    storageKey,
    JSON.stringify(Object.fromEntries(ids.map((id) => [id, elements[id].value]))),
  );
};

const setToast = (message, tone = "info") => {
  toast.textContent = message;
  toast.dataset.tone = tone;
  toast.classList.add("is-visible");
  window.clearTimeout(setToast.timer);
  setToast.timer = window.setTimeout(() => toast.classList.remove("is-visible"), 3600);
};

const articleMarkdown = () =>
  [
    elements.selectedTitle.value ? `# ${elements.selectedTitle.value.trim()}` : "",
    elements.leadOutput.value.trim(),
    elements.bodyDraft.value.trim(),
    elements.summaryOutput.value.trim(),
  ]
    .filter(Boolean)
    .join("\n\n");

const refreshPreview = () => {
  preview.textContent = articleMarkdown() || "タイトル、リード文、本文、まとめ文がここにまとまります。";
};

const setPanel = (panelId) => {
  document.querySelectorAll(".step-tabs button").forEach((button) => {
    button.classList.toggle("is-active", button.dataset.panel === panelId);
  });
  document.querySelectorAll(".step-panel").forEach((panel) => {
    panel.classList.toggle("is-active", panel.id === panelId);
  });
};

const fields = () => ({
  keyword: elements.keyword.value,
  targetLength: elements.targetLength.value,
  bodyAllocation: elements.bodyAllocation.value,
  articlePurpose: elements.articlePurpose.value,
  articleTone: elements.articleTone.value,
  trustedSources: elements.trustedSources.value,
  knowledgeMemo: elements.knowledgeMemo.value,
  sourceMaterials: elements.sourceMaterials.value,
  intent: elements.intentOutput.value,
  rakkoGptsResult: elements.rakkoGptsResult.value,
  competitorOutlines: elements.competitorOutlines.value,
  outline: elements.outlineOutput.value,
  synopsis: elements.approvedSynopsis.value || elements.synopsisOutput.value,
  synopsisOutput: elements.synopsisOutput.value,
  approvedSynopsis: elements.approvedSynopsis.value,
  synopsisRevisionNote: elements.synopsisRevisionNote.value,
  title: elements.selectedTitle.value,
  preflightCheck: elements.preflightCheck.value,
  bodyHeadings: elements.bodyHeadings.value,
  headingLengthPlan: elements.headingLengthPlan.value,
  extraRules: elements.extraRules.value,
  summaryHeading: elements.summaryHeading.value,
});

const outputTarget = {
  sourceDiscovery: elements.trustedSources,
  knowledge: elements.knowledgeMemo,
  intent: elements.intentOutput,
  outline: elements.outlineOutput,
  synopsis: elements.synopsisOutput,
  synopsisReview: elements.synopsisOutput,
  titles: elements.titlesOutput,
  preflight: elements.preflightCheck,
  lead: elements.leadOutput,
  body: elements.bodyDraft,
  summary: elements.summaryOutput,
};

const dollars = (value) => `$${Number(value || 0).toFixed(4)}`;

const renderUsage = (usage) => {
  if (!usage) {
    return;
  }
  budgetText.textContent = `使用 ${dollars(usage.spentUsd)} / 上限 ${dollars(usage.capUsd)}`;
  budgetMeta.textContent =
    `残り ${dollars(usage.remainingUsd)} / ${usage.requests || 0} 回生成 / ` +
    `入力 ${usage.inputTokens || 0} tokens / 出力 ${usage.outputTokens || 0} tokens`;
};

const syncApiActions = () => {
  document.querySelectorAll(".api-action").forEach((button) => {
    button.hidden = !apiDetails.open;
  });
};

const syncSynopsisAdoptStatus = () => {
  synopsisAdoptStatus.textContent = elements.approvedSynopsis.value.trim()
    ? "採用版があります。以降のタイトル、リード文、本文、まとめ文に使われます。"
    : "採用版が後続ステップに使われます。";
};

const generate = async (step, button) => {
  button.disabled = true;
  button.textContent = "生成中";

  try {
    const response = await fetch("/api/generate", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({step, model: elements.model.value, fields: fields()}),
    });
    const payload = await response.json();
    if (!response.ok) {
      throw new Error(payload.error || "生成に失敗しました。");
    }

    const target = outputTarget[step];
    target.value =
      step === "body" && target.value.trim()
        ? `${target.value.trim()}\n\n${payload.output}`
        : payload.output;
    saveState();
    refreshPreview();
    renderUsage(payload.usage);
    setToast(
      `${payload.stepLabel}を生成しました。今回の推定費用は ${dollars(payload.requestCostUsd)} です。`,
      "success",
    );
  } catch (error) {
    setToast(error.message, "error");
  } finally {
    button.disabled = false;
    button.textContent = button.dataset.label;
  }
};

const buildChatgptPrompt = async (step, button) => {
  button.disabled = true;
  button.textContent = "作成中";

  try {
    const response = await fetch("/api/prompt", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({step, fields: fields()}),
    });
    const payload = await response.json();
    if (!response.ok) {
      throw new Error(payload.error || "プロンプト作成に失敗しました。");
    }

    elements.chatgptPrompt.value = payload.prompt;
    saveState();
    setToast(`${payload.stepLabel}のプロンプトを作成しました。`, "success");
  } catch (error) {
    setToast(error.message, "error");
  } finally {
    button.disabled = false;
    button.textContent = button.dataset.label;
  }
};

const copyPrompt = async () => {
  const prompt = elements.chatgptPrompt.value.trim();
  if (!prompt) {
    setToast("先にプロンプトを作成してください。", "error");
    return;
  }
  try {
    await navigator.clipboard.writeText(prompt);
    setToast("プロンプトをコピーしました。", "success");
  } catch {
    setToast("ブラウザーのコピー権限を確認してください。", "error");
  }
};

const fetchRakkoHeadlines = async () => {
  fetchRakkoButton.disabled = true;
  fetchRakkoButton.textContent = "取得中";

  try {
    const response = await fetch("/api/rakko/headlines", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({keyword: elements.keyword.value}),
    });
    const payload = await response.json();
    if (!response.ok) {
      throw new Error(payload.error || "見出し取得に失敗しました。");
    }

    elements.competitorOutlines.value = payload.outlines;
    saveState();
    rakkoStatus.textContent =
      `上位 ${payload.returnedCount} 件から構成用テキストを入力しました。` +
      ` ラッコ消費クレジット ${payload.consumedCredit}。`;
    setToast("ラッコキーワードから見出しを取得しました。", "success");
  } catch (error) {
    setToast(error.message, "error");
  } finally {
    fetchRakkoButton.disabled = false;
    fetchRakkoButton.textContent = "ラッコから取得";
  }
};

const decodeCsvFile = async (file) => {
  const bytes = await file.arrayBuffer();
  const view = new Uint8Array(bytes);
  if (view[0] === 0xff && view[1] === 0xfe) {
    return new TextDecoder("utf-16le").decode(bytes).replace(/^\uFEFF/, "");
  }
  if (view[0] === 0xfe && view[1] === 0xff) {
    return new TextDecoder("utf-16be").decode(bytes).replace(/^\uFEFF/, "");
  }
  const utf8 = new TextDecoder("utf-8").decode(bytes);
  if (!utf8.includes("\uFFFD")) {
    return utf8.replace(/^\uFEFF/, "");
  }
  return new TextDecoder("shift_jis").decode(bytes).replace(/^\uFEFF/, "");
};

const parseCsv = (text) => {
  const delimiter = text.split(/\r?\n/, 1)[0]?.includes("\t") ? "\t" : ",";
  const rows = [];
  let row = [];
  let cell = "";
  let quoted = false;

  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    const next = text[index + 1];

    if (char === '"' && quoted && next === '"') {
      cell += '"';
      index += 1;
    } else if (char === '"') {
      quoted = !quoted;
    } else if (char === delimiter && !quoted) {
      row.push(cell.trim());
      cell = "";
    } else if ((char === "\n" || char === "\r") && !quoted) {
      if (char === "\r" && next === "\n") {
        index += 1;
      }
      row.push(cell.trim());
      if (row.some(Boolean)) {
        rows.push(row);
      }
      row = [];
      cell = "";
    } else {
      cell += char;
    }
  }

  row.push(cell.trim());
  if (row.some(Boolean)) {
    rows.push(row);
  }
  return rows;
};

const cleanCell = (value) => String(value || "").replace(/\s+/g, " ").trim();
const rowLabel = (value) => cleanCell(value).toLowerCase();
const irrelevantHeadingPatterns = [
  /関連記事|関連する記事|おすすめ記事|おすすめの商品|あなたへのおすすめ/,
  /人気記事|新着記事|最近の投稿|よく読まれている記事|ランキング/,
  /記事を探す|記事検索|検索フォーム|検索 article|search article/i,
  /カテゴリー|カテゴリから探す|category|タグ|keywords|キーワード/,
  /商品を探す|商品一覧|買い物|ショッピングガイド|shopping guide/i,
  /sns|フォロー|follow me/i,
  /メニュー|menu|qrコード|アクセスマップ|会社情報|問い合わせ|資料請求/,
  /ブランドサイト|キャンペーン|応募|参加する|pick up/i,
];
const isRelevantHeadingLine = (line) => {
  const text = cleanCell(line).replace(/^h[1-6]\s*[:：]\s*/i, "");
  return text && !irrelevantHeadingPatterns.some((pattern) => pattern.test(text));
};
const headingLevel = (value) => {
  const normalized = cleanCell(value).toLowerCase();
  const match = normalized.match(/(?:^|[^a-z0-9])(h[1-6])(?:[^a-z0-9]|$)/);
  return match?.[1] || "";
};
const looksLikeHeadingText = (value) => {
  const text = cleanCell(value);
  return text && !headingLevel(text) && !/^https?:\/\//i.test(text) && text.length < 260;
};

const rememberRakkoSourcePages = (pages) => {
  rakkoSourcePages = pages
    .map((page, index) => ({
      rank: cleanCell(page.rank) || String(index + 1),
      title: cleanCell(page.title),
      url: cleanCell(page.url),
    }))
    .filter((page) => page.url);
};

const rowsToRakkoOutline = (rows) => {
  if (rows.length < 2) {
    throw new Error("CSVの行数が不足しています。");
  }

  const transposed = rows.some((row) => rowLabel(row[0]) === "headline");
  if (transposed) {
    return transposedRowsToRakkoOutline(rows);
  }

  const headers = rows[0].map(cleanCell);
  const headerText = headers.join(" ");
  const positionIndex = headers.findIndex((header) => /順位|rank|position/i.test(header));
  const titleIndex = headers.findIndex((header) => /タイトル|title|記事名|ページ名/i.test(header));
  const urlIndex = headers.findIndex((header) => /url|URL/.test(header));
  const levelIndex = headers.findIndex((header) => /見出し.*(種類|階層|タグ|レベル)|heading.*level|タグ/i.test(header));
  const textIndex = headers.findIndex((header) => /見出し.*(本文|内容|テキスト|文字)|heading.*text|見出し$/i.test(header));
  const pageGroups = new Map();

  rows.slice(1).forEach((cells, rowIndex) => {
    const values = cells.map(cleanCell);
    let level = levelIndex >= 0 ? headingLevel(values[levelIndex]) : "";
    let text = textIndex >= 0 ? values[textIndex] : "";

    if (!level || !looksLikeHeadingText(text)) {
      values.forEach((value, cellIndex) => {
        if (!level) {
          level = headingLevel(value);
        }
        if (!text && cellIndex !== levelIndex && looksLikeHeadingText(value)) {
          text = value;
        }
      });
    }

    if (!["h1", "h2", "h3"].includes(level) || !looksLikeHeadingText(text)) {
      return;
    }

    const rank = cleanCell(positionIndex >= 0 ? values[positionIndex] : "");
    const title = cleanCell(titleIndex >= 0 ? values[titleIndex] : "");
    const url = cleanCell(urlIndex >= 0 ? values[urlIndex] : "");
    const key = rank || url || title || `CSV ${Math.floor(rowIndex / 60) + 1}`;
    const page = pageGroups.get(key) || {rank, title, url, headlines: []};
    page.headlines.push(`${level}：${text}`);
    if (!page.title && title) {
      page.title = title;
    }
    if (!page.url && url) {
      page.url = url;
    }
    pageGroups.set(key, page);
  });

  const pages = [...pageGroups.values()].filter((page) => page.headlines.length);
  if (!pages.length) {
    throw new Error(`CSVから見出し列を判定できませんでした。ヘッダー: ${headerText || "なし"}`);
  }

  rememberRakkoSourcePages(pages);

  return pages
    .slice(0, 5)
    .map((page, index) =>
      [
        `${page.rank || index + 1}位の記事`,
        page.title ? `タイトル：${page.title}` : "",
        page.url ? `URL：${page.url}` : "",
        ...page.headlines.filter((headline) => !headline.startsWith("h1：") && isRelevantHeadingLine(headline)),
      ]
        .filter(Boolean)
        .join("\n"),
    )
    .join("\n\n");
};

const rakkoItemsFromJson = (payload) => {
  if (Array.isArray(payload?.data?.items)) {
    return payload.data.items;
  }
  if (Array.isArray(payload?.items)) {
    return payload.items;
  }
  if (Array.isArray(payload?.result?.items)) {
    return payload.result.items;
  }
  return [];
};

const jsonToRakkoOutline = (text) => {
  let payload;
  try {
    payload = JSON.parse(text);
  } catch {
    throw new Error("JSONを解析できませんでした。ラッコキーワードから出力したJSONか確認してください。");
  }

  const pages = rakkoItemsFromJson(payload)
    .map((item, index) => {
      const rank = cleanCell(item.metrics?.position) || String(index + 1);
      const title = cleanCell(item.page?.title);
      const url = cleanCell(item.page?.url);
      const headlines = (item.headlines || [])
        .filter((headline) => ["h2", "h3"].includes(cleanCell(headline.level).toLowerCase()))
        .map((headline) => `${cleanCell(headline.level).toLowerCase()}：${cleanCell(headline.text)}`)
        .filter((line) => !line.endsWith("：") && isRelevantHeadingLine(line));

      return {rank, title, url, headlines};
    })
    .filter((page) => page.headlines.length);

  if (!pages.length) {
    throw new Error("JSONからh2/h3見出しを取得できませんでした。headlines を含むJSONか確認してください。");
  }

  rememberRakkoSourcePages(pages);

  return pages
    .slice(0, 5)
    .map((page, index) =>
      [
        `${page.rank || index + 1}位の記事`,
        page.title ? `タイトル：${page.title}` : "",
        page.url ? `URL：${page.url}` : "",
        ...page.headlines,
      ]
        .filter(Boolean)
        .join("\n"),
    )
    .join("\n\n");
};

const extractJsonCandidate = (text) => {
  const source = String(text || "").trim();
  const fenced = source.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fenced) {
    return fenced[1].trim();
  }
  const firstBrace = source.indexOf("{");
  const lastBrace = source.lastIndexOf("}");
  if (firstBrace >= 0 && lastBrace > firstBrace) {
    return source.slice(firstBrace, lastBrace + 1);
  }
  return source;
};

const textToRakkoOutline = (text) => {
  const lines = String(text || "")
    .split(/\r?\n/)
    .map(cleanCell)
    .filter(Boolean);
  const kept = [];
  let headingCount = 0;
  const prefixPattern =
    /^(?:\d+\s*位の記事|記事\s*\d+|タイトル[:：]|URL[:：]|https?:\/\/|h[23]\s*[:：])/i;

  lines.forEach((line) => {
    const normalized = line.replace(/^\s*[-*]\s*/, "");
    const match = normalized.match(/^(h[23])\s*[:：]\s*(.+)$/i);
    if (match) {
      const heading = `${match[1].toLowerCase()}：${match[2].trim()}`;
      if (isRelevantHeadingLine(heading)) {
        kept.push(heading);
        headingCount += 1;
      }
      return;
    }
    if (prefixPattern.test(normalized)) {
      kept.push(normalized);
    }
  });

  if (!headingCount) {
    throw new Error("GPTs結果からh2/h3見出しを判定できませんでした。JSONか、h2：/h3：形式の出力を貼り付けてください。");
  }

  return kept.join("\n");
};

const rakkoGptsResultToOutline = (text) => {
  const candidate = extractJsonCandidate(text);
  if (candidate.trimStart().startsWith("{")) {
    return jsonToRakkoOutline(candidate);
  }
  return textToRakkoOutline(text);
};

const applyRakkoGptsResult = () => {
  const text = elements.rakkoGptsResult.value.trim();
  if (!text) {
    setToast("先にラッコGPTsの結果を貼り付けてください。", "error");
    return;
  }

  try {
    elements.competitorOutlines.value = rakkoGptsResultToOutline(text);
    saveState();
    rakkoStatus.textContent = "ラッコGPTs結果を構成用の上位見出しテキストへ反映しました。";
    setToast("ラッコGPTs結果を反映しました。", "success");
  } catch (error) {
    setToast(error.message || "ラッコGPTs結果の反映に失敗しました。", "error");
  }
};

const transposedRowsToRakkoOutline = (rows) => {
  const labels = new Map(rows.map((row) => [rowLabel(row[0]), row]));
  const rankRow = labels.get("rank") || [];
  const titleRow = labels.get("title") || [];
  const urlRow = labels.get("url") || [];
  const headlineRows = rows.filter((row) => rowLabel(row[0]) === "headline" || !cleanCell(row[0]));
  const maxColumns = Math.max(rankRow.length, titleRow.length, urlRow.length);
  const pages = [];

  for (let column = 1; column < maxColumns; column += 1) {
    const headlines = headlineRows
      .map((row) => cleanCell(row[column]))
      .map((headline) => {
        const match = headline.match(/^(h[1-6])\s*[:：]\s*(.+)$/i);
        return match ? `${match[1].toLowerCase()}：${match[2].trim()}` : "";
      })
      .filter((line) => /^h[23]：/.test(line) && isRelevantHeadingLine(line));

    if (!headlines.length) {
      continue;
    }

    pages.push({
      rank: cleanCell(rankRow[column]) || String(column),
      title: cleanCell(titleRow[column]),
      url: cleanCell(urlRow[column]),
      headlines,
    });
  }

  if (!pages.length) {
    throw new Error("CSVからh2/h3見出しを判定できませんでした。headline 行を含むCSVか確認してください。");
  }

  rememberRakkoSourcePages(pages);

  return pages
    .slice(0, 5)
    .map((page, index) =>
      [
        `${page.rank || index + 1}位の記事`,
        page.title ? `タイトル：${page.title}` : "",
        page.url ? `URL：${page.url}` : "",
        ...page.headlines,
      ]
        .filter(Boolean)
        .join("\n"),
    )
    .join("\n\n");
};

const importRakkoCsv = async (event) => {
  const file = event.target.files?.[0];
  if (!file) {
    return;
  }

  try {
    const text = await decodeCsvFile(file);
    elements.competitorOutlines.value =
      file.name.toLowerCase().endsWith(".json") || text.trimStart().startsWith("{")
        ? jsonToRakkoOutline(text)
        : rowsToRakkoOutline(parseCsv(text));
    saveState();
    rakkoStatus.textContent = `${file.name} を読み込み、構成用の上位見出しテキストを入力しました。`;
    setToast("ラッコファイルを読み込みました。", "success");
  } catch (error) {
    setToast(error.message || "ファイルの読み込みに失敗しました。", "error");
  } finally {
    event.target.value = "";
  }
};

const importSourceMaterials = async (event) => {
  const files = [...(event.target.files || [])];
  if (!files.length) {
    return;
  }

  try {
    const imported = await Promise.all(
      files.map(async (file) => {
        const text = await decodeCsvFile(file);
        return `# ${file.name}\n${text.trim()}`;
      }),
    );
    elements.sourceMaterials.value = [elements.sourceMaterials.value.trim(), ...imported]
      .filter(Boolean)
      .join("\n\n");
    saveState();
    setToast(`${files.length}件の資料を読み込みました。`, "success");
  } catch (error) {
    setToast(error.message || "資料の読み込みに失敗しました。", "error");
  } finally {
    event.target.value = "";
  }
};

const urlsFromText = (text) =>
  [...String(text || "").matchAll(/https?:\/\/[^\s"'<>）)]+/g)].map((match) => match[0]);

const uniqueUrls = (urls) => [...new Set(urls.map((url) => url.trim()).filter(Boolean))];

const buildNotebookResearchSet = () => {
  const sourceUrls = uniqueUrls([
    ...rakkoSourcePages.map((page) => page.url),
    ...urlsFromText(elements.trustedSources.value),
    ...urlsFromText(elements.sourceMaterials.value),
    ...urlsFromText(elements.competitorOutlines.value),
  ]).slice(0, 20);

  if (!elements.keyword.value.trim()) {
    setToast("先にキーワードを入力してください。", "error");
    return;
  }

  const rankedSources = rakkoSourcePages
    .filter((page) => sourceUrls.includes(page.url))
    .slice(0, 10)
    .map((page) => `- ${page.rank}位: ${page.title || "タイトル不明"}\n  ${page.url}`)
    .join("\n");
  const urlList = sourceUrls.map((url) => `- ${url}`).join("\n");

  elements.notebookResearchSet.value = `# NotebookLMへの調査依頼
「${elements.keyword.value.trim()}」の記事を書くために、以下のURLや資料をソースとして確認してください。

# 重要情報ソース候補
${elements.trustedSources.value.trim() || "まだ重要情報ソース候補がありません。先に「情報ソース候補プロンプト」で候補を整理すると、NotebookLMに読み込ませる資料を選びやすくなります。"}

# 参考URL
${rankedSources || urlList || "まだURLがありません。ラッコJSON/CSVを読み込むか、文献URLを貼り付けてください。"}

# 依頼内容
- 読者が理解しておくべき前提知識を整理してください。
- 記事で誤解を招きやすい点を挙げてください。
- 専門用語、制度、仕組み、注意点を初心者向けに説明してください。
- ソースごとに、記事へ使える根拠や要点を整理してください。
- 断定を避けるべき未確認情報を分けてください。
- 検索意図、構成、本文に反映したい観点をまとめてください。

# 出力形式
基礎知識の要約
300から500文字程度

ソース別メモ
- ソース名またはURL：
  - 重要な要点：
  - 記事で使える根拠：
  - 注意すべき断定：

専門用語
- 用語：短い説明

記事へ活かす観点
- ...`;
  saveState();
  setToast("NotebookLM用リサーチセットを作成しました。", "success");
};

const copyMarkdown = async () => {
  const markdown = articleMarkdown();
  if (!markdown) {
    setToast("コピーする下書きがまだありません。", "error");
    return;
  }
  try {
    await navigator.clipboard.writeText(markdown);
    setToast("Markdownをコピーしました。", "success");
  } catch {
    setToast("ブラウザーのコピー権限を確認してください。", "error");
  }
};

const adoptSynopsis = () => {
  const draft = elements.synopsisOutput.value.trim();
  if (!draft) {
    setToast("採用するあらすじ下書きがありません。", "error");
    return;
  }
  elements.approvedSynopsis.value = draft;
  saveState();
  syncSynopsisAdoptStatus();
  setToast("あらすじを採用しました。後続ステップに使います。", "success");
};

const downloadMarkdown = () => {
  const markdown = articleMarkdown();
  if (!markdown) {
    setToast("保存する下書きがまだありません。", "error");
    return;
  }
  const blob = new Blob([markdown], {type: "text/markdown;charset=utf-8"});
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = `${elements.keyword.value.trim() || "web-article"}.md`;
  link.click();
  URL.revokeObjectURL(link.href);
  setToast("Markdownファイルを保存しました。", "success");
};

const saveProject = async () => {
  if (!elements.keyword.value.trim()) {
    setToast("先にキーワードを入力してください。", "error");
    return;
  }

  try {
    const response = await fetch("/api/project/save", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({fields: fields(), draftMarkdown: articleMarkdown()}),
    });
    const payload = await response.json();
    if (!response.ok) {
      throw new Error(payload.error || "プロジェクト保存に失敗しました。");
    }
    setToast(`article-projects/${payload.projectName} に保存しました。`, "success");
  } catch (error) {
    setToast(error.message || "プロジェクト保存に失敗しました。", "error");
  }
};

const checkServer = async () => {
  try {
    const response = await fetch("/api/health");
    const payload = await response.json();
    statusDot.dataset.ready = payload.ready;
    statusText.textContent = payload.ready
      ? `API生成も利用可能 / ${payload.defaultModel}`
      : "Plus手動連携";
    elements.model.value = payload.supportedModels.includes(elements.model.value)
      ? elements.model.value
      : payload.defaultModel;
    renderUsage(payload.usage);
    rakkoStatus.textContent = payload.rakkoReady
      ? "ラッコ API 接続準備済みです。キーワードから上位見出しを取得できます。"
      : "RAKKO_API_KEY 未設定です。見出しは手入力でも続けられます。";
  } catch {
    statusDot.dataset.ready = "false";
    statusText.textContent = "サーバー未接続";
  }
};

Object.entries(readState()).forEach(([id, value]) => {
  if (elements[id]) {
    elements[id].value = value;
  }
});

document.querySelectorAll(".step-tabs button").forEach((button) => {
  button.addEventListener("click", () => setPanel(button.dataset.panel));
});

document.querySelectorAll("[data-generate]").forEach((button) => {
  button.dataset.label = button.textContent;
  button.addEventListener("click", () => generate(button.dataset.generate, button));
});

document.querySelectorAll("[data-prompt]").forEach((button) => {
  button.dataset.label = button.textContent;
  button.addEventListener("click", () => buildChatgptPrompt(button.dataset.prompt, button));
});

ids.forEach((id) => {
  elements[id].addEventListener("input", () => {
    saveState();
    refreshPreview();
    if (id === "approvedSynopsis") {
      syncSynopsisAdoptStatus();
    }
  });
});

document.getElementById("copyMarkdown").addEventListener("click", copyMarkdown);
document.getElementById("downloadMarkdown").addEventListener("click", downloadMarkdown);
document.getElementById("saveProject").addEventListener("click", saveProject);
fetchRakkoButton.addEventListener("click", fetchRakkoHeadlines);
rakkoCsv.addEventListener("change", importRakkoCsv);
sourceMaterialsFile.addEventListener("change", importSourceMaterials);
copyPromptButton.addEventListener("click", copyPrompt);
buildResearchSetButton.addEventListener("click", buildNotebookResearchSet);
applyRakkoGptsResultButton.addEventListener("click", applyRakkoGptsResult);
apiDetails.addEventListener("toggle", syncApiActions);
adoptSynopsisButton.addEventListener("click", adoptSynopsis);

checkServer();
refreshPreview();
syncApiActions();
syncSynopsisAdoptStatus();
