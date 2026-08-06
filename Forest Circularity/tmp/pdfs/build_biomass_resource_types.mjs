import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = path.resolve("outputs/biomass-resource-types");
await fs.mkdir(outputDir, { recursive: true });

const data = [
  ["廃棄物系資源", "木質系バイオマス", "製材工場残材", ""],
  ["廃棄物系資源", "木質系バイオマス", "建設発生木材", ""],
  ["廃棄物系資源", "製紙系バイオマス", "古紙", ""],
  ["廃棄物系資源", "製紙系バイオマス", "製紙汚泥", ""],
  ["廃棄物系資源", "製紙系バイオマス", "黒液", ""],
  ["廃棄物系資源", "家畜排せつ物", "牛ふん尿", ""],
  ["廃棄物系資源", "家畜排せつ物", "豚ふん尿", ""],
  ["廃棄物系資源", "家畜排せつ物", "鶏ふん尿", ""],
  ["廃棄物系資源", "家畜排せつ物", "その他家畜ふん尿", ""],
  ["廃棄物系資源", "生活排水", "下水汚泥", ""],
  ["廃棄物系資源", "生活排水", "し尿・浄化槽汚泥", ""],
  ["廃棄物系資源", "食品廃棄物", "食品加工廃棄物", ""],
  ["廃棄物系資源", "食品廃棄物", "食品販売廃棄物", "卸売市場廃棄物"],
  ["廃棄物系資源", "食品廃棄物", "食品販売廃棄物", "食品小売業廃棄物"],
  ["廃棄物系資源", "食品廃棄物", "厨芥類", "家庭系厨芥"],
  ["廃棄物系資源", "食品廃棄物", "厨芥類", "事業系厨芥"],
  ["廃棄物系資源", "食品廃棄物", "廃食用油", ""],
  ["廃棄物系資源", "その他", "埋立地ガス", ""],
  ["廃棄物系資源", "その他", "紙くず・繊維くず", ""],
  ["未利用系資源", "木質系バイオマス", "森林バイオマス", "林地残材"],
  ["未利用系資源", "木質系バイオマス", "森林バイオマス", "間伐材"],
  ["未利用系資源", "木質系バイオマス", "森林バイオマス", "未利用樹"],
  ["未利用系資源", "木質系バイオマス", "その他木質系バイオマス", "剪定枝など"],
  ["未利用系資源", "農業残さ系", "稲作残さ", "稲わら"],
  ["未利用系資源", "農業残さ系", "稲作残さ", "もみ殻"],
  ["未利用系資源", "農業残さ系", "麦わら", ""],
  ["未利用系資源", "農業残さ系", "バガス", ""],
  ["未利用系資源", "農業残さ系", "その他農業残さ", ""],
  ["生産系資源", "木質系バイオマス", "短周期栽培木材", ""],
  ["生産系資源", "草本系バイオマス", "牧草", ""],
  ["生産系資源", "草本系バイオマス", "水草", ""],
  ["生産系資源", "草本系バイオマス", "海草", ""],
  ["生産系資源", "その他", "藻類", ""],
  ["生産系資源", "その他", "糖・でんぷん", ""],
  ["生産系資源", "その他", "植物油", "パーム油"],
  ["生産系資源", "その他", "植物油", "菜種油"],
];

function mergeRuns(sheet, col, startRow, values, mergeSingle = false) {
  let start = 0;
  for (let i = 1; i <= values.length; i++) {
    if (i === values.length || values[i] !== values[start]) {
      const row1 = startRow + start;
      const row2 = startRow + i - 1;
      if (row2 > row1 || mergeSingle) {
        sheet.getRange(`${col}${row1}:${col}${row2}`).merge();
      }
      start = i;
    }
  }
}

function rowCountByGroup(rows, colIndex, startRow) {
  const groups = [];
  let start = 0;
  for (let i = 1; i <= rows.length; i++) {
    if (i === rows.length || rows[i][colIndex] !== rows[start][colIndex]) {
      groups.push({ value: rows[start][colIndex], startRow: startRow + start, endRow: startRow + i - 1 });
      start = i;
    }
  }
  return groups;
}

const workbook = Workbook.create();
const tableSheet = workbook.worksheets.add("表 4-1");
const dataSheet = workbook.worksheets.add("データ");

tableSheet.showGridLines = false;
tableSheet.getRange("A1:D1").merge();
tableSheet.getRange("A1").values = [["表 4-1　バイオマス資源の種類"]];
tableSheet.getRange("A1").format = {
  font: { bold: true, size: 16, color: "#0B1F8F" },
  horizontalAlignment: "center",
};

