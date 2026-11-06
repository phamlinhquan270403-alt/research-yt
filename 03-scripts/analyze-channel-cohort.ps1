param(
    [string]$DataDir = "G:\research niches\02-data",
    [datetime]$AsOf = [datetime]'2026-11-02'
)

$ErrorActionPreference = 'Stop'

function Get-Quantile {
    param([double[]]$Values, [double]$Quantile)
    $sorted = @($Values | Sort-Object)
    if ($sorted.Count -eq 0) { return $null }
    $pos = ($sorted.Count - 1) * $Quantile
    $lo = [math]::Floor($pos); $hi = [math]::Ceiling($pos)
    if ($lo -eq $hi) { return [double]$sorted[$lo] }
    return [double]$sorted[$lo] + (($pos - $lo) * ([double]$sorted[$hi] - [double]$sorted[$lo]))
}

$raw = Import-Csv -LiteralPath (Join-Path $DataDir 'channel-cohort-raw.csv')
$obs = foreach ($r in $raw) {
    $published = $null
    try { $published = [datetime]::ParseExact($r.upload_date_raw, 'yyyyMMdd', [Globalization.CultureInfo]::InvariantCulture) } catch {}
    if ($null -eq $published) { continue }
    $age = [math]::Max(7, [math]::Floor(($AsOf - $published).TotalDays))
    [pscustomobject]@{
        channel_handle = $r.channel_handle
        channel_name = $r.channel_name
        theme = $r.theme
        sampled_for = $r.sampled_for
        video_id = $r.video_id
        title = $r.title
        upload_date = $published.ToString('yyyy-MM-dd')
        age_days = $age
        duration_seconds = [int]$r.duration_seconds
        views_snapshot = [long]$r.views_snapshot
        views_per_day = [math]::Round(([double]$r.views_snapshot / $age), 2)
        video_url = $r.video_url
    }
}

$themeP25 = @{}
foreach ($g in ($obs | Group-Object theme)) {
    $themeP25[$g.Name] = Get-Quantile ([double[]]@($g.Group | Select-Object -ExpandProperty views_per_day)) 0.25
}

$channels = foreach ($g in ($obs | Group-Object channel_handle)) {
    $videos = @($g.Group | Sort-Object upload_date -Descending)
    $vpds = [double[]]@($videos | Select-Object -ExpandProperty views_per_day)
    $latestAge = [int]$videos[0].age_days
    $medianVpd = Get-Quantile $vpds 0.50
    $theme = $videos[0].theme
    $olderToNewer = @($videos | Sort-Object upload_date)
    $gaps = @()
    for ($i = 1; $i -lt $olderToNewer.Count; $i++) {
        $d1 = [datetime]$olderToNewer[$i-1].upload_date
        $d2 = [datetime]$olderToNewer[$i].upload_date
        $gaps += ($d2 - $d1).Days
    }
    $medianGap = if ($gaps.Count) { Get-Quantile ([double[]]$gaps) 0.50 } else { $null }
    $latestTwo = [double[]]@($videos | Select-Object -First 2 | Select-Object -ExpandProperty views_per_day)
    $previous = [double[]]@($videos | Select-Object -Skip 2 | Select-Object -ExpandProperty views_per_day)
    $recentMedian = if ($latestTwo.Count) { Get-Quantile $latestTwo 0.50 } else { $null }
    $previousMedian = if ($previous.Count) { Get-Quantile $previous 0.50 } else { $null }
    $outcome = 'insufficient_data'
    if ($latestAge -ge 180) { $outcome = 'public_inactive' }
    elseif ($latestAge -le 90 -and $medianVpd -le $themeP25[$theme]) { $outcome = 'low_traction_active' }
    elseif ($latestAge -le 90 -and $previousMedian -gt 0 -and $recentMedian -le (0.4 * $previousMedian)) { $outcome = 'possible_stall' }
    elseif ($latestAge -le 90) { $outcome = 'active_or_mixed' }
    [pscustomobject]@{
        channel_handle = $g.Name
        channel_name = $videos[0].channel_name
        theme = $theme
        sampled_for = $videos[0].sampled_for
        sampled_videos = $videos.Count
        latest_upload_date = $videos[0].upload_date
        latest_upload_age_days = $latestAge
        median_views_per_day = [math]::Round($medianVpd, 2)
        theme_p25_views_per_day = [math]::Round($themeP25[$theme], 2)
        latest_2_median_vpd = if ($null -ne $recentMedian) { [math]::Round($recentMedian, 2) } else { $null }
        previous_3_median_vpd = if ($null -ne $previousMedian) { [math]::Round($previousMedian, 2) } else { $null }
        median_upload_gap_days = if ($null -ne $medianGap) { [math]::Round($medianGap, 1) } else { $null }
        public_outcome = $outcome
        interpretation_limit = 'Public metadata only. Not revenue, YPP status, retention, CTR, or causal explanation.'
    }
}

$channels | Export-Csv -LiteralPath (Join-Path $DataDir 'channel-outcomes.csv') -NoTypeInformation -Encoding UTF8
$obs | Export-Csv -LiteralPath (Join-Path $DataDir 'channel-cohort-observations.csv') -NoTypeInformation -Encoding UTF8
$outcomes = $channels | Group-Object public_outcome | ForEach-Object { [pscustomobject]@{ public_outcome=$_.Name; channel_count=$_.Count } }
$outcomes | Export-Csv -LiteralPath (Join-Path $DataDir 'channel-outcome-summary.csv') -NoTypeInformation -Encoding UTF8
Write-Host "Wrote $(@($obs).Count) channel-video rows and $(@($channels).Count) channel outcomes."
