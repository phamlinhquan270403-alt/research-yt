import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const rootDir = "G:/research niches";
const dataDir = path.join(rootDir, "02-data");
const outputDir = path.join(rootDir, "01-bao-cao");
const outputPath = path.join(outputDir, "youtube_niche_data_report.xlsx");
const fontName = "Arial";
const colors = {
  navy: "#153B5B", blue: "#1F6E8C", paleBlue: "#EAF4FB", paleGreen: "#EAF7F0",
  green: "#277A54", amber: "#FFF4D6", amberText: "#7A5200", red: "#FDE9EA",
  redText: "#9B2431", gray: "#5E6B7A", line: "#D6E0EA", white: "#FFFFFF", ink: "#152536"
};

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
  const headers = rawHeaders.map(header => header.replace(/^\uFEFF/, ""));
  return records.filter(r => r.some(cell => cell !== "")).map(r => Object.fromEntries(headers.map((h, i) => [h, r[i] ?? ""])));
}

const asNumber = (value) => Number(value || 0);
const asDate = (value) => value ? new Date(`${value}T00:00:00Z`) : null;
const csv = async (name) => parseCsv(await fs.readFile(path.join(dataDir, name), "utf8"));

const [microthemes, outcomes, videos] = await Promise.all([
  csv("microtheme-summary.csv"),
  csv("channel-outcomes.csv"),
  csv("combined-video-observations.csv")
]);
const microByName = new Map(microthemes.map(row => [row.micro_theme, row]));

const candidates = [
  {
    candidate: "AI data-center & compute infrastructure", theme: "AI compute and hardware", status: "Primary candidate — review first",
    scores: [8.4, 7.4, 6.8, 7.5, 7.5, 9.5, 6.3], confidence: "Medium",
    note: "Use physical constraints: chips, power, cooling, water and network. Avoid general AI news."
  },
  {
    candidate: "Water & civic systems", theme: "Water utilities", status: "Backup 1 — evergreen", scores: [6.7, 6.5, 7.8, 9.0, 7.0, 9.0, 6.4], confidence: "Medium",
    note: "Strong evergreen/3D fit. Lower public-demand baseline means slower validation risk."
  },
  {
    candidate: "Business & economic mechanics visualized", theme: "Business and economics mechanics", status: "Backup 2 — speed", scores: [7.7, 6.5, 6.9, 9.0, 7.5, 6.5, 8.0], confidence: "Medium",
    note: "Evergreen and faster to ship; smaller technical moat than a physical-system niche."
  },
  {
    candidate: "3D engineered systems", theme: "3D how-it-works explainers", status: "Conditional — choose a domain", scores: [7.4, 6.5, 7.7, 8.1, 7.0, 10.0, 5.0], confidence: "Medium",
    note: "This is a strong delivery format, not a channel niche. Lock one domain before production."
  },
  {
    candidate: "Space & science animation", theme: "Space and science animation", status: "Hold — sample too small", scores: [9.5, 4.5, 7.2, 8.5, 6.5, 8.0, 4.7], confidence: "Low",
    note: "High VPD signal, but only 5 sampled videos / 4 channels. Do not use as a decision winner yet."
  },
  {
    candidate: "Aviation & logistics systems", theme: "Aviation and logistics systems", status: "Backup 3", scores: [6.8, 6.4, 6.2, 8.0, 6.5, 8.5, 6.5], confidence: "Medium",
    note: "Broad inventory of subjects; needs a tighter editorial promise than general explainers."
  },
  {
    candidate: "Cities, housing & urban design", theme: "Cities, housing and urban design", status: "Watchlist", scores: [6.1, 6.4, 6.0, 8.8, 6.5, 8.2, 7.0], confidence: "Medium",
    note: "Wide VPD spread and more topic/policy volatility. Avoid treating headline hits as baseline."
  },
  {
    candidate: "Internet & cybersecurity explainers", theme: "Internet and cybersecurity explainers", status: "Watchlist — authority pressure", scores: [8.1, 5.2, 4.2, 8.2, 8.0, 6.8, 7.0], confidence: "Low",
    note: "Demand appears strong but 83.3% media/institution share in sample raises authority/competition risk."
  }
];
const weights = [20, 20, 20, 15, 10, 10, 10];
const criteria = ["Demand / views", "New-channel entry proxy", "Competition proxy", "Durability", "Monetization fit", "Remotion / Three.js fit", "Production speed"];

