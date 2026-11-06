import fs from "node:fs/promises";
import path from "node:path";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const root = "G:/research niches";
const dataDir = path.join(root, "02-data");
const workbookPath = path.join(root, "01-bao-cao", "youtube_niche_data_report.xlsx");
const font = "Arial";
const C = { navy: "#153B5B", blue: "#1F6E8C", paleBlue: "#EAF4FB", green: "#277A54", paleGreen: "#EAF7F0", amber: "#FFF4D6", amberText: "#7A5200", red: "#FDE9EA", redText: "#9B2431", line: "#D6E0EA", white: "#FFFFFF", ink: "#152536", gray: "#5E6B7A" };

function parseCsv(text) {
  const rows = []; let row = []; let value = ""; let quoted = false;
  for (let i = 0; i < text.length; i += 1) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') { value += '"'; i += 1; }
      else if (ch === '"') quoted = false;
      else value += ch;
    } else if (ch === '"') quoted = true;
    else if (ch === ',') { row.push(value); value = ""; }
    else if (ch === '\n') { row.push(value.replace(/\r$/, "")); rows.push(row); row = []; value = ""; }
    else value += ch;
  }
  if (value.length || row.length) { row.push(value.replace(/\r$/, "")); rows.push(row); }
  const [rawHeaders, ...records] = rows;
  const headers = rawHeaders.map(h => h.replace(/^\uFEFF/, ""));
  return records.filter(r => r.some(cell => cell !== "")).map(r => Object.fromEntries(headers.map((h, i) => [h, r[i] ?? ""])));
}
const readCsv = async name => parseCsv(await fs.readFile(path.join(dataDir, name), "utf8"));
const num = value => Number(value || 0);
const date = value => value ? new Date(`${value}T00:00:00Z`) : null;
function setTitle(sheet, text, subtitle, endColumn) {
  sheet.showGridLines = false;
  sheet.getRange("A2").values = [[text]];
  sheet.getRange("A2").format = { font: { name: font, size: 16, bold: true, color: C.ink } };
  sheet.getRange(`A3:${endColumn}3`).merge();
  sheet.getRange("A3").values = [[subtitle]];
  sheet.getRange("A3").format = { font: { name: font, size: 10, italic: true, color: C.gray } };
  sheet.getRange(`A4:${endColumn}4`).format.borders = { bottom: { style: "medium", color: C.navy } };
}
function header(range) { range.format = { fill: C.navy, font: { name: font, size: 10, bold: true, color: C.white }, horizontalAlignment: "center", verticalAlignment: "center", wrapText: true, borders: { preset: "all", style: "thin", color: C.white } }; }
function body(range) { range.format.borders = { preset: "inside", style: "thin", color: C.line }; range.format.verticalAlignment = "center"; }
function widths(sheet, specs) { for (const [range, width] of specs) sheet.getRange(range).format.columnWidth = width; }
function safeName(value) { return value.replace(/[^A-Za-z0-9]+/g, "_").replace(/^_|_$/g, "").toLowerCase(); }

const [candidates, observations, evidence, branch, caleb] = await Promise.all([
  readCsv("round2-validated-candidate-summary.csv"),
  readCsv("round2-enriched-observations.csv"),
  readCsv("round2-channel-evidence.csv"),
  readCsv("round2-primary-history-branch.csv"),
  readCsv("round2-primary-history-caleb.csv")
]);

const input = await FileBlob.load(workbookPath);
const workbook = await SpreadsheetFile.importXlsx(input);
const r2 = workbook.worksheets.add("Round 2 summary");
const obs = workbook.worksheets.add("Round 2 observations");
const repeat = workbook.worksheets.add("Round 2 repeat evidence");
const audit = workbook.worksheets.add("Round 2 audit");

