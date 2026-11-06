param(
    [string]$DataDir = "G:\research niches\02-data",
    [datetime]$AsOf = [datetime]'2026-11-02',
    [int]$MinDurationSeconds = 480
)

$ErrorActionPreference = 'Stop'

function Get-Quantile {
    param([double[]]$Values, [double]$Quantile)
    $sorted = @($Values | Sort-Object)
    if ($sorted.Count -eq 0) { return $null }
    $position = ($sorted.Count - 1) * $Quantile
    $low = [math]::Floor($position); $high = [math]::Ceiling($position)
    if ($low -eq $high) { return [double]$sorted[$low] }
    return [double]$sorted[$low] + (($position - $low) * ([double]$sorted[$high] - [double]$sorted[$low]))
}

function Get-Candidate([string]$Query) {
    $q = $Query.ToLowerInvariant()
    if ($q -match 'make money|why container shipping|electricity markets|warehouse logistics|credit card') { return 'Business mechanics' }
    if ($q -match 'ai data|data center|gpu|ai inference|semiconductor|ai needs|fiber network') { return 'AI compute infrastructure' }
    if ($q -match 'water|wastewater|stormwater') { return 'Water and civic systems' }
    if ($q -match 'transformer|jet engine|electric vehicle|hvac|factories|cranes|cargo ports|substations') { return '3D engineered systems' }
    return 'Unclassified'
}

$inputFiles = 1..4 | ForEach-Object { Join-Path $DataDir "round2-batch-$_-raw.csv" } | Where-Object { Test-Path -LiteralPath $_ }
if (@($inputFiles).Count -ne 4) { throw 'Expected four completed round2 batch CSV files.' }
$raw = foreach ($file in $inputFiles) { Import-Csv -LiteralPath $file }
$deduped = @($raw | Sort-Object video_id -Unique)

$frame = foreach ($row in $deduped) {
    # Search-listing metadata often returns upload date as NA. Direct enrichment
    # is intentionally delayed to the balanced target sample below.
    $text = "$($row.title) $($row.channel_name)".ToLowerInvariant()
    [pscustomobject]@{
        candidate = Get-Candidate $row.source_query
        source_query = $row.source_query
        video_id = $row.video_id
        channel_id = $row.channel_id
        channel_name = $row.channel_name
        channel_handle = $row.channel_handle
        title = $row.title
        upload_date = ''
        age_days = $null
        duration_seconds = [int]$row.duration_seconds
        views_snapshot = [long]$row.views_snapshot
        views_per_day = $null
        is_kids_signal = $text -match 'kids|children|dr\. binocs|learn bright|peekaboo'
        is_tutorial_signal = $text -match 'tutorial|course|lesson|training|full course|lecture'
        video_url = $row.video_url
    }
}

$eligible = @($frame | Where-Object { $_.candidate -ne 'Unclassified' -and -not $_.is_kids_signal -and $_.duration_seconds -ge $MinDurationSeconds })
$summary = foreach ($group in ($eligible | Group-Object candidate | Sort-Object Name)) {
    [pscustomobject]@{
        candidate = $group.Name
        sampled_videos = $group.Count
        unique_channels = @($group.Group | Select-Object -ExpandProperty channel_id -Unique).Count
        covered_queries = @($group.Group | Select-Object -ExpandProperty source_query -Unique).Count
        vpd_status = 'Requires direct enrichment for published date and VPD'
        tutorial_course_share = [math]::Round((@($group.Group | Where-Object { $_.is_tutorial_signal }).Count / $group.Count), 3)
        limit = 'ytsearch relevance-routed public sample. Direct enrichment is required for publish dates and VPD; not a keyword census, retention, RPM or US-audience share.'
    }
}

# Choose one high-view-snapshot and one median-view-snapshot candidate per
# query. This preserves query coverage and deliberately includes non-winner
# observations for direct enrichment. The selection is not a VPD conclusion.
$target = [System.Collections.Generic.List[object]]::new()
$seen = @{}
foreach ($group in ($eligible | Group-Object candidate,source_query)) {
    $ordered = @($group.Group | Sort-Object views_snapshot -Descending)
    if ($ordered.Count -eq 0) { continue }
    $positions = @(0, [math]::Floor(($ordered.Count - 1) / 2)) | Select-Object -Unique
    foreach ($position in $positions) {
        $item = $ordered[$position]
        if ($seen.ContainsKey($item.video_id)) { continue }
        $seen[$item.video_id] = $true
        $target.Add([pscustomobject]@{
            candidate = $item.candidate
            sample_role = if ($position -eq 0) { 'query_high_views_provisional' } else { 'query_median_views_provisional' }
            source_query = $item.source_query
            video_id = $item.video_id
            channel_id = $item.channel_id
            channel_name = $item.channel_name
            channel_handle = $item.channel_handle
            title = $item.title
            upload_date = $item.upload_date
            age_days = $item.age_days
            duration_seconds = $item.duration_seconds
            views_snapshot = $item.views_snapshot
            views_per_day = $item.views_per_day
            is_tutorial_signal = $item.is_tutorial_signal
            video_url = $item.video_url
        })
    }
}

$deduped | Export-Csv -LiteralPath (Join-Path $DataDir 'round2-raw-combined.csv') -NoTypeInformation -Encoding UTF8
$eligible | Export-Csv -LiteralPath (Join-Path $DataDir 'round2-longform-frame.csv') -NoTypeInformation -Encoding UTF8
$summary | Export-Csv -LiteralPath (Join-Path $DataDir 'round2-candidate-summary.csv') -NoTypeInformation -Encoding UTF8
$target | Export-Csv -LiteralPath (Join-Path $DataDir 'round2-enrichment-target.csv') -NoTypeInformation -Encoding UTF8
$summary | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $DataDir 'round2-candidate-summary.json') -Encoding UTF8
[pscustomobject]@{ raw_unique_videos=$deduped.Count; eligible_longform_videos=$eligible.Count; enrichment_target_videos=$target.Count; candidate_count=$summary.Count } | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $DataDir 'round2-frame-summary.json') -Encoding UTF8
Write-Host "Wrote $($eligible.Count) eligible long-form observations and $($target.Count) enrichment targets."