const headers = [["資源区分", "系統", "資源分類", "詳細"]];
tableSheet.getRange("A3:D3").values = headers;
tableSheet.getRange("A3:D3").format = {
  fill: "#0B8FC7",
  font: { bold: true, color: "#FFFFFF" },
  horizontalAlignment: "center",
  verticalAlignment: "middle",
};

tableSheet.getRange(`A4:D${data.length + 3}`).values = data;
tableSheet.getRange(`A3:D${data.length + 3}`).format.borders = { preset: "all", style: "thin", color: "#3F3F46" };
tableSheet.getRange(`A4:B${data.length + 3}`).format = {
  fill: "#CFE0F4",
  verticalAlignment: "middle",
  wrapText: true,
};
tableSheet.getRange(`C4:D${data.length + 3}`).format = {
  verticalAlignment: "middle",
  wrapText: true,
};
tableSheet.getRange(`A4:A${data.length + 3}`).format = {
  fill: "#1094CE",
  font: { color: "#FFFFFF", bold: true },
  horizontalAlignment: "center",
  verticalAlignment: "middle",
  wrapText: true,
};

mergeRuns(tableSheet, "A", 4, data.map((row) => row[0]));
mergeRuns(tableSheet, "B", 4, data.map((row) => `${row[0]}|${row[1]}`).map((key) => key.split("|")[1]));

// Merge the品目 column only within continuous repeated品目 blocks that share the same parent.
let itemStart = 0;
for (let i = 1; i <= data.length; i++) {
  const sameParent =
    i < data.length &&
    data[i][0] === data[itemStart][0] &&
    data[i][1] === data[itemStart][1] &&
    data[i][2] === data[itemStart][2];
  if (!sameParent) {
    const row1 = 4 + itemStart;
    const row2 = 4 + i - 1;
    if (row2 > row1) tableSheet.getRange(`C${row1}:C${row2}`).merge();
    itemStart = i;
  }
}

for (const group of rowCountByGroup(data, 0, 4)) {
  tableSheet.getRange(`A${group.startRow}:D${group.startRow}`).format.borders = {
    top: { style: "medium", color: "#111827" },
  };
}

tableSheet.getRange("A:A").format.columnWidth = 15;
tableSheet.getRange("B:B").format.columnWidth = 22;
tableSheet.getRange("C:C").format.columnWidth = 24;
tableSheet.getRange("D:D").format.columnWidth = 22;
tableSheet.getRange(`3:${data.length + 3}`).format.rowHeight = 24;
tableSheet.freezePanes.freezeRows(3);

dataSheet.showGridLines = false;
dataSheet.getRange("A1:E1").values = [["資源区分", "系統", "資源分類", "品目詳細", "PDF表での行"]];
dataSheet.getRange(`A2:E${data.length + 1}`).values = data.map((row, index) => [
  row[0],
  row[1],
  row[2],
  row[3],
  index + 1,
]);
dataSheet.getRange(`A1:E${data.length + 1}`).format.borders = { preset: "all", style: "thin", color: "#D4D4D8" };
dataSheet.getRange("A1:E1").format = {
  fill: "#14532D",
  font: { bold: true, color: "#FFFFFF" },
  horizontalAlignment: "center",
};
dataSheet.getRange(`A2:D${data.length + 1}`).format.wrapText = true;
dataSheet.getRange("A:A").format.columnWidth = 16;
dataSheet.getRange("B:B").format.columnWidth = 22;
dataSheet.getRange("C:C").format.columnWidth = 24;
dataSheet.getRange("D:D").format.columnWidth = 20;
dataSheet.getRange("E:E").format.columnWidth = 14;
dataSheet.freezePanes.freezeRows(1);
const table = dataSheet.tables.add(`A1:E${data.length + 1}`, true, "BiomassResourceTypes");
table.style = "TableStyleMedium4";

const preview = await workbook.render({
  sheetName: "表 4-1",
  autoCrop: "all",
  scale: 1,
  format: "png",
});
await fs.writeFile(path.join(outputDir, "preview.png"), new Uint8Array(await preview.arrayBuffer()));

const dataPreview = await workbook.render({
  sheetName: "データ",
  autoCrop: "all",
  scale: 1,
  format: "png",
});
await fs.writeFile(path.join(outputDir, "data-preview.png"), new Uint8Array(await dataPreview.arrayBuffer()));

const check = await workbook.inspect({
  kind: "table",
  range: `データ!A1:E${data.length + 1}`,
  include: "values",
  tableMaxRows: 40,
  tableMaxCols: 5,
  maxChars: 8000,
});
console.log(check.ndjson);

const xlsx = await SpreadsheetFile.exportXlsx(workbook);
await xlsx.save(path.join(outputDir, "バイオマス資源の種類_表4-1.xlsx"));

console.log(path.join(outputDir, "バイオマス資源の種類_表4-1.xlsx"));