// Calculation/output sheet.
setTitle(r2, "Round 2 niche validation", "Balanced 8-query sample per candidate. Only direct-enriched public observations feed this gate.", "L");
r2.getRange("A6:L6").values = [["Candidate", "Direct videos", "Channels", "Queries", "Median VPD", "P25 VPD", "P75 VPD", "Videos ≤365d", "Recent share", "Repeat channels", "Evidence gate", "Round 3 action"]];
header(r2.getRange("A6:L6"));
const action = {
  "AI compute infrastructure": "Advance: competitor/engine analysis",
  "Water and civic systems": "Hold: evergreen backup; refresh evidence later",
  "Business mechanics": "Hold: speed backup; weaker current evidence",
  "3D engineered systems": "Do not treat as niche; retain as format layer"
};
const candidateRows = candidates.map(c => [c.candidate, num(c.enriched_videos), num(c.unique_channels), num(c.covered_queries), num(c.median_vpd), num(c.p25_vpd), num(c.p75_vpd), num(c.recent_365d_videos), null, num(c.repeat_evidence_channels), null, action[c.candidate] || "Hold"]);
r2.getRange(`A7:L${6 + candidateRows.length}`).values = candidateRows;
for (let row = 7; row < 7 + candidateRows.length; row += 1) {
  r2.getRange(`I${row}`).formulas = [[`=H${row}/B${row}`]];
  r2.getRange(`K${row}`).formulas = [[`=IF(AND(B${row}>=10,D${row}>=8,I${row}>=0.5,J${row}>=2),"ADVANCE","HOLD")`]];
}
body(r2.getRange(`A7:L${6 + candidateRows.length}`));
r2.getRange(`B7:D${6 + candidateRows.length}`).format.numberFormat = "#,##0";
r2.getRange(`E7:G${6 + candidateRows.length}`).format.numberFormat = "#,##0.0";
r2.getRange(`H7:H${6 + candidateRows.length}`).format.numberFormat = "#,##0";
r2.getRange(`I7:I${6 + candidateRows.length}`).format.numberFormat = "0.0%";
r2.getRange(`J7:J${6 + candidateRows.length}`).format.numberFormat = "#,##0";
r2.getRange(`K7:K${6 + candidateRows.length}`).conditionalFormats.add("containsText", { text: "ADVANCE", format: { fill: C.paleGreen, font: { color: C.green, bold: true } } });
r2.getRange(`K7:K${6 + candidateRows.length}`).conditionalFormats.add("containsText", { text: "HOLD", format: { fill: C.amber, font: { color: C.amberText, bold: true } } });
r2.getRange("A13:L13").merge();
r2.getRange("A13").values = [["Gate logic: Direct videos ≥10; Queries =8; Recent share ≥50%; Repeat channels ≥2. This gate advances research only. It does not predict revenue, YPP, audience country, CTR, retention or new-channel success."]];
r2.getRange("A13").format = { fill: C.amber, font: { name: font, size: 10, color: C.amberText }, wrapText: true, verticalAlignment: "top" };
r2.getRange("A15:F15").values = [["Primary candidate", "Current evidence", "What it is", "What it excludes", "Visual advantage", "Open validation"]];
header(r2.getRange("A15:F15"));
r2.getRange("A16:F16").values = [["AI physical infrastructure", "13 direct videos; 8 queries; 7 recent; 3 repeat channels", "Data centers, chips, power, cooling, water, network", "AI news, tool reviews, coding tutorials", "3D system flow + map + causal simulation", "US audience, new-channel cohort, CTR, AVD, RPM"]];
body(r2.getRange("A16:F16")); r2.getRange("A16:F16").format.wrapText = true;
widths(r2, [["A:A", 31], ["B:D", 14], ["E:G", 15], ["H:J", 14], ["K:K", 15], ["L:L", 42]]);
r2.getRange("A6:L16").format.rowHeight = 28; r2.freezePanes.freezeRows(6);

// Direct-enriched observation input table.
setTitle(obs, "Round 2 direct-enriched observations", "One high-view and one median-view provisional observation per query were direct-enriched before VPD analysis.", "P");
const obsHeaders = ["Candidate", "Sample role", "Source query", "Video ID", "Channel", "Handle", "Title", "Upload date", "Age days", "Duration sec", "Views snapshot", "VPD", "Channel subs snapshot", "Likes", "Comments", "Video URL"];
obs.getRange("A6:P6").values = [obsHeaders]; header(obs.getRange("A6:P6"));
const obsValues = observations.map(r => [r.candidate, r.sample_role, r.source_query, r.video_id, r.channel_name, r.channel_handle, r.title, date(r.upload_date), num(r.age_days), num(r.duration_seconds), num(r.views_snapshot), num(r.views_per_day), num(r.channel_subscribers_snapshot), num(r.likes_snapshot), num(r.comments_snapshot), r.video_url]);
obs.getRange(`A7:P${6 + obsValues.length}`).values = obsValues; body(obs.getRange(`A7:P${6 + obsValues.length}`));
obs.getRange(`H7:H${6 + obsValues.length}`).format.numberFormat = "yyyy-mm-dd";
obs.getRange(`I7:O${6 + obsValues.length}`).format.numberFormat = "#,##0.0";
obs.getRange(`L7:L${6 + obsValues.length}`).conditionalFormats.add("dataBar", { color: C.blue, gradient: true });
widths(obs, [["A:A", 28], ["B:B", 29], ["C:C", 38], ["D:D", 18], ["E:E", 25], ["F:F", 20], ["G:G", 58], ["H:H", 14], ["I:O", 15], ["P:P", 42]]);
obs.getRange(`G7:G${6 + obsValues.length}`).format.wrapText = true; obs.freezePanes.freezeRows(6);

