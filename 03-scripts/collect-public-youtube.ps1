param(
    [string]$OutDir = "G:\research niches\02-data",
    [int]$LimitPerQuery = 10,
    [string]$QueryFile = "",
    [string]$OutputPrefix = "discovery",
    [int]$StartIndex = 0,
    [int]$MaxQueryCount = 0
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Broad discovery universe for adult, English long-form explainers that could
# plausibly use code-driven visuals. These are coverage queries, not niches
# selected in advance.
$defaultQueries = @(
    "how systems work animation explained",
    "science animation explained",
    "technology 3d animation explained",
    "business economics explained",
    "map data visualization explained",
    "city urban planning explained",
    "personal finance animation explained",
    "cybersecurity internet explained",
    "space astronomy animation explained",
    "history animated map explained",
    "airports aviation explained",
    "logistics supply chain explained",
    "energy grid explained",
    "water system explained",
    "data center AI chips explained",
    "housing costs explained",
    "manufacturing process explained",
    "climate technology explained"
)
$queries = if ([string]::IsNullOrWhiteSpace($QueryFile)) { $defaultQueries } else {
    Get-Content -LiteralPath $QueryFile | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_) -and -not $_.TrimStart().StartsWith('#')
    }
}
if ($StartIndex -gt 0) { $queries = @($queries | Select-Object -Skip $StartIndex) }
if ($MaxQueryCount -gt 0) { $queries = @($queries | Select-Object -First $MaxQueryCount) }

$snapshotAt = (Get-Date).ToUniversalTime().ToString("o")
$printTemplate = "%(id)s`t%(channel_id)s`t%(channel)s`t%(uploader_id)s`t%(title)s`t%(duration)s`t%(view_count)s`t%(upload_date)s`t%(webpage_url)s"
$records = [System.Collections.Generic.List[object]]::new()
$errors = [System.Collections.Generic.List[object]]::new()

foreach ($query in $queries) {
    Write-Host "Searching: $query" -ForegroundColor Cyan
    # `ytsearch` is the cross-version pseudo-URL supported by the installed
    # yt-dlp build. Sort order is recorded as relevance and handled later by
    # sampling across query families rather than claimed as chronological.
    $searchUrl = "ytsearch$LimitPerQuery`:$query"
    try {
        $lines = & yt-dlp --flat-playlist --skip-download --no-warnings --ignore-errors --print $printTemplate $searchUrl 2>$null
        foreach ($line in $lines) {
            $p = $line -split "`t", 9
            if ($p.Count -ne 9 -or [string]::IsNullOrWhiteSpace($p[0])) { continue }
            $duration = 0; $views = 0
            [void][int]::TryParse($p[5], [ref]$duration)
            [void][long]::TryParse($p[6], [ref]$views)
            $records.Add([pscustomobject]@{
                snapshot_at = $snapshotAt
                source_query = $query
                source_mode = "ytsearch"
                video_id = $p[0]
                channel_id = $p[1]
                channel_name = $p[2]
                channel_handle = $p[3]
                title = $p[4]
                duration_seconds = $duration
                views_snapshot = $views
                upload_date_raw = $p[7]
                video_url = $p[8]
            })
        }
    } catch {
        $errors.Add([pscustomobject]@{ source_query = $query; error = $_.Exception.Message })
    }
}

$unique = $records | Sort-Object video_id -Unique
$unique | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $OutDir "$OutputPrefix-raw.json") -Encoding UTF8
$unique | Export-Csv -LiteralPath (Join-Path $OutDir "$OutputPrefix-raw.csv") -NoTypeInformation -Encoding UTF8
$queries | Set-Content -LiteralPath (Join-Path $OutDir "$OutputPrefix-query-universe.txt") -Encoding UTF8
$errors | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $OutDir "$OutputPrefix-collection-errors.json") -Encoding UTF8

$summary = [pscustomobject]@{
    snapshot_at = $snapshotAt
    query_count = $queries.Count
    rows_before_dedupe = $records.Count
    unique_video_count = @($unique).Count
    unique_channel_count = @($unique | Where-Object { $_.channel_id } | Select-Object -ExpandProperty channel_id -Unique).Count
    collection_error_count = $errors.Count
}
$summary | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $OutDir "$OutputPrefix-summary.json") -Encoding UTF8
Write-Host ($summary | ConvertTo-Json -Compress)
