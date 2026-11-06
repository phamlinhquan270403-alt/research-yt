param(
    [string]$DataDir = "G:\research niches\02-data",
    [int]$VideosPerChannel = 10,
    [int]$StartIndex = 0,
    [int]$MaxChannels = 4,
    [string]$OutputPrefix = "round2-channel-history-batch"
)

$ErrorActionPreference = 'Stop'
$all = @(Import-Csv -LiteralPath (Join-Path $DataDir 'round2-cohort-selection.csv'))
if ($StartIndex -gt 0) { $all = @($all | Select-Object -Skip $StartIndex) }
if ($MaxChannels -gt 0) { $all = @($all | Select-Object -First $MaxChannels) }
$snapshotAt = (Get-Date).ToUniversalTime().ToString('o')
$printTemplate = "%(id)s`t%(channel)s`t%(title)s`t%(upload_date)s`t%(duration)s`t%(view_count)s`t%(channel_follower_count)s`t%(webpage_url)s"
$out = [System.Collections.Generic.List[object]]::new()
$errors = [System.Collections.Generic.List[object]]::new()

foreach ($entry in $all) {
    Write-Host "Channel: $($entry.channel_handle)" -ForegroundColor Cyan
    try {
        $url = "https://www.youtube.com/$($entry.channel_handle)/videos"
        $lines = & yt-dlp --skip-download --no-warnings --ignore-errors --playlist-end $VideosPerChannel --print $printTemplate $url 2>$null
        foreach ($line in $lines) {
            $p = $line -split "`t", 8
            if ($p.Count -ne 8 -or [string]::IsNullOrWhiteSpace($p[0])) { continue }
            $duration = 0; $views = 0; $subs = 0
            [void][int]::TryParse($p[4], [ref]$duration)
            [void][long]::TryParse($p[5], [ref]$views)
            [void][long]::TryParse($p[6], [ref]$subs)
            $out.Add([pscustomobject]@{
                snapshot_at = $snapshotAt
                candidate = $entry.candidate
                audit_role = $entry.audit_role
                channel_handle = $entry.channel_handle
                selected_channel_name = $entry.channel_name
                source_video_id = $entry.source_video_id
                source_video_vpd = $entry.source_video_vpd
                video_id = $p[0]
                channel_name = $p[1]
                title = $p[2]
                upload_date_raw = $p[3]
                duration_seconds = $duration
                views_snapshot = $views
                channel_subscribers_snapshot = $subs
                video_url = $p[7]
            })
        }
    } catch {
        $errors.Add([pscustomobject]@{ candidate=$entry.candidate; channel_handle=$entry.channel_handle; error=$_.Exception.Message })
    }
}

$out | Export-Csv -LiteralPath (Join-Path $DataDir "$OutputPrefix.csv") -NoTypeInformation -Encoding UTF8
$out | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $DataDir "$OutputPrefix.json") -Encoding UTF8
$errors | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $DataDir "$OutputPrefix-errors.json") -Encoding UTF8
[pscustomobject]@{ snapshot_at=$snapshotAt; selected_channels=$all.Count; video_count=$out.Count; error_count=$errors.Count } | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $DataDir "$OutputPrefix-summary.json") -Encoding UTF8
Write-Host "Collected $($out.Count) videos from $($all.Count) selected channels."
