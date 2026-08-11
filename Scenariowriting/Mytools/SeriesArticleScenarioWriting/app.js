const storageKey = "seriesArticleScenarioWriting.v1";

const fields = Array.from(document.querySelectorAll("[data-field]"));
const outputText = document.querySelector("#outputText");
const policyPreview = document.querySelector("#policyPreview");
const modeInputs = Array.from(document.querySelectorAll("[name='publishMode']"));

const defaults = {
  publishMode: "note",
  seriesTitle: "塾の生徒と講師の対話で学ぶ勉強法",
  currentPolicy:
    "会話と地の文で、勉強法を押しつけずに伝える。先生は正解を断定するより、生徒が自分で気づく流れを作る。",
  characters:
    "律：勉強の必要性は分かっているが、やり方に納得できない生徒。\n相原先生：問いかけながら考えを整理する講師。認める言葉は段階的に出す。",
  corePhilosophy:
    "勉強は根性論ではなく、理解の順番と振り返り方で変わる。親には管理より観察の視点を届ける。",
  styleRules:
    "説教調にしない。\n一度で完全解決させない。\n生徒の反発や違和感を消さずに扱う。\n学習法の要点は会話の中で自然に出す。",
};

const normalizeLines = (value) =>
  String(value || "")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);

const syncMode = (selectedMode = defaults.publishMode) => {
  const nextMode = selectedMode || defaults.publishMode;
  modeInputs.forEach((input) => {
    const isSelected = input.value === nextMode;
    input.checked = isSelected;
    input.closest("label")?.classList.toggle("active", isSelected);
  });
  document.body.dataset.mode = nextMode;
};

const getData = () => {
  const data = {};
  fields.forEach((field) => {
    data[field.dataset.field] = field.value;
  });
  data.publishMode =
    modeInputs.find((input) => input.checked)?.value || defaults.publishMode;
  data.outputText = outputText.value;
  return data;
};

const setData = (data) => {
  fields.forEach((field) => {
    field.value = data[field.dataset.field] || "";
  });
  syncMode(data.publishMode || defaults.publishMode);
  outputText.value = data.outputText || "";
  updatePolicyPreview();
};

const save = () => {
  localStorage.setItem(storageKey, JSON.stringify(getData()));
  updatePolicyPreview();
};

const load = () => {
  const saved = localStorage.getItem(storageKey);
  if (saved) {
    setData({...defaults, ...JSON.parse(saved)});
    return;
  }
  setData(defaults);
};

const updatePolicyPreview = () => {
  const data = getData();
  policyPreview.textContent =
    data.currentPolicy?.trim() || data.seriesConcept?.trim() || "未入力";
};

const activateTab = (tabName) => {
  document.querySelectorAll(".tab").forEach((tab) => {
    tab.classList.toggle("active", tab.dataset.tab === tabName);
  });
  document.querySelectorAll(".tab-panel").forEach((panel) => {
    panel.classList.toggle("active", panel.dataset.panel === tabName);
  });
};

