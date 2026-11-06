param(
    [string]$DataDir = "G:\research niches\02-data",
    [int]$MinDurationSeconds = 480,
    [string]$InputCsv = "discovery-raw.csv",
    [string]$OutputPrefix = "longform-enriched",
    [int]$StartIndex = 0,
    [int]$MaxItems = 0
)

$ErrorActionPreference = "Stop"
$source = Import-Csv -LiteralPath (Join-Path $DataDir $InputCsv) |
    Where-Object { [int]$_.duration_seconds -ge $MinDurationSeconds }
if ($StartIndex -gt 0) { $source = @($source | Select-Object -Skip $StartIndex) }
if ($MaxItems -gt 0) { $source = @($source | Select-Object -First $MaxItems) }

$snapshotAt = (Get-Date).ToUniversalTime().ToString("o")
$printTemplate = "%(id)s`t%(channel_id)s`t%(channel)s`t%(uploader_id)s`t%(title)s`t%(duration)s`t%(view_count)s`t%(upload_date)s`t%(timestamp)s`t%(channel_follower_count)s`t%(like_count)s`t%(comment_count)s`t%(webpage_url)s"
$out = [System.Collections.Generic.List[object]]::new()
$errors = [System.Collections.Generic.List[object]]::new()
$seen = @{}

foreach ($item in $source) {
    if ($seen.ContainsKey($item.video_id)) { continue }
    $seen[$item.video_id] = $true
    Write-Host "Enriching: $($item.video_id)" -ForegroundColor Cyan
    try {
        $lines = & yt-dlp --skip-download --no-playlist --no-warnings --ignore-errors --print $printTemplate $item.video_url 2>$null
        $line = @($lines | Where-Object { $_ })[0]
        $p = $line -split "`t", 13
        if ($p.Count -ne 13 -or [string]::IsNullOrWhiteSpace($p[0])) { throw "No usable metadata returned" }
        $duration = 0; $views = 0; $timestamp = 0; $subs = 0; $likes = 0; $comments = 0
        [void][int]::TryParse($p[5], [ref]$duration)
        [void][long]::TryParse($p[6], [ref]$views)
        [void][long]::TryParse($p[8], [ref]$timestamp)
        [void][long]::TryParse($p[9], [ref]$subs)
        [void][long]::TryParse($p[10], [ref]$likes)
        [void][long]::TryParse($p[11], [ref]$comments)
        $out.Add([pscustomobject]@{
            snapshot_at = $snapshotAt
            source_query = $item.source_query
            video_id = $p[0]
            channel_id = $p[1]
            channel_name = $p[2]
            channel_handle = $p[3]
            title = $p[4]
            duration_seconds = $duration
            views_snapshot = $views
            upload_date_raw = $p[7]
            upload_timestamp = $timestamp
            channel_subscribers_snapshot = $subs
            likes_snapshot = $likes
            comments_snapshot = $comments
            video_url = $p[12]
        })
    } catch {
        $errors.Add([pscustomobject]@{ video_id = $item.video_id; video_url = $item.video_url; error = $_.Exception.Message })
    }
}

$out | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $DataDir "$OutputPrefix.json") -Encoding UTF8
$out | Export-Csv -LiteralPath (Join-Path $DataDir "$OutputPrefix.csv") -NoTypeInformation -Encoding UTF8
$errors | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $DataDir "$OutputPrefix-errors.json") -Encoding UTF8

$summary = [pscustomobject]@{
    snapshot_at = $snapshotAt
    input_longform_count = @($source).Count
    enriched_count = $out.Count
    enrichment_error_count = $errors.Count
}
$summary | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $DataDir "$OutputPrefix-summary.json") -Encoding UTF8
Write-Host ($summary | ConvertTo-Json -Compress)