// Repeat evidence table.
setTitle(repeat, "Round 2 repeat evidence", "Repeat means the same channel appeared in at least two candidate-query observations. It is not a claim of total channel performance.", "K");
const repeatHeaders = ["Candidate", "Channel", "Handle", "Sampled videos", "Queries", "Median VPD", "Max VPD", "Max / median", "Public pattern", "Limit"];
repeat.getRange("A6:J6").values = [repeatHeaders]; header(repeat.getRange("A6:J6"));
const evidenceValues = evidence.map(r => [r.candidate, r.channel_name, r.channel_handle, num(r.sampled_videos), num(r.covered_queries), num(r.median_vpd), num(r.max_vpd), num(r.max_to_median_ratio), r.public_pattern, r.limit]);
repeat.getRange(`A7:J${6 + evidenceValues.length}`).values = evidenceValues; body(repeat.getRange(`A7:J${6 + evidenceValues.length}`));
repeat.getRange(`D7:H${6 + evidenceValues.length}`).format.numberFormat = "#,##0.0";
repeat.getRange(`I7:I${6 + evidenceValues.length}`).conditionalFormats.add("containsText", { text: "repeat_sampled", format: { fill: C.paleGreen, font: { color: C.green, bold: true } } });
widths(repeat, [["A:A", 29], ["B:B", 29], ["C:C", 25], ["D:H", 15], ["I:I", 25], ["J:J", 58]]); repeat.getRange(`J7:J${6 + evidenceValues.length}`).format.wrapText = true; repeat.freezePanes.freezeRows(6);

// Small independent audit of public cadence for two primary-candidate representatives.
setTitle(audit, "Primary-channel public audit", "Latest five public uploads for two high/middle observed-VPD representatives. A lower-VPD representative was not fetched because the platform quota stopped the request.", "H");
const history = [...branch, ...caleb].map(r => {
  const uploaded = date(r.upload_date_raw.replace(/(\d{4})(\d{2})(\d{2})/, "$1-$2-$3"));
  const ageDays = Math.max(7, Math.floor((new Date("2026-11-02T00:00:00Z") - uploaded) / 86400000));
  return [r.channel_name, r.channel_handle, uploaded, ageDays, num(r.views_snapshot), num(r.duration_seconds), Math.round((num(r.views_snapshot) / ageDays) * 100) / 100, r.title, r.video_url];
});
audit.getRange("A6:I6").values = [["Channel", "Handle", "Upload date", "Age days", "Views snapshot", "Duration sec", "VPD", "Title", "Video URL"]]; header(audit.getRange("A6:I6"));
audit.getRange(`A7:I${6 + history.length}`).values = history; body(audit.getRange(`A7:I${6 + history.length}`));
audit.getRange(`C7:C${6 + history.length}`).format.numberFormat = "yyyy-mm-dd";
audit.getRange(`D7:G${6 + history.length}`).format.numberFormat = "#,##0.0";
widths(audit, [["A:A", 24], ["B:B", 23], ["C:C", 14], ["D:G", 15], ["H:H", 60], ["I:I", 42]]); audit.getRange(`H7:H${6 + history.length}`).format.wrapText = true; audit.freezePanes.freezeRows(6);

workbook.recalculate();
const check = await workbook.inspect({ kind: "table", range: "Round 2 summary!A2:L16", include: "values,formulas", tableMaxRows: 20, tableMaxCols: 12 });
console.log("ROUND2_INSPECT", check.ndjson);
const errors = await workbook.inspect({ kind: "match", searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!", options: { useRegex: true, maxResults: 300 }, summary: "round 2 formula error scan" });
console.log("ROUND2_ERRORS", errors.ndjson);
for (const sheetName of ["Round 2 summary", "Round 2 observations", "Round 2 repeat evidence", "Round 2 audit"]) {
  const preview = await workbook.render({ sheetName, autoCrop: "all", scale: 1, format: "png" });
  await fs.writeFile(path.join(root, "01-bao-cao", "charts", `${safeName(sheetName)}.png`), new Uint8Array(await preview.arrayBuffer()));
}
const out = await SpreadsheetFile.exportXlsx(workbook);
await out.save(workbookPath);
console.log(`OUTPUT:${workbookPath}`);
