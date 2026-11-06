param(
    [string]$DataDir = "G:\research niches\02-data",
    [datetime]$AsOf = [datetime]'2026-11-02'
)

$ErrorActionPreference = "Stop"

function Get-Quantile {
    param([double[]]$Values, [double]$Quantile)
    $sorted = @($Values | Sort-Object)
    if ($sorted.Count -eq 0) { return $null }
    $position = ($sorted.Count - 1) * $Quantile
    $lower = [math]::Floor($position)
    $upper = [math]::Ceiling($position)
    if ($lower -eq $upper) { return [double]$sorted[$lower] }
    return [double]$sorted[$lower] + (($position - $lower) * ([double]$sorted[$upper] - [double]$sorted[$lower]))
}

$rows = Import-Csv -LiteralPath (Join-Path $DataDir "longform-enriched.csv")
$observations = foreach ($r in $rows) {
    $date = $null
    try { $date = [datetime]::ParseExact($r.upload_date_raw, 'yyyyMMdd', [Globalization.CultureInfo]::InvariantCulture) } catch {}
    if ($null -eq $date) { continue }
    $ageDays = [math]::Max(7, [math]::Floor(($AsOf - $date).TotalDays))
    [pscustomobject]@{
        source_query = $r.source_query
        video_id = $r.video_id
        channel_id = $r.channel_id
        channel_name = $r.channel_name
        channel_handle = $r.channel_handle
        title = $r.title
        upload_date = $date.ToString('yyyy-MM-dd')
        age_days = $ageDays
        duration_seconds = [int]$r.duration_seconds
        views_snapshot = [long]$r.views_snapshot
        views_per_day = [math]::Round(([double]$r.views_snapshot / $ageDays), 2)
        channel_subscribers_snapshot = [long]$r.channel_subscribers_snapshot
        video_url = $r.video_url
    }
}

$summary = foreach ($group in ($observations | Group-Object source_query | Sort-Object Name)) {
    $vpds = [double[]]@($group.Group | Select-Object -ExpandProperty views_per_day)
    [pscustomobject]@{
        source_query = $group.Name
        video_count = $group.Count
        median_vpd = [math]::Round((Get-Quantile $vpds 0.50), 2)
        p25_vpd = [math]::Round((Get-Quantile $vpds 0.25), 2)
        p75_vpd = [math]::Round((Get-Quantile $vpds 0.75), 2)
        min_vpd = [math]::Round(($vpds | Measure-Object -Minimum).Minimum, 2)
        max_vpd = [math]::Round(($vpds | Measure-Object -Maximum).Maximum, 2)
        age_days_median = [math]::Round((Get-Quantile ([double[]]@($group.Group | Select-Object -ExpandProperty age_days)) 0.50), 0)
    }
}

$byQuery = @{}
foreach ($s in $summary) { $byQuery[$s.source_query] = $s }
$tagged = foreach ($o in $observations) {
    $stats = $byQuery[$o.source_query]
    $outcome = if ($o.age_days -lt 14) { 'too_new_to_classify' }
    elseif ($o.views_per_day -le $stats.p25_vpd) { 'underperformer_video' }
    elseif ($o.views_per_day -ge $stats.p75_vpd) { 'high_traction_video' }
    else { 'middle_video' }
    $o | Add-Member -NotePropertyName video_outcome -NotePropertyValue $outcome -PassThru
}

$tagged | Export-Csv -LiteralPath (Join-Path $DataDir "video-observations.csv") -NoTypeInformation -Encoding UTF8
$summary | Export-Csv -LiteralPath (Join-Path $DataDir "query-baseline.csv") -NoTypeInformation -Encoding UTF8
$summary | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $DataDir "query-baseline.json") -Encoding UTF8
Write-Host "Wrote $(@($tagged).Count) video observations and $(@($summary).Count) query baselines."
