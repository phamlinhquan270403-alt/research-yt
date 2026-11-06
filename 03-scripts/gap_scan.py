"""Compare all-time vs this-year top videos per topic using search pages only (no per-video calls).
Gap = demand proven (all-time views) while this year's supply is weak/strong.
usage: python gap_scan.py out.json"""
import json, subprocess, sys, statistics, time, urllib.parse

QUERIES = {
    "how does a submarine work": "how", "how does a nuclear reactor work": "how",
    "how were the pyramids built": "how", "how are tunnels built": "how",
    "how do dams work": "how", "how were castles built": "how",
    "how do skyscrapers stay up": "how", "how do underground mines work": "how",
    "abandoned cities history": "photo", "lost civilizations": "photo",
    "famous shipwrecks history": "photo", "biggest megaprojects": "photo",
    "history of the panama canal": "photo", "deepest places on earth": "photo",
    "apollo missions history": "photo", "polar expeditions history": "photo",
    "ancient roman engineering": "photo", "history of lighthouses": "photo",
    "worst engineering disasters": "photo", "transcontinental railroad history": "photo",
}
SP = {"all": "CAMSAhgD", "year": "CAMSBAgFGAM%3D"}  # sort by views, 4-20 min; +this year


def search(q, sp):
    url = f"https://www.youtube.com/results?search_query={urllib.parse.quote_plus(q)}&sp={sp}"
    r = subprocess.run(["yt-dlp", "--no-warnings", "--flat-playlist", "-j", "--playlist-end", "10", url],
                       capture_output=True, text=True, encoding="utf-8")
    return [json.loads(l) for l in r.stdout.splitlines() if l.strip()]


rows = []
for q, kind in QUERIES.items():
    a, y = search(q, SP["all"]), search(q, SP["year"])
    time.sleep(2)
    va = [d.get("view_count") or 0 for d in a] or [0]
    vy = [d.get("view_count") or 0 for d in y] or [0]
    rows.append(dict(q=q, kind=kind, all_med=int(statistics.median(va)), year_med=int(statistics.median(vy)),
                     year_n=len(y), year_top=max(y, key=lambda d: d.get("view_count") or 0, default=None),
                     all_top=max(a, key=lambda d: d.get("view_count") or 0, default=None)))
    print(f"done {q}", file=sys.stderr)

print(f"{'topic':36} {'kind':5} {'top10 all-time med':>18} {'top10 2026 med':>14}  best 2026 video")
for r in sorted(rows, key=lambda r: r["year_med"], reverse=True):
    t = r["year_top"] or {}
    print(f"{r['q'][:36]:36} {r['kind']:5} {r['all_med']:>18,} {r['year_med']:>14,}  "
          f"{(t.get('view_count') or 0):>9,} | {(t.get('channel') or '')[:20]:20} | {(t.get('title') or '')[:50]} | {t.get('id')}")
json.dump(rows, open(sys.argv[1], "w", encoding="utf-8"), indent=1, default=str)