function setBase(sheet) {
  sheet.showGridLines = false;
  sheet.getUsedRange().format.font = { name: fontName, size: 10, color: colors.ink };
}
function title(sheet, titleText, subtitle, endColumn = "H") {
  sheet.getRange("A2").values = [[titleText]];
  sheet.getRange("A2").format = { font: { name: fontName, size: 16, bold: true, color: colors.ink } };
  sheet.getRange(`A3:${endColumn}3`).merge();
  sheet.getRange("A3").values = [[subtitle]];
  sheet.getRange("A3").format = { font: { name: fontName, size: 10, italic: true, color: colors.gray } };
  sheet.getRange(`A4:${endColumn}4`).format.borders = { bottom: { style: "medium", color: colors.navy } };
}
function header(range) {
  range.format = {
    fill: colors.navy,
    font: { name: fontName, size: 10, bold: true, color: colors.white },
    horizontalAlignment: "center", verticalAlignment: "center", wrapText: true,
    borders: { preset: "all", style: "thin", color: colors.white }
  };
}
function bordered(range) {
  range.format.borders = { preset: "inside", style: "thin", color: colors.line };
  range.format.verticalAlignment = "center";
}
function limitWidth(sheet, cols) {
  for (const [range, width] of cols) sheet.getRange(range).format.columnWidth = width;
}
function safeFileName(name) { return name.replace(/[^A-Za-z0-9]+/g, "_").replace(/^_|_$/g, "").toLowerCase(); }

const workbook = Workbook.create();
const summary = workbook.worksheets.add("Summary");
const scorecard = workbook.worksheets.add("Scorecard");
const micro = workbook.worksheets.add("Microthemes");
const channel = workbook.worksheets.add("Channel outcomes");
const sample = workbook.worksheets.add("Public video sample");
const methods = workbook.worksheets.add("Methods & sources");
[summary, scorecard, micro, channel, sample, methods].forEach(setBase);
summary.tabColor = colors.navy; scorecard.tabColor = colors.blue;

// Scorecard is the calculation owner.
title(scorecard, "Niche scorecard", "Weights are the user's requested raw weights (sum 105). Weighted score is normalized to /10. Public-data gaps are explicit.", "L");
scorecard.getRange("A5").values = [["Raw weight"]];
scorecard.getRange("C5:I5").values = [weights];
scorecard.getRange("A5:I5").format = { fill: colors.paleBlue, font: { name: fontName, bold: true, color: colors.ink }, horizontalAlignment: "center" };
scorecard.getRange("A7:L7").values = [["Candidate", "Decision status", ...criteria, "Weighted score /10", "Confidence", "Evidence note"]];
header(scorecard.getRange("A7:L7"));
const scoreRows = candidates.map((c, index) => [
  c.candidate, c.status, ...c.scores, null, c.confidence, c.note
]);
scorecard.getRange(`A8:L${7 + candidates.length}`).values = scoreRows;
for (let r = 8; r < 8 + candidates.length; r += 1) {
  scorecard.getRange(`J${r}`).formulas = [[`=SUMPRODUCT(C${r}:I${r},$C$5:$I$5)/SUM($C$5:$I$5)`]];
}
bordered(scorecard.getRange(`A8:L${7 + candidates.length}`));
scorecard.getRange(`C8:J${7 + candidates.length}`).format.numberFormat = "0.0";
scorecard.getRange(`J8:J${7 + candidates.length}`).conditionalFormats.add("colorScale", { colors: ["#FDE9EA", "#FFF4D6", "#EAF7F0"], thresholds: ["min", { type: "percentile", value: 50 }, "max"] });
scorecard.getRange(`K8:K${7 + candidates.length}`).conditionalFormats.add("containsText", { text: "Low", format: { fill: colors.red, font: { color: colors.redText, bold: true } } });
scorecard.getRange(`K8:K${7 + candidates.length}`).conditionalFormats.add("containsText", { text: "Medium", format: { fill: colors.amber, font: { color: colors.amberText } } });
limitWidth(scorecard, [["A:A", 33], ["B:B", 25], ["C:J", 12], ["K:K", 12], ["L:L", 47]]);
scorecard.getRange("L8:L15").format.wrapText = true;
scorecard.getRange("A7:L15").format.rowHeight = 28;
scorecard.freezePanes.freezeRows(7);

