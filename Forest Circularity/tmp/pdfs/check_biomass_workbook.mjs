import fs from "node:fs/promises";
import path from "node:path";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const inputPath = path.resolve("outputs/biomass-resource-types/バイオマス資源の種類_表4-1.xlsx");
const outputDir = path.resolve("tmp/pdfs/check-biomass-workbook");
await fs.mkdir(outputDir, { recursive: true });

const input = await FileBlob.load(inputPath);
const workbook = await SpreadsheetFile.importXlsx(input);

const overview = await workbook.inspect({
  kind: "workbook,sheet,table",
  maxChars: 6000,
  tableMaxRows: 8,
  tableMaxCols: 8,
});
console.log("OVERVIEW");
console.log(overview.ndjson);

const data = await workbook.inspect({
  kind: "table",
  range: "データ!A1:E37",
  include: "values",
  tableMaxRows: 40,
  tableMaxCols: 5,
  maxChars: 10000,
});
console.log("DATA");
console.log(data.ndjson);

for (const sheetName of ["表 4-1", "データ"]) {
  const preview = await workbook.render({
    sheetName,
    autoCrop: "all",
    scale: 1,
    format: "png",
  });
  const safeName = sheetName.replaceAll(" ", "_");
  await fs.writeFile(path.join(outputDir, `${safeName}.png`), new Uint8Array(await preview.arrayBuffer()));
}

console.log(outputDir);