const appendPolicyHistory = () => {
  const data = getData();
  const now = new Date();
  const stamp = new Intl.DateTimeFormat("ja-JP", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(now);
  const block = [
    `【${stamp}】`,
    data.currentPolicy || "現在方針：未入力",
    data.policyReason ? `理由：${data.policyReason}` : "",
  ]
    .filter(Boolean)
    .join("\n");
  const historyField = document.querySelector("[data-field='policyHistory']");
  historyField.value = historyField.value
    ? `${block}\n\n${historyField.value}`
    : block;
  save();
};

const articleTitle = (data) => {
  if (data.publishMode !== "note" && data.seoTitle) {
    return data.seoTitle;
  }
  return data.articleTitle || data.theme || "仮タイトル";
};

const buildPointDialogue = (points) => {
  if (!points.length) {
    return [
      "律：「つまり、やり方を決める前に、何が分かっていないかを見るってことですか」",
      "相原先生：「そう。勉強時間より先に、つまずき方を見たほうがいい」",
    ].join("\n\n");
  }

  return points
    .map((point, index) =>
      [
        `律：「${point}って、どう考えればいいんですか」`,
        `相原先生：「まずはそこを一つずつ分けよう。${index + 1}つ目の手がかりは、${point}だ」`,
      ].join("\n")
    )
    .join("\n\n");
};

const generateNoteDraft = (data) => {
  const points = normalizeLines(data.keyPoints);
  const materials = data.materials?.trim();
  const title = articleTitle(data);
  const episode = data.episodeNumber ? `${data.episodeNumber} ` : "";

  return `# ${episode}${title}

${data.theme || "今回のテーマを、律と相原先生のやり取りから考えていく。"}

律は、机の上に開いたノートを見たまま、少しだけ眉を寄せていた。

律：「これ、やったほうがいいのは分かるんです。でも、なんで必要なのかがまだ分からなくて」

相原先生：「分からないまま続けるのは、しんどいよね。今日はそこをほどいてみよう」

${buildPointDialogue(points)}

${materials ? `\n使いたい場面メモを反映する：\n${materials}\n` : ""}
相原先生：「大事なのは、できるふりをすることじゃない。どこで止まったかを言葉にできることだよ」

律は、少し黙ってからノートの端に短く書き込んだ。

分からないところを、分からないままにしない。

たぶん今日の話は、そこから始まっていた。`;
};

const generateBlogDraft = (data) => {
  const points = normalizeLines(data.keyPoints);
  const sections = normalizeLines(data.blogSections);
  const title = articleTitle(data);
  const description =
    data.metaDescription ||
    `${data.theme || "勉強法の悩み"}について、生徒と講師の対話を通じて考え方を整理します。`;
  const h2s = sections.length
    ? sections
    : [
        "今回のテーマ",
        "生徒がつまずきやすいポイント",
        "対話で見えてくる勉強の考え方",
        "家庭で意識したいこと",
        "まとめ",
      ];

  return `# ${title}

メタディスクリプション：${description}
${data.slug ? `スラッグ：${data.slug}\n` : ""}${data.blogKeyword ? `メインキーワード：${data.blogKeyword}\n` : ""}
${data.targetReader ? `想定読者：${data.targetReader}\n` : ""}
${h2s
  .map((heading, index) => {
    if (index === 0) {
      return `## ${heading}

${data.theme || "今回扱うテーマをここに整理します。"}

律：「これ、やったほうがいいのは分かるんです。でも、なんで必要なのかがまだ分からなくて」

相原先生：「分からないまま続けるのは、しんどいよね。今日はそこをほどいてみよう」`;
    }

    if (index === 1) {
      return `## ${heading}

${points.length ? points.map((point) => `- ${point}`).join("\n") : "- 何を覚えるべきかが曖昧\n- 勉強時間だけで判断してしまう\n- 間違い直しが作業になっている"}`;
    }

    if (index === 2) {
      return `## ${heading}

${buildPointDialogue(points)}

${data.materials ? `\n具体例・セリフ候補：\n${data.materials}` : ""}`;
    }

    if (index === 3) {
      return `## ${heading}

${data.parentMessage || "保護者の方は、正解したかどうかだけでなく、どこで迷ったのかを一緒に確認してみてください。勉強の質は、つまずきの見つけ方で変わります。"}`;
    }

    return `## ${heading}

今回の要点は、勉強法を形だけ真似るのではなく、自分がどこで止まっているかを言葉にすることです。

${data.parentMessage || "必要に応じて、次の記事では具体的な復習の手順やノートの使い方につなげます。"}`;
  })
  .join("\n\n")}`;
};

const generatePrompt = () => {
  const data = getData();
  const modeName =
    data.publishMode === "note"
      ? "note連載記事"
      : data.publishMode === "wordpress"
        ? "WordPress掲載向けブログ記事"
        : "通常ブログ記事";

  outputText.value = `あなたは、塾の生徒と講師の対話を通じて勉強法や考え方を伝える連載記事のライターです。

以下の設定を使って、${modeName}として読める完成稿を書いてください。

【シリーズ名】
${data.seriesTitle}

【全体構想】
${data.seriesConcept}

【現在方針】
${data.currentPolicy}

【変更履歴】
${data.policyHistory}

【キャラクター設定】
${data.characters}

【関係性】
${data.relationshipDesign}

【思想的核】
${data.corePhilosophy}

【表現ルール】
${data.styleRules}

【今回の記事】
話数：${data.episodeNumber}
仮タイトル：${data.articleTitle}
テーマ：${data.theme}
要点：
${data.keyPoints}

具体例・セリフ候補・注意点：
${data.materials}

想定読者：${data.targetReader}
文字数目安：${data.targetLength}
会話と地の文の配分：${data.narrationRatio}

【ブログ用指定】
メインキーワード：${data.blogKeyword}
SEOタイトル案：${data.seoTitle}
スラッグ：${data.slug}
メタディスクリプション：${data.metaDescription}
H2構成案：
${data.blogSections}

保護者向け補足・CTA：
${data.parentMessage}

【執筆条件】
- 会話と地の文を組み合わせる
- 生徒の違和感や反発を自然に残す
- 講師は上から断定せず、問いかけながら整理する
- noteの場合は物語として余韻を残す
- ブログまたはWordPressの場合は、導入、H2見出し、まとめ、保護者向け補足を明確にする
- 調査メモや参考動画ストックの欄は使わない`;
  save();
  activateTab("output");
};

const generateDraft = () => {
  const data = getData();
  outputText.value =
    data.publishMode === "note" ? generateNoteDraft(data) : generateBlogDraft(data);
  save();
  activateTab("output");
};

document.querySelectorAll(".tab").forEach((tab) => {
  tab.addEventListener("click", () => activateTab(tab.dataset.tab));
});

fields.forEach((field) => {
  field.addEventListener("input", save);
});

modeInputs.forEach((input) => {
  input.addEventListener("change", () => {
    syncMode(input.value);
    save();
  });
});

document.querySelector("#addPolicyHistory").addEventListener("click", appendPolicyHistory);
document.querySelector("#generateDraft").addEventListener("click", generateDraft);
document.querySelector("#generatePrompt").addEventListener("click", generatePrompt);

document.querySelector("#copyOutput").addEventListener("click", async () => {
  await navigator.clipboard.writeText(outputText.value);
});

document.querySelector("#exportJson").addEventListener("click", () => {
  const blob = new Blob([JSON.stringify(getData(), null, 2)], {
    type: "application/json",
  });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = "series-article-scenario-writing.json";
  anchor.click();
  URL.revokeObjectURL(url);
});

document.querySelector("#importJson").addEventListener("change", async (event) => {
  const file = event.target.files?.[0];
  if (!file) {
    return;
  }
  const text = await file.text();
  setData({...defaults, ...JSON.parse(text)});
  save();
  event.target.value = "";
});

outputText.addEventListener("input", save);

load();