// Summary links to finished scorecard calculations.
title(summary, "US faceless YouTube niche research", "Data-first shortlist. Long-form first; no prototype or production started. Public metadata snapshot: 02 Nov 2026.", "M");
summary.getRange("A6:C6").values = [["Recommended for approval", "AI data-center & compute infrastructure", "Primary candidate"]];
summary.getRange("A6:C6").format = { fill: colors.paleGreen, font: { name: fontName, bold: true, color: colors.green }, borders: { preset: "outside", style: "thin", color: colors.green } };
summary.getRange("A8:D8").values = [["Public-data scope", "171 long-form videos", "13 microthemes", "18 channel cohorts"]];
summary.getRange("A8:D8").format = { fill: colors.paleBlue, font: { name: fontName, bold: true, color: colors.ink }, horizontalAlignment: "center" };
summary.getRange("A10:D10").values = [["Outcome labels in cohort", "Public inactive", "Low-traction active", "Possible stall"]];
header(summary.getRange("A10:D10"));
summary.getRange("A11:D11").values = [["Count", null, null, null]];
summary.getRange("B11").formulas = [["=COUNTIF('Channel outcomes'!D7:D24,\"public_inactive\")"]];
summary.getRange("C11").formulas = [["=COUNTIF('Channel outcomes'!D7:D24,\"low_traction_active\")"]];
summary.getRange("D11").formulas = [["=COUNTIF('Channel outcomes'!D7:D24,\"possible_stall\")"]];
summary.getRange("A13:E13").values = [["Rank", "Candidate", "Weighted score /10", "Confidence", "Decision status"]];
header(summary.getRange("A13:E13"));
for (let i = 0; i < candidates.length; i += 1) {
  const r = 14 + i; const sc = 8 + i;
  summary.getRange(`A${r}`).formulas = [[`=RANK.EQ(C${r},$C$14:$C$21,0)`]];
  summary.getRange(`B${r}`).values = [[candidates[i].candidate]];
  summary.getRange(`C${r}`).formulas = [[`=Scorecard!J${sc}`]];
  summary.getRange(`D${r}`).formulas = [[`=Scorecard!K${sc}`]];
  summary.getRange(`E${r}`).formulas = [[`=Scorecard!B${sc}`]];
}
bordered(summary.getRange("A14:E21"));
summary.getRange("C14:C21").format.numberFormat = "0.0";
summary.getRange("C14:C21").conditionalFormats.add("colorScale", { colors: ["#FDE9EA", "#FFF4D6", "#EAF7F0"], thresholds: ["min", { type: "percentile", value: 50 }, "max"] });
summary.getRange("G6:M6").merge();
summary.getRange("G6").values = [["What the data cannot prove"]];
summary.getRange("G6").format = { fill: colors.amber, font: { name: fontName, bold: true, color: colors.amberText } };
summary.getRange("G7:M12").merge();
summary.getRange("G7").values = [["Public metadata cannot reveal RPM, CTR, retention, watch hours, subscriber conversion, actual country share, channel creation date, or YPP eligibility. “New-channel” and “competition” use stated proxies, not invented facts."]];
summary.getRange("G7").format = { fill: "#FFF9EA", font: { name: fontName, size: 10, color: colors.ink }, wrapText: true, verticalAlignment: "top" };
summary.getRange("G14:H14").values = [["Candidate", "Score"]];
summary.getRange("G15:H22").formulas = candidates.map((_, i) => [`=B${14 + i}`, `=C${14 + i}`]);
const chart = summary.charts.add("bar", summary.getRange("G14:H22"));
chart.title = "Weighted shortlist score";
chart.hasLegend = false;
chart.setPosition("G24", "M40");
limitWidth(summary, [["A:A", 25], ["B:B", 38], ["C:C", 16], ["D:D", 12], ["E:E", 30], ["F:F", 3], ["G:M", 14]]);
summary.getRange("B14:B21").format.wrapText = true;
summary.getRange("E14:E21").format.wrapText = true;
summary.getRange("A13:E21").format.rowHeight = 28;

