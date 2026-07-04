/**
 * Google Apps Script for the "AIエージェント参考YouTubeリスト" sheet.
 *
 * What it does:
 * - Reads pasted Transcript text from a Transcript column.
 * - Creates a Google Doc in the configured Drive folder.
 * - Writes the Doc URL back to the transcript/link column.
 * - Fills blank date/title cells when possible.
 *
 * It does not fetch YouTube transcripts automatically. For third-party videos,
 * the stable path is still: copy transcript text manually, then run this script.
 */

const TRANSCRIPT_DOCS_CONFIG = {
  driveFolderId: '1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz',
  minTranscriptChars: 80,
  clearTranscriptAfterDocCreate: false,
  docNameSuffix: ' 文字起こし',
  defaultDocTitle: 'YouTube transcript',
  transcriptHeader: 'Transcript',
  linkHeader: '要約リンク',
  dateFormat: 'yyyy-MM-dd',
};

const HEADER_ALIASES = {
  url: ['url', 'ｕｒｌ', 'youtube url', 'youtube', 'link', 'リンク'],
  date: ['date', '追加日', '日付', '登録日', '作成日'],
  title: ['title', 'タイトル', '動画タイトル', '動画名', 'name', '名称'],
  transcriptText: ['transcript', '文字起こし本文', '文字起こしテキスト', '全文', '本文'],
  transcriptLink: ['要約リンク', '文字起こしurl', '文字起こしリンク', 'transcript_url', 'transcript link', 'summary_url'],
  status: ['status', '状態', '視聴状況'],
};

function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Transcript Docs')
    .addItem('選択行からDocsを作成', 'createTranscriptDocForSelectedRow')
    .addItem('未処理行を一括処理', 'createTranscriptDocsForPendingRows')
    .addSeparator()
    .addItem('必要な列を作成', 'setupTranscriptDocColumns')
    .addToUi();
}

function setupTranscriptDocColumns() {
  const sheet = SpreadsheetApp.getActiveSheet();
  const headers = getHeaders_(sheet);
  ensureColumn_(sheet, headers, TRANSCRIPT_DOCS_CONFIG.transcriptHeader);
  ensureColumn_(sheet, getHeaders_(sheet), TRANSCRIPT_DOCS_CONFIG.linkHeader);
  SpreadsheetApp.getUi().alert('Transcript列と要約リンク列を確認しました。');
}

function createTranscriptDocForSelectedRow() {
  const sheet = SpreadsheetApp.getActiveSheet();
  const rowNumber = sheet.getActiveRange().getRow();
  if (rowNumber <= 1) {
    SpreadsheetApp.getUi().alert('ヘッダー行ではなく、処理したいデータ行を選択してください。');
    return;
  }

  const result = processRow_(sheet, rowNumber);
  SpreadsheetApp.getUi().alert(result.message);
}

function createTranscriptDocsForPendingRows() {
  const sheet = SpreadsheetApp.getActiveSheet();
  const lastRow = sheet.getLastRow();
  if (lastRow <= 1) {
    SpreadsheetApp.getUi().alert('処理対象のデータ行がありません。');
    return;
  }

  let created = 0;
  let skipped = 0;
  const errors = [];

  for (let rowNumber = 2; rowNumber <= lastRow; rowNumber++) {
    try {
      const result = processRow_(sheet, rowNumber, true);
      if (result.created) {
        created++;
      } else {
        skipped++;
      }
    } catch (error) {
      errors.push(`row ${rowNumber}: ${error.message}`);
    }
  }

  let message = `完了: created=${created}, skipped=${skipped}`;
  if (errors.length > 0) {
    message += `\n\nErrors:\n${errors.slice(0, 10).join('\n')}`;
  }
  SpreadsheetApp.getUi().alert(message);
}

