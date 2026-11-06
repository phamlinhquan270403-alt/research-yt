param(
    [string]$DataDir = "G:\research niches\02-data",
    [int]$VideosPerChannel = 5
)

$ErrorActionPreference = "Stop"

# Stratified follow-up sample selected after the broad discovery pass. Each
# pair contains visible traction variation in the same or an adjacent topic.
# It is not a claim that any creator failed financially.
$cohort = @(
    @{ handle='@UrbanPlannerExplained'; theme='urban planning'; sampled_for='mixed traction' },
    @{ handle='@SahariYT'; theme='urban planning'; sampled_for='lower VPD comparison' },
    @{ handle='@Aviationexplainedd'; theme='airport operations'; sampled_for='within-channel variation' },
    @{ handle='@AeroExplainedTV'; theme='airport operations'; sampled_for='peer comparison' },
    @{ handle='@infrastructure-fr'; theme='energy grid'; sampled_for='very low VPD observation' },
    @{ handle='@Leo-cui-phd-cfa'; theme='energy and data centers'; sampled_for='higher VPD comparison' },
    @{ handle='@Animagraffs'; theme='water systems'; sampled_for='lower VPD comparison' },
    @{ handle='@primalspace'; theme='water systems'; sampled_for='higher VPD comparison' },
    @{ handle='@3dcasuallearning'; theme='3D mechanical explainers'; sampled_for='lower VPD comparison' },
    @{ handle='@historyonthemap'; theme='animated maps'; sampled_for='peer comparison' },
    @{ handle='@geoearthstories'; theme='animated maps'; sampled_for='peer comparison' },
    @{ handle='@adamsaxiom'; theme='economics explainers'; sampled_for='lower VPD comparison' },
    @{ handle='@theleaderstalk'; theme='business and logistics education'; sampled_for='mixed traction' },
    @{ handle='@littlebitbetter7'; theme='personal finance'; sampled_for='higher VPD comparison' },
    @{ handle='@thewealthworkshop'; theme='personal finance'; sampled_for='lower VPD comparison' },
    @{ handle='@IntelliBoost'; theme='logistics education'; sampled_for='very low VPD observation' },
    @{ handle='@LordGizmo'; theme='manufacturing explainers'; sampled_for='lower VPD comparison' },
    @{ handle='@Explains101'; theme='housing explainers'; sampled_for='peer comparison' },
    @{ handle='@CasuallyFinance'; theme='housing explainers'; sampled_for='higher VPD comparison' }
)

$snapshotAt = (Get-Date).ToUniversalTime().ToString('o')
$printTemplate = "%(id)s`t%(channel)s`t%(title)s`t%(upload_date)s`t%(duration)s`t%(view_count)s`t%(channel_follower_count)s`t%(webpage_url)s"
$out = [System.Collections.Generic.List[object]]::new()
$errors = [System.Collections.Generic.List[object]]::new()

foreach ($entry in $cohort) {
    Write-Host "Channel: $($entry.handle)" -ForegroundColor Cyan
    try {
        $url = "https://www.youtube.com/$($entry.handle)/videos"
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
                channel_handle = $entry.handle
                theme = $entry.theme
                sampled_for = $entry.sampled_for
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
        $errors.Add([pscustomobject]@{ channel_handle = $entry.handle; error = $_.Exception.Message })
    }
}

$out | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $DataDir 'channel-cohort-raw.json') -Encoding UTF8
$out | Export-Csv -LiteralPath (Join-Path $DataDir 'channel-cohort-raw.csv') -NoTypeInformation -Encoding UTF8
$errors | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $DataDir 'channel-cohort-errors.json') -Encoding UTF8
$summary = [pscustomobject]@{ snapshot_at=$snapshotAt; channel_count=$cohort.Count; video_count=$out.Count; error_count=$errors.Count }
$summary | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $DataDir 'channel-cohort-summary.json') -Encoding UTF8
Write-Host ($summary | ConvertTo-Json -Compress)
