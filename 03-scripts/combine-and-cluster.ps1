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

function Get-MicroTheme([string]$Query) {
    $q = $Query.ToLowerInvariant()
    if ($q -match 'water|wastewater') { return 'Water utilities' }
    if ($q -match 'power grid|electric grid|energy grid') { return 'Energy grid and electricity' }
    if ($q -match 'city|cities|housing|urban') { return 'Cities, housing and urban design' }
    if ($q -match 'airport|aviation|cargo|supply chain|logistics') { return 'Aviation and logistics systems' }
    if ($q -match 'data center|gpu|ai chips|semiconductor') { return 'AI compute and hardware' }
    if ($q -match 'personal finance') { return 'Personal finance education' }
    if ($q -match 'business|economics|companies make money') { return 'Business and economics mechanics' }
    if ($q -match 'history|animated map') { return 'History and animated maps' }
    if ($q -match 'space|science') { return 'Space and science animation' }
    if ($q -match 'cybersecurity') { return 'Internet and cybersecurity explainers' }
    if ($q -match 'climate') { return 'Climate technology' }
    if ($q -match 'manufacturing|systems work|technology 3d') { return '3D how-it-works explainers' }
    return 'Unclassified'
}

function Get-SourceType([string]$Channel) {
    if ($Channel -match 'TED|CNN|CNBC|BBC|Netflix|IBM|Forbes|a16z|UNEP|American Society|University|Architectural Digest|WIRED|Bloomberg|Vox|Insider|Science Channel|CrashCourse|freeCodeCamp') { return 'media_or_institution' }
    return 'independent_or_unclear'
}

$files = @('longform-enriched.csv','expansion-longform-enriched.csv') | ForEach-Object { Join-Path $DataDir $_ } | Where-Object { Test-Path -LiteralPath $_ }
$raw = foreach ($file in $files) { Import-Csv -LiteralPath $file }
$deduped = $raw | Sort-Object video_id -Unique
$obs = foreach ($r in $deduped) {
    $published = $null
    try { $published = [datetime]::ParseExact($r.upload_date_raw, 'yyyyMMdd', [Globalization.CultureInfo]::InvariantCulture) } catch {}
    if ($null -eq $published) { continue }
    $age = [math]::Max(7, [math]::Floor(($AsOf - $published).TotalDays))
    $text = "$($r.title) $($r.channel_name)".ToLowerInvariant()
    $kids = $text -match 'kids|children|dr\. binocs|learn bright|peekaboo'
    $tutorial = $text -match 'tutorial|course|lesson|training|full course|lecture'
    [pscustomobject]@{
        micro_theme = Get-MicroTheme $r.source_query
        source_query = $r.source_query
        video_id = $r.video_id
        channel_id = $r.channel_id
        channel_name = $r.channel_name
        channel_handle = $r.channel_handle
        source_type = Get-SourceType $r.channel_name
        title = $r.title
        upload_date = $published.ToString('yyyy-MM-dd')
        age_days = $age
        duration_seconds = [int]$r.duration_seconds
        views_snapshot = [long]$r.views_snapshot
        views_per_day = [math]::Round(([double]$r.views_snapshot / $age),2)
        is_kids_signal = $kids
        is_tutorial_signal = $tutorial
        format_scope = if ($kids) { 'exclude_kids' } elseif ($tutorial) { 'tutorial_or_course' } else { 'editorial_explainer_candidate' }
        video_url = $r.video_url
    }
}

$eligible = @($obs | Where-Object { -not $_.is_kids_signal })
$globalP75 = Get-Quantile ([double[]]@($eligible | Select-Object -ExpandProperty views_per_day)) 0.75
$summary = foreach ($g in ($eligible | Group-Object micro_theme | Sort-Object Name)) {
    $vpd = [double[]]@($g.Group | Select-Object -ExpandProperty views_per_day)
    $sourceChannels = @($g.Group | Select-Object -ExpandProperty channel_id -Unique).Count
    $media = @($g.Group | Where-Object { $_.source_type -eq 'media_or_institution' }).Count
    [pscustomobject]@{
        micro_theme = $g.Name
        sampled_videos = $g.Count
        unique_channels = $sourceChannels
        median_vpd = [math]::Round((Get-Quantile $vpd 0.50),2)
        p25_vpd = [math]::Round((Get-Quantile $vpd 0.25),2)
        p75_vpd = [math]::Round((Get-Quantile $vpd 0.75),2)
        high_traction_video_rate = [math]::Round((@($g.Group | Where-Object { $_.views_per_day -ge $globalP75 }).Count / $g.Count),3)
        media_or_institution_share = [math]::Round(($media / $g.Count),3)
        tutorial_or_course_share = [math]::Round((@($g.Group | Where-Object { $_.is_tutorial_signal }).Count / $g.Count),3)
        oldest_upload = ($g.Group | Sort-Object upload_date | Select-Object -First 1).upload_date
        newest_upload = ($g.Group | Sort-Object upload_date -Descending | Select-Object -First 1).upload_date
        interpretation_limit = 'Query-routed public sample, not a census. VPD does not measure retention, RPM, CTR, watch hours or US audience share.'
    }
}

$obs | Export-Csv -LiteralPath (Join-Path $DataDir 'combined-video-observations.csv') -NoTypeInformation -Encoding UTF8
$summary | Export-Csv -LiteralPath (Join-Path $DataDir 'microtheme-summary.csv') -NoTypeInformation -Encoding UTF8
$summary | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $DataDir 'microtheme-summary.json') -Encoding UTF8
Write-Host "Wrote $(@($obs).Count) combined videos and $(@($summary).Count) micro-theme summaries."
