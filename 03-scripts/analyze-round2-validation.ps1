param(
    [string]$DataDir = "G:\research niches\02-data",
    [datetime]$AsOf = [datetime]'2026-11-02'
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

$target = Import-Csv -LiteralPath (Join-Path $DataDir 'round2-enrichment-target.csv')
$targetById = @{}
foreach ($row in $target) { $targetById[$row.video_id] = $row }
$inputFiles = 1..6 | ForEach-Object { Join-Path $DataDir "round2-enriched-batch-$_.csv" } | Where-Object { Test-Path -LiteralPath $_ }
if (@($inputFiles).Count -ne 6) { throw 'Expected six completed enriched batch CSV files.' }
$rawEnriched = foreach ($file in $inputFiles) { Import-Csv -LiteralPath $file }

$observations = foreach ($row in ($rawEnriched | Sort-Object video_id -Unique)) {
    $targetRow = $targetById[$row.video_id]
    if ($null -eq $targetRow) { continue }
    $published = $null
    try { $published = [datetime]::ParseExact($row.upload_date_raw, 'yyyyMMdd', [Globalization.CultureInfo]::InvariantCulture) } catch {}
    if ($null -eq $published) { continue }
    $age = [math]::Max(7, [math]::Floor(($AsOf - $published).TotalDays))
    [pscustomobject]@{
        candidate = $targetRow.candidate
        sample_role = $targetRow.sample_role
        source_query = $targetRow.source_query
        video_id = $row.video_id
        channel_id = $row.channel_id
        channel_name = $row.channel_name
        channel_handle = $row.channel_handle
        title = $row.title
        upload_date = $published.ToString('yyyy-MM-dd')
        age_days = $age
        duration_seconds = [int]$row.duration_seconds
        views_snapshot = [long]$row.views_snapshot
        views_per_day = [math]::Round(([double]$row.views_snapshot / $age), 2)
        channel_subscribers_snapshot = [long]$row.channel_subscribers_snapshot
        likes_snapshot = [long]$row.likes_snapshot
        comments_snapshot = [long]$row.comments_snapshot
        is_tutorial_signal = ($targetRow.is_tutorial_signal -eq 'True')
        video_url = $row.video_url
    }
}

$candidateSummary = foreach ($group in ($observations | Group-Object candidate | Sort-Object Name)) {
    $vpd = [double[]]@($group.Group | Select-Object -ExpandProperty views_per_day)
    $channelGroups = @($group.Group | Group-Object channel_id)
    $repeat = @($channelGroups | Where-Object { $_.Count -ge 2 })
    $recent = @($group.Group | Where-Object { $_.age_days -le 365 })
    [pscustomobject]@{
        candidate = $group.Name
        enriched_videos = $group.Count
        unique_channels = $channelGroups.Count
        covered_queries = @($group.Group | Select-Object -ExpandProperty source_query -Unique).Count
        median_vpd = [math]::Round((Get-Quantile $vpd 0.5), 2)
        p25_vpd = [math]::Round((Get-Quantile $vpd 0.25), 2)
        p75_vpd = [math]::Round((Get-Quantile $vpd 0.75), 2)
        recent_365d_videos = $recent.Count
        median_recent_vpd = if ($recent.Count -gt 0) { [math]::Round((Get-Quantile ([double[]]@($recent | Select-Object -ExpandProperty views_per_day)) 0.5), 2) } else { $null }
        tutorial_course_share = [math]::Round((@($group.Group | Where-Object { $_.is_tutorial_signal }).Count / $group.Count), 3)
        repeat_evidence_channels = $repeat.Count
        interpretation_limit = 'Balanced query-level sample, not a market census. Channel age, audience geography, retention, CTR, RPM and watch hours are not public.'
    }
}

$querySummary = foreach ($group in ($observations | Group-Object candidate,source_query | Sort-Object Name)) {
    $vpd = [double[]]@($group.Group | Select-Object -ExpandProperty views_per_day)
    [pscustomobject]@{
        candidate = $group.Group[0].candidate
        source_query = $group.Group[0].source_query
        enriched_videos = $group.Count
        median_vpd = [math]::Round((Get-Quantile $vpd 0.5), 2)
        max_vpd = [math]::Round(($vpd | Measure-Object -Maximum).Maximum, 2)
        min_vpd = [math]::Round(($vpd | Measure-Object -Minimum).Minimum, 2)
        recent_365d_videos = @($group.Group | Where-Object { $_.age_days -le 365 }).Count
    }
}

$channelEvidence = foreach ($group in ($observations | Group-Object candidate,channel_id | Sort-Object Name)) {
    $vpd = [double[]]@($group.Group | Select-Object -ExpandProperty views_per_day)
    $median = Get-Quantile $vpd 0.5
    $max = ($vpd | Measure-Object -Maximum).Maximum
    [pscustomobject]@{
        candidate = $group.Group[0].candidate
        channel_id = $group.Group[0].channel_id
        channel_name = $group.Group[0].channel_name
        channel_handle = $group.Group[0].channel_handle
        sampled_videos = $group.Count
        covered_queries = @($group.Group | Select-Object -ExpandProperty source_query -Unique).Count
        median_vpd = [math]::Round($median, 2)
        max_vpd = [math]::Round($max, 2)
        max_to_median_ratio = [math]::Round(($max / [math]::Max(1, $median)), 2)
        public_pattern = if ($group.Count -ge 2 -and ($max / [math]::Max(1, $median)) -ge 5) { 'one_hit_proxy' } elseif ($group.Count -ge 2) { 'repeat_sampled' } else { 'insufficient_repeat_evidence' }
        limit = 'Only candidate-query observations. Not channel-wide traction or a financial outcome.'
    }
}

# Select three distinct channels per candidate for an independent, current
# upload-history audit: high, middle and lower observed VPD. This is a
# stratified follow-up, not a claim that the lower channel has failed.
$cohort = [System.Collections.Generic.List[object]]::new()
foreach ($group in ($observations | Group-Object candidate | Sort-Object Name)) {
    $uniqueByChannel = @($group.Group | Sort-Object views_per_day -Descending | Group-Object channel_id | ForEach-Object { $_.Group | Select-Object -First 1 })
    $ordered = @($uniqueByChannel | Sort-Object views_per_day -Descending)
    $orderedCount = @($ordered).Count
    if ($orderedCount -eq 0) { continue }
    $positions = @(0, [math]::Floor(($orderedCount - 1) / 2), ($orderedCount - 1)) | Select-Object -Unique
    foreach ($position in $positions) {
        $item = $ordered[$position]
        if ([string]::IsNullOrWhiteSpace($item.channel_handle)) { continue }
        $cohort.Add([pscustomobject]@{
            candidate = $item.candidate
            audit_role = if ($position -eq 0) { 'higher_observed_vpd' } elseif ($position -eq ($orderedCount - 1)) { 'lower_observed_vpd' } else { 'middle_observed_vpd' }
            channel_handle = $item.channel_handle
            channel_name = $item.channel_name
            source_video_id = $item.video_id
            source_video_title = $item.title
            source_video_vpd = $item.views_per_day
            selection_limit = 'Selected from an 8-query public sample. It is not a statement of channel-wide success or failure.'
        })
    }
}

$observations | Export-Csv -LiteralPath (Join-Path $DataDir 'round2-enriched-observations.csv') -NoTypeInformation -Encoding UTF8
$candidateSummary | Export-Csv -LiteralPath (Join-Path $DataDir 'round2-validated-candidate-summary.csv') -NoTypeInformation -Encoding UTF8
$querySummary | Export-Csv -LiteralPath (Join-Path $DataDir 'round2-query-summary.csv') -NoTypeInformation -Encoding UTF8
$channelEvidence | Export-Csv -LiteralPath (Join-Path $DataDir 'round2-channel-evidence.csv') -NoTypeInformation -Encoding UTF8
$cohort | Export-Csv -LiteralPath (Join-Path $DataDir 'round2-cohort-selection.csv') -NoTypeInformation -Encoding UTF8
[pscustomobject]@{ enriched_observations=$observations.Count; candidates=$candidateSummary.Count; followup_channels=$cohort.Count } | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $DataDir 'round2-analysis-summary.json') -Encoding UTF8
Write-Host "Wrote $($observations.Count) enriched observations and $($cohort.Count) channel follow-up selections."