function processRow_(sheet, rowNumber, quiet) {
  const headers = getHeaders_(sheet);
  let headerMap = buildHeaderMap_(headers);

  const transcriptColumn = ensureColumn_(sheet, headers, TRANSCRIPT_DOCS_CONFIG.transcriptHeader);
  headerMap = buildHeaderMap_(getHeaders_(sheet));
  const linkColumn = findColumn_(headerMap, HEADER_ALIASES.transcriptLink) ||
    ensureColumn_(sheet, getHeaders_(sheet), TRANSCRIPT_DOCS_CONFIG.linkHeader);
  headerMap = buildHeaderMap_(getHeaders_(sheet));

  const rowValues = sheet.getRange(rowNumber, 1, 1, sheet.getLastColumn()).getValues()[0];
  const existingLink = getCellByColumn_(rowValues, linkColumn);
  const transcript = getCellByColumn_(rowValues, transcriptColumn);

  if (existingLink) {
    return { created: false, message: `row ${rowNumber}: 既にリンクがあります。` };
  }

  if (!transcript) {
    return { created: false, message: `row ${rowNumber}: Transcript本文が空です。` };
  }

  if (String(transcript).trim().length < TRANSCRIPT_DOCS_CONFIG.minTranscriptChars) {
    throw new Error(`Transcript本文が短すぎます (${String(transcript).trim().length} chars)。コピー内容を確認してください。`);
  }

  const urlColumn = findColumn_(headerMap, HEADER_ALIASES.url);
  const titleColumn = findColumn_(headerMap, HEADER_ALIASES.title);
  const dateColumn = findColumn_(headerMap, HEADER_ALIASES.date);
  const statusColumn = findColumn_(headerMap, HEADER_ALIASES.status);

  const videoUrl = getCellByColumn_(rowValues, urlColumn);
  let title = getCellByColumn_(rowValues, titleColumn);
  if (!title && videoUrl) {
    title = fetchYouTubeTitle_(videoUrl);
  }
  if (!title) {
    title = TRANSCRIPT_DOCS_CONFIG.defaultDocTitle;
  }

  const docName = sanitizeDocName_(title) + TRANSCRIPT_DOCS_CONFIG.docNameSuffix;
  const docUrl = createTranscriptDoc_(docName, transcript, videoUrl);

  sheet.getRange(rowNumber, linkColumn).setValue(docUrl);

  if (titleColumn && !getCellByColumn_(rowValues, titleColumn) && title !== TRANSCRIPT_DOCS_CONFIG.defaultDocTitle) {
    sheet.getRange(rowNumber, titleColumn).setValue(title);
  }

  if (dateColumn && !getCellByColumn_(rowValues, dateColumn)) {
    const timezone = Session.getScriptTimeZone();
    sheet.getRange(rowNumber, dateColumn).setValue(Utilities.formatDate(new Date(), timezone, TRANSCRIPT_DOCS_CONFIG.dateFormat));
  }

  if (statusColumn && !getCellByColumn_(rowValues, statusColumn)) {
    sheet.getRange(rowNumber, statusColumn).setValue('Docs作成済み');
  }

  if (TRANSCRIPT_DOCS_CONFIG.clearTranscriptAfterDocCreate) {
    sheet.getRange(rowNumber, transcriptColumn).clearContent();
  }

  return {
    created: true,
    message: quiet ? `row ${rowNumber}: created` : `Google Docsを作成し、row ${rowNumber} にリンクを書き込みました。\n${docUrl}`,
  };
}

function createTranscriptDoc_(docName, transcript, videoUrl) {
  const doc = DocumentApp.create(docName);
  const body = doc.getBody();
  body.clear();

  body.appendParagraph(docName.replace(TRANSCRIPT_DOCS_CONFIG.docNameSuffix, ''))
    .setHeading(DocumentApp.ParagraphHeading.HEADING1);

  if (videoUrl) {
    body.appendParagraph(`Source: ${videoUrl}`);
    body.appendParagraph('');
  }

  body.appendParagraph(String(transcript).trim());
  doc.saveAndClose();

  const file = DriveApp.getFileById(doc.getId());
  const folder = DriveApp.getFolderById(TRANSCRIPT_DOCS_CONFIG.driveFolderId);
  file.moveTo(folder);

  return doc.getUrl();
}

function fetchYouTubeTitle_(url) {
  if (!url || !isYouTubeUrl_(url)) {
    return '';
  }

  try {
    const endpoint = `https://www.youtube.com/oembed?url=${encodeURIComponent(url)}&format=json`;
    const response = UrlFetchApp.fetch(endpoint, { muteHttpExceptions: true });
    if (response.getResponseCode() < 200 || response.getResponseCode() >= 300) {
      return '';
    }
    const payload = JSON.parse(response.getContentText());
    return payload.title || '';
  } catch (error) {
    return '';
  }
}

function isYouTubeUrl_(url) {
  return /(?:youtube\.com\/watch\?|youtube\.com\/shorts\/|youtu\.be\/)/i.test(String(url));
}

function getHeaders_(sheet) {
  return sheet.getRange(1, 1, 1, Math.max(sheet.getLastColumn(), 1)).getValues()[0];
}

function buildHeaderMap_(headers) {
  const map = {};
  headers.forEach((header, index) => {
    const normalized = normalizeHeader_(header);
    if (normalized && !map[normalized]) {
      map[normalized] = index + 1;
    }
  });
  return map;
}

function findColumn_(headerMap, aliases) {
  for (const alias of aliases) {
    const normalized = normalizeHeader_(alias);
    if (headerMap[normalized]) {
      return headerMap[normalized];
    }
  }
  return 0;
}

function ensureColumn_(sheet, headers, headerName) {
  const headerMap = buildHeaderMap_(headers);
  const existing = headerMap[normalizeHeader_(headerName)];
  if (existing) {
    return existing;
  }

  const nextColumn = sheet.getLastColumn() + 1;
  sheet.getRange(1, nextColumn).setValue(headerName);
  return nextColumn;
}

function getCellByColumn_(rowValues, columnNumber) {
  if (!columnNumber || columnNumber < 1) {
    return '';
  }
  const value = rowValues[columnNumber - 1];
  return value === null || value === undefined ? '' : String(value).trim();
}

function normalizeHeader_(value) {
  if (value === null || value === undefined) {
    return '';
  }
  return String(value).trim().toLowerCase().replace(/\s+/g, '_');
}

function sanitizeDocName_(value) {
  const cleaned = String(value || TRANSCRIPT_DOCS_CONFIG.defaultDocTitle)
    .replace(/[\\/:*?"<>|]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  return cleaned.substring(0, 120) || TRANSCRIPT_DOCS_CONFIG.defaultDocTitle;
}
