const ids = [
  "videoTitle",
  "scriptType",
  "channelName",
  "hostName",
  "audience",
  "targetLength",
  "bodyLength",
  "videoTone",
  "soloRole",
  "soloTone",
  "soloRules",
  "soloSubCharacter",
  "subCharacterName",
  "subCharacterRole",
  "subCharacterTone",
  "subCharacterScenes",
  "subCharacterFrequency",
  "subCharacterRelationship",
  "subCharacterPurpose",
  "characterAName",
  "characterARole",
  "characterATone",
  "characterBName",
  "characterBRole",
  "characterBTone",
  "relationship",
  "dialogueOutputFormat",
  "spreadsheetColumns",
  "spreadsheetColumnExamples",
  "model",
  "chatgptPrompt",
  "trustedSources",
  "knowledgeMemo",
  "referenceVideos",
  "referenceScripts",
  "referencePlots",
  "sourceMaterials",
  "notebookResearchSet",
  "articleTitles",
  "intentOutput",
  "audienceInsightOutput",
  "rakkoGptsResult",
  "competitorOutlines",
  "outlineOutput",
  "synopsisTaskType",
  "plotInput",
  "planningCheckPoints",
  "synopsisOutput",
  "synopsisRevisionNote",
  "approvedSynopsis",
  "preflightCheck",
  "introEndingOutput",
  "bodyHeadings",
  "evidenceRules",
  "extraRules",
  "bodyDraft",
  "transcriptVideoUrls",
  "rawTranscript",
  "transcriptRules",
  "cleanedTranscript",
  "rewriteGoal",
  "rewriteAnalysisOutput",
  "rewriteSynopsisOutput",
  "rewriteSynopsisRevisionNote",
  "approvedRewriteSynopsis",
  "rewriteSourceRange",
  "rewriteExtraRules",
  "dialogueRewriteDraft",
];

const elements = Object.fromEntries(ids.map((id) => [id, document.getElementById(id)]));
const preview = document.getElementById("scriptPreview");
const toast = document.getElementById("toast");
const statusDot = document.getElementById("statusDot");
const statusText = document.getElementById("statusText");
const budgetText = document.getElementById("budgetText");
const budgetMeta = document.getElementById("budgetMeta");
const apiDetails = document.getElementById("apiDetails");
const copyPromptButton = document.getElementById("copyPrompt");
const sourceMaterialsFile = document.getElementById("sourceMaterialsFile");
const buildResearchSetButton = document.getElementById("buildResearchSet");
const adoptSynopsisButton = document.getElementById("adoptSynopsis");
const synopsisAdoptStatus = document.getElementById("synopsisAdoptStatus");
const outlineCsv = document.getElementById("outlineCsv");
const csvStatus = document.getElementById("csvStatus");
const applyRakkoGptsResultButton = document.getElementById("applyRakkoGptsResult");
const storageKey = "youtube-script-workflow-state-v1";
let outlineSourcePages = [];

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

const scriptMarkdown = () =>
  [
    elements.videoTitle.value ? `# ${elements.videoTitle.value.trim()}` : "",
    elements.introEndingOutput.value.trim(),
    elements.bodyDraft.value.trim(),
    elements.dialogueRewriteDraft.value.trim(),
  ]
    .filter(Boolean)
    .join("\n\n");

const refreshPreview = () => {
  preview.textContent = scriptMarkdown() || "冒頭、本文、エンディングがここにまとまります。";
};

const setPanel = (panelId) => {
  document.querySelectorAll(".step-tabs button").forEach((button) => {
    button.classList.toggle("is-active", button.dataset.panel === panelId);
  });
  document.querySelectorAll(".step-panel").forEach((panel) => {
    panel.classList.toggle("is-active", panel.id === panelId);
  });
};

const syncScriptType = () => {
  const dialogue = elements.scriptType.value === "dialogue";
  document.querySelector(".solo-settings").hidden = dialogue;
  document.querySelector(".dialogue-settings").hidden = !dialogue;
  document.querySelector(".sub-character-settings").hidden =
    dialogue || elements.soloSubCharacter.value !== "yes";
};