// Microtheme public-data measurement table.
title(micro, "Microtheme public-data screen", "Query-routed public sample; metrics are not market census or US-audience estimates.", "L");
const microHeaders = ["Microtheme", "Sampled videos", "Unique channels", "Median VPD", "P25 VPD", "P75 VPD", "High-traction rate", "Media / institution share", "Tutorial / course share", "Oldest upload", "Newest upload", "Interpretation limit"];
micro.getRange("A6:L6").values = [microHeaders]; header(micro.getRange("A6:L6"));
const microValues = microthemes.map(row => [
  row.micro_theme, asNumber(row.sampled_videos), asNumber(row.unique_channels), asNumber(row.median_vpd), asNumber(row.p25_vpd), asNumber(row.p75_vpd), asNumber(row.high_traction_video_rate), asNumber(row.media_or_institution_share), asNumber(row.tutorial_or_course_share), asDate(row.oldest_upload), asDate(row.newest_upload), row.interpretation_limit
]);
micro.getRange(`A7:L${6 + microValues.length}`).values = microValues;
bordered(micro.getRange(`A7:L${6 + microValues.length}`));
micro.getRange(`B7:C${6 + microValues.length}`).format.numberFormat = "#,##0";
micro.getRange(`D7:F${6 + microValues.length}`).format.numberFormat = "#,##0.0";
micro.getRange(`G7:I${6 + microValues.length}`).format.numberFormat = "0.0%";
micro.getRange(`J7:K${6 + microValues.length}`).format.numberFormat = "yyyy-mm-dd";
micro.getRange(`D7:D${6 + microValues.length}`).conditionalFormats.add("dataBar", { color: colors.blue, gradient: true });
limitWidth(micro, [["A:A", 34], ["B:C", 13], ["D:F", 14], ["G:I", 16], ["J:K", 14], ["L:L", 54]]);
micro.getRange(`L7:L${6 + microValues.length}`).format.wrapText = true;
micro.freezePanes.freezeRows(6);

// Channel outcome cohort.
title(channel, "Channel outcome cohort", "Five latest public videos per channel where available. Labels describe observable outcome only — never financial failure or causal attribution.", "L");
channel.getRange("A5:L5").merge();
channel.getRange("A5").values = [["Outcome labels: public inactive = latest upload ≥180d; low-traction active = latest upload ≤90d and median VPD ≤ theme P25; possible stall = latest 2 VPD median ≤40% of prior 3. These are public-outcome labels, not causal or financial claims."]];
channel.getRange("A5").format = { fill: colors.amber, font: { name: fontName, size: 9, color: colors.amberText }, wrapText: true };
const channelHeaders = ["Channel", "Handle", "Theme", "Public outcome", "Latest upload", "Latest age (days)", "Median VPD", "Theme P25 VPD", "Latest 2 median VPD", "Prior 3 median VPD", "Observation note", "Channel URL"];
channel.getRange("A7:L7").values = [channelHeaders]; header(channel.getRange("A7:L7"));
const channelValues = outcomes.map(row => [
  row.channel_name, row.channel_handle, row.theme, row.public_outcome, asDate(row.latest_upload_date), asNumber(row.latest_upload_age_days), asNumber(row.median_views_per_day), asNumber(row.theme_p25_views_per_day), asNumber(row.latest_2_median_vpd), asNumber(row.previous_3_median_vpd), row.interpretation_limit, `https://www.youtube.com/${row.channel_handle}`
]);
channel.getRange(`A8:L${7 + channelValues.length}`).values = channelValues;
bordered(channel.getRange(`A8:L${7 + channelValues.length}`));
channel.getRange(`E8:E${7 + channelValues.length}`).format.numberFormat = "yyyy-mm-dd";
channel.getRange(`F8:J${7 + channelValues.length}`).format.numberFormat = "#,##0.0";
channel.getRange(`D8:D${7 + channelValues.length}`).conditionalFormats.add("containsText", { text: "public_inactive", format: { fill: colors.red, font: { color: colors.redText, bold: true } } });
channel.getRange(`D8:D${7 + channelValues.length}`).conditionalFormats.add("containsText", { text: "low_traction_active", format: { fill: colors.amber, font: { color: colors.amberText, bold: true } } });
limitWidth(channel, [["A:A", 26], ["B:B", 18], ["C:C", 28], ["D:D", 20], ["E:E", 14], ["F:J", 15], ["K:K", 44], ["L:L", 38]]);
channel.getRange(`K8:L${7 + channelValues.length}`).format.wrapText = true;
channel.freezePanes.freezeRows(7);