const syncDialogueOutputFormat = () => {
  document.querySelector(".spreadsheet-extra-options").hidden =
    elements.dialogueOutputFormat.value !== "spreadsheet";
};

const fields = () => ({
  videoTitle: elements.videoTitle.value,
  scriptType: elements.scriptType.value,
  channelName: elements.channelName.value,
  hostName: elements.hostName.value,
  audience: elements.audience.value,
  targetLength: elements.targetLength.value,
  bodyLength: elements.bodyLength.value,
  videoTone: elements.videoTone.value,
  soloRole: elements.soloRole.value,
  soloTone: elements.soloTone.value,
  soloRules: elements.soloRules.value,
  soloSubCharacter: elements.soloSubCharacter.value,
  subCharacterName: elements.subCharacterName.value,
  subCharacterRole: elements.subCharacterRole.value,
  subCharacterTone: elements.subCharacterTone.value,
  subCharacterScenes: elements.subCharacterScenes.value,
  subCharacterFrequency: elements.subCharacterFrequency.value,
  subCharacterRelationship: elements.subCharacterRelationship.value,
  subCharacterPurpose: elements.subCharacterPurpose.value,
  characterAName: elements.characterAName.value,
  characterARole: elements.characterARole.value,
  characterATone: elements.characterATone.value,
  characterBName: elements.characterBName.value,
  characterBRole: elements.characterBRole.value,
  characterBTone: elements.characterBTone.value,
  relationship: elements.relationship.value,
  dialogueOutputFormat: elements.dialogueOutputFormat.value,
  spreadsheetColumns: elements.spreadsheetColumns.value,
  spreadsheetColumnExamples: elements.spreadsheetColumnExamples.value,
  trustedSources: elements.trustedSources.value,
  knowledgeMemo: elements.knowledgeMemo.value,
  referenceVideos: elements.referenceVideos.value,
  referenceScripts: elements.referenceScripts.value,
  referencePlots: elements.referencePlots.value,
  sourceMaterials: elements.sourceMaterials.value,
  notebookResearchSet: elements.notebookResearchSet.value,
  articleTitles: elements.articleTitles.value,
  intent: elements.intentOutput.value,
  audienceInsight: elements.audienceInsightOutput.value,
  rakkoGptsResult: elements.rakkoGptsResult.value,
  competitorOutlines: elements.competitorOutlines.value,
  outline: elements.outlineOutput.value,
  synopsisTaskType: elements.synopsisTaskType.value,
  plotInput: elements.plotInput.value,
  planningCheckPoints: elements.planningCheckPoints.value,
  synopsis: elements.approvedSynopsis.value || elements.synopsisOutput.value,
  synopsisOutput: elements.synopsisOutput.value,
  approvedSynopsis: elements.approvedSynopsis.value,
  synopsisRevisionNote: elements.synopsisRevisionNote.value,
  preflightCheck: elements.preflightCheck.value,
  introEndingOutput: elements.introEndingOutput.value,
  bodyDraft: elements.bodyDraft.value,
  bodyHeadings: elements.bodyHeadings.value,
  evidenceRules: elements.evidenceRules.value,
  extraRules: elements.extraRules.value,
  transcriptVideoUrls: elements.transcriptVideoUrls.value,
  rawTranscript: elements.rawTranscript.value,
  transcriptRules: elements.transcriptRules.value,
  cleanedTranscript: elements.cleanedTranscript.value,
  rewriteGoal: elements.rewriteGoal.value,
  rewriteAnalysis: elements.rewriteAnalysisOutput.value,
  rewriteSynopsis: elements.approvedRewriteSynopsis.value || elements.rewriteSynopsisOutput.value,
  rewriteAnalysisOutput: elements.rewriteAnalysisOutput.value,
  rewriteSynopsisOutput: elements.rewriteSynopsisOutput.value,
  approvedRewriteSynopsis: elements.approvedRewriteSynopsis.value,
  rewriteSynopsisRevisionNote: elements.rewriteSynopsisRevisionNote.value,
  rewriteSourceRange: elements.rewriteSourceRange.value,
  rewriteExtraRules: elements.rewriteExtraRules.value,
  dialogueRewriteDraft: elements.dialogueRewriteDraft.value,
});

const outputTarget = {
  sourceDiscovery: elements.trustedSources,
  knowledge: elements.knowledgeMemo,
  intent: elements.intentOutput,
  audienceInsight: elements.audienceInsightOutput,
  outline: elements.outlineOutput,
  synopsis: elements.synopsisOutput,
  synopsisReview: elements.synopsisOutput,
  preflight: elements.preflightCheck,
  introEnding: elements.introEndingOutput,
  body: elements.bodyDraft,
  transcriptCleanup: elements.cleanedTranscript,
  rewriteAnalysis: elements.rewriteAnalysisOutput,
  rewriteSynopsis: elements.rewriteSynopsisOutput,
  rewriteSynopsisReview: elements.rewriteSynopsisOutput,
  dialogueRewrite: elements.dialogueRewriteDraft,
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
    ? "採用版があります。以降の冒頭、本文に使われます。"
    : "採用版が後続ステップに使われます。";
};

const syncRewriteSynopsisAdoptStatus = () => {
  const status = document.getElementById("rewriteSynopsisAdoptStatus");
  status.textContent = elements.approvedRewriteSynopsis.value.trim()
    ? "採用版があります。対話リライトに使われます。"
    : "採用版が対話リライトに使われます。";
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
      (step === "body" || step === "dialogueRewrite") && target.value.trim()
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

const adoptRewriteSynopsis = () => {
  const draft = elements.rewriteSynopsisOutput.value.trim();
  if (!draft) {
    setToast("採用するリライトあらすじ下書きがありません。", "error");
    return;
  }
  elements.approvedRewriteSynopsis.value = draft;
  saveState();
  syncRewriteSynopsisAdoptStatus();
  setToast("リライトあらすじを採用しました。対話リライトに使います。", "success");
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
  const text = cleanCell(line).replace(/^(?:h[1-6]|中見出し|小見出し)\s*[:：]\s*/i, "");
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

const rememberOutlineSourcePages = (pages) => {
  outlineSourcePages = pages
    .map((page, index) => ({
      rank: cleanCell(page.rank) || String(index + 1),
      title: cleanCell(page.title),
      url: cleanCell(page.url),
    }))
    .filter((page) => page.url);
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

const jsonToOutline = (text) => {
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
        .map((headline) => {
          const level = cleanCell(headline.level).toLowerCase();
          const label = level === "h2" ? "中見出し" : "小見出し";
          return `${label}：${cleanCell(headline.text)}`;
        })
        .filter((line) => !line.endsWith("：") && isRelevantHeadingLine(line));

      return {rank, title, url, headlines};
    })
    .filter((page) => page.headlines.length);

  if (!pages.length) {
    throw new Error("JSONからh2/h3見出しを取得できませんでした。headlines を含むJSONか確認してください。");
  }

  rememberOutlineSourcePages(pages);

  return pages
    .slice(0, 10)
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

const textToOutline = (text) => {
  const lines = String(text || "")
    .split(/\r?\n/)
    .map(cleanCell)
    .filter(Boolean);
  const kept = [];
  let headingCount = 0;
  const prefixPattern =
    /^(?:\d+\s*位の記事|記事\s*\d+|タイトル[:：]|URL[:：]|https?:\/\/|中見出し[:：]|小見出し[:：]|h[23]\s*[:：])/i;

  lines.forEach((line) => {
    const normalized = line.replace(/^\s*[-*]\s*/, "");
    const htmlHeading = normalized.match(/^(h[23])\s*[:：]\s*(.+)$/i);
    const scriptHeading = normalized.match(/^(中見出し|小見出し)\s*[:：]\s*(.+)$/);
    if (htmlHeading) {
      const label = htmlHeading[1].toLowerCase() === "h2" ? "中見出し" : "小見出し";
      const heading = `${label}：${htmlHeading[2].trim()}`;
      if (isRelevantHeadingLine(heading)) {
        kept.push(heading);
        headingCount += 1;
      }
      return;
    }
    if (scriptHeading) {
      const heading = `${scriptHeading[1]}：${scriptHeading[2].trim()}`;
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
    return jsonToOutline(candidate);
  }
  return textToOutline(text);
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
    csvStatus.textContent =
      "ラッコGPTs結果を反映しました。台本では、視聴者ニーズと話題候補の材料として扱ってください。";
    setToast("ラッコGPTs結果を反映しました。", "success");
  } catch (error) {
    setToast(error.message || "ラッコGPTs結果の反映に失敗しました。", "error");
  }
};

const rowsToOutline = (rows) => {
  if (rows.length < 2) {
    throw new Error("CSVの行数が不足しています。");
  }

  const headers = rows[0].map(cleanCell);
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

    const title = cleanCell(titleIndex >= 0 ? values[titleIndex] : "");
    const url = cleanCell(urlIndex >= 0 ? values[urlIndex] : "");
    const key = url || title || `CSV ${Math.floor(rowIndex / 60) + 1}`;
    const page = pageGroups.get(key) || {title, url, headlines: []};
    const label = level === "h2" ? "中見出し" : level === "h3" ? "小見出し" : "h1";
    const line = `${label}：${text}`;
    if (isRelevantHeadingLine(line)) {
      page.headlines.push(line);
    }
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
    throw new Error("CSVから見出し列を判定できませんでした。");
  }

  rememberOutlineSourcePages(pages);

  return pages
    .slice(0, 10)
    .map((page, index) =>
      [
        `${index + 1}位の記事`,
        page.title ? `タイトル：${page.title}` : "",
        page.url ? `URL：${page.url}` : "",
        ...page.headlines,
      ]
        .filter(Boolean)
        .join("\n"),
    )
    .join("\n\n");
};

const importOutlineCsv = async (event) => {
  const file = event.target.files?.[0];
  if (!file) {
    return;
  }

  try {
    const text = await decodeCsvFile(file);
    elements.competitorOutlines.value =
      file.name.toLowerCase().endsWith(".json") || text.trimStart().startsWith("{")
        ? jsonToOutline(text)
        : rowsToOutline(parseCsv(text));
    saveState();
    csvStatus.textContent = `${file.name} を読み込み、目次構成用のテキストを入力しました。`;
    setToast("CSV/JSONを読み込みました。", "success");
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
    ...outlineSourcePages.map((page) => page.url),
    ...urlsFromText(elements.trustedSources.value),
    ...urlsFromText(elements.referenceVideos.value),
    ...urlsFromText(elements.referenceScripts.value),
    ...urlsFromText(elements.referencePlots.value),
    ...urlsFromText(elements.transcriptVideoUrls.value),
    ...urlsFromText(elements.sourceMaterials.value),
    ...urlsFromText(elements.competitorOutlines.value),
    ...urlsFromText(elements.articleTitles.value),
  ]).slice(0, 20);

  if (!elements.videoTitle.value.trim()) {
    setToast("先に動画タイトルを入力してください。", "error");
    return;
  }

  const rankedSources = outlineSourcePages
    .filter((page) => sourceUrls.includes(page.url))
    .slice(0, 10)
    .map((page) => `- ${page.rank}位: ${page.title || "タイトル不明"}\n  ${page.url}`)
    .join("\n");
  const urlList = sourceUrls.map((url) => `- ${url}`).join("\n");

  elements.notebookResearchSet.value = `# NotebookLMへの調査依頼
「${elements.videoTitle.value.trim()}」のYouTube台本を作るために、以下のURLや資料をソースとして確認してください。

# 重要情報ソース候補
${elements.trustedSources.value.trim() || "まだ重要情報ソース候補がありません。先に「情報ソース候補プロンプト」で候補を整理すると、NotebookLMに読み込ませる資料を選びやすくなります。"}

# 参考動画
${elements.referenceVideos.value.trim() || "参考動画がある場合は、動画URL・タイトル・要点・書き起こし抜粋をここに追加してください。"}

# 参考台本
${elements.referenceScripts.value.trim() || "参考台本がある場合は、台本本文・URL・使いたい言い回しをここに追加してください。"}

# 参考プロット
${elements.referencePlots.value.trim() || "参考プロットがある場合は、構成・展開・山場・感情変化をここに追加してください。"}

# 参考URL
${rankedSources || urlList || "まだURLがありません。CSVを読み込むか、資料URLを貼り付けてください。"}

# 依頼内容
- 視聴者が理解しておくべき前提知識を整理してください。
- 台本で誤解を招きやすい点を挙げてください。
- 専門用語、制度、仕組み、注意点を初心者向けに説明してください。
- ソースごとに、台本へ使える根拠や要点を整理してください。
- 断定を避けるべき未確認情報を分けてください。
- 一人語り、対話形式、対話リライトに反映したい観点をまとめてください。

# 出力形式
基礎知識の要約
300から500文字程度

ソース別メモ
- ソース名またはURL：
  - 重要な要点：
  - 台本で使える根拠：
  - 注意すべき断定：

専門用語
- 用語：短い説明

台本へ活かす観点
- ...`;
  saveState();
  setToast("NotebookLM用リサーチセットを作成しました。", "success");
};

const copyMarkdown = async () => {
  const markdown = scriptMarkdown();
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

const downloadMarkdown = () => {
  const markdown = scriptMarkdown();
  if (!markdown) {
    setToast("保存する下書きがまだありません。", "error");
    return;
  }
  const blob = new Blob([markdown], {type: "text/markdown;charset=utf-8"});
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = `${elements.videoTitle.value.trim() || "youtube-script"}.md`;
  link.click();
  URL.revokeObjectURL(link.href);
  setToast("Markdownファイルを保存しました。", "success");
};

const saveProject = async () => {
  if (!elements.videoTitle.value.trim()) {
    setToast("先に動画タイトルを入力してください。", "error");
    return;
  }

  try {
    const response = await fetch("/api/project/save", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({fields: fields(), draftMarkdown: scriptMarkdown()}),
    });
    const payload = await response.json();
    if (!response.ok) {
      throw new Error(payload.error || "プロジェクト保存に失敗しました。");
    }
    setToast(`script-projects/${payload.projectName} に保存しました。`, "success");
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
    if (id === "scriptType" || id === "soloSubCharacter") {
      syncScriptType();
    }
    if (id === "dialogueOutputFormat") {
      syncDialogueOutputFormat();
    }
    if (id === "approvedSynopsis") {
      syncSynopsisAdoptStatus();
    }
    if (id === "approvedRewriteSynopsis") {
      syncRewriteSynopsisAdoptStatus();
    }
  });
});

document.getElementById("copyMarkdown").addEventListener("click", copyMarkdown);
document.getElementById("downloadMarkdown").addEventListener("click", downloadMarkdown);
document.getElementById("saveProject").addEventListener("click", saveProject);
copyPromptButton.addEventListener("click", copyPrompt);
buildResearchSetButton.addEventListener("click", buildNotebookResearchSet);
apiDetails.addEventListener("toggle", syncApiActions);
adoptSynopsisButton.addEventListener("click", adoptSynopsis);
document.getElementById("adoptRewriteSynopsis").addEventListener("click", adoptRewriteSynopsis);
outlineCsv.addEventListener("change", importOutlineCsv);
applyRakkoGptsResultButton.addEventListener("click", applyRakkoGptsResult);
sourceMaterialsFile.addEventListener("change", importSourceMaterials);

checkServer();
refreshPreview();
syncApiActions();
syncScriptType();
syncDialogueOutputFormat();
syncSynopsisAdoptStatus();
syncRewriteSynopsisAdoptStatus();