// Raw public video observation table.
title(sample, "Public video observations", "Deduplicated long-form public video sample. View count is a snapshot, not lifetime reach or channel performance.", "O");
const videoHeaders = ["Microtheme", "Source query", "Video ID", "Channel ID", "Channel", "Handle", "Source type", "Title", "Upload date", "Age days", "Duration seconds", "Views snapshot", "Views / day", "Scope", "Video URL"];
sample.getRange("A6:O6").values = [videoHeaders]; header(sample.getRange("A6:O6"));
const videoValues = videos.map(row => [
  row.micro_theme, row.source_query, row.video_id, row.channel_id, row.channel_name, row.channel_handle, row.source_type, row.title, asDate(row.upload_date), asNumber(row.age_days), asNumber(row.duration_seconds), asNumber(row.views_snapshot), asNumber(row.views_per_day), row.format_scope, row.video_url
]);
sample.getRange(`A7:O${6 + videoValues.length}`).values = videoValues;
bordered(sample.getRange(`A7:O${6 + videoValues.length}`));
sample.getRange(`I7:I${6 + videoValues.length}`).format.numberFormat = "yyyy-mm-dd";
sample.getRange(`J7:M${6 + videoValues.length}`).format.numberFormat = "#,##0.0";
limitWidth(sample, [["A:A", 30], ["B:B", 33], ["C:D", 20], ["E:E", 22], ["F:F", 18], ["G:G", 20], ["H:H", 58], ["I:I", 14], ["J:M", 15], ["N:N", 28], ["O:O", 42]]);
sample.getRange(`H7:H${6 + videoValues.length}`).format.wrapText = true;
sample.freezePanes.freezeRows(6);

// Methods and sources: citations adjacent to data/method inputs.
title(methods, "Methods & sources", "Definitions, source links and non-negotiable limits for this preliminary research report.", "G");
methods.getRange("A6:C6").values = [["Method component", "Implementation", "Limit"]]; header(methods.getRange("A6:C6"));
methods.getRange("A7:C10").values = [
  ["Discovery", "36 English / US-intent public queries across systems, infrastructure, economics and animation.", "Search-routed sample; not a market census."],
  ["Video filter", "Public videos enriched and retained when duration is at least 480 seconds; deduplicated by video ID.", "Does not measure actual US audience share."],
  ["VPD", "Public view snapshot divided by max(7, age in days).", "Not retention, impressions, CTR, watch hours, RPM or revenue."],
  ["Outcome cohort", "18 channels, five latest public videos where available. Labels use published dates and VPD patterns only.", "Cannot identify financial failure, motivation, YPP status or causal reasons."]
];
bordered(methods.getRange("A7:C10"));
methods.getRange("A12:C12").values = [["Official source", "URL", "Why it matters"]]; header(methods.getRange("A12:C12"));
methods.getRange("A13:C16").values = [
  ["YouTube Partner Program overview", "https://support.google.com/youtube/answer/94522?hl=en", "Current ad-revenue eligibility overview."],
  ["YPP changes effective 01 Feb 2027", "https://support.google.com/youtube/answer/12843009?hl=en", "Target date may cross a higher future entry threshold."],
  ["YouTube monetization policies", "https://support.google.com/youtube/answer/1311392?hl=en", "Original/authentic content requirement; avoid mass-produced or repetitive output."],
  ["Advertiser-friendly content guidelines", "https://support.google.com/youtube/answer/6162278?hl=en", "Policy risk belongs in monetization scoring."]
];
bordered(methods.getRange("A13:C16"));
methods.getRange("A18:C18").merge();
methods.getRange("A18").values = [["Required data to raise confidence: YouTube Data API channel/upload history, keyword demand source, and post-publish internal analytics (impressions, CTR, AVD, watch hours, subscriber conversion). Gemini key is not required for public metadata collection."]];
methods.getRange("A18").format = { fill: colors.paleBlue, font: { name: fontName, size: 10, color: colors.ink }, wrapText: true, verticalAlignment: "top" };
limitWidth(methods, [["A:A", 31], ["B:B", 65], ["C:C", 57], ["D:G", 3]]);
methods.getRange("A7:C16").format.wrapText = true;

workbook.recalculate();

const inspection = await workbook.inspect({ kind: "table", range: "Summary!A2:M21", include: "values,formulas", tableMaxRows: 22, tableMaxCols: 13 });
console.log("SUMMARY_INSPECT", inspection.ndjson);
const formulaErrors = await workbook.inspect({ kind: "match", searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!", options: { useRegex: true, maxResults: 300 }, summary: "final formula error scan" });
console.log("FORMULA_ERRORS", formulaErrors.ndjson);

await fs.mkdir(outputDir, { recursive: true });
for (const sheetName of ["Summary", "Scorecard", "Microthemes", "Channel outcomes", "Public video sample", "Methods & sources"]) {
  const preview = await workbook.render({ sheetName, autoCrop: "all", scale: 1, format: "png" });
  await fs.writeFile(path.join(outputDir, "charts", `${safeFileName(sheetName)}.png`), new Uint8Array(await preview.arrayBuffer()));
}
const xlsx = await SpreadsheetFile.exportXlsx(workbook);
await xlsx.save(outputPath);
console.log(`OUTPUT:${outputPath}`);
