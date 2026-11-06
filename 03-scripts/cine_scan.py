"""Scan cinematic niche candidates: this-year top10 (4-20 min, sorted by views) per query.
usage: python cine_scan.py out.json"""
import json, subprocess, sys, statistics, time, urllib.parse

NICHES = {
    "heist_con": ["bank heist true story", "con man true story"],
    "disaster_last_hours": ["the last hours of disaster", "disaster minute by minute"],
    "survival": ["incredible survival story", "lost at sea survival story"],
    "escape": ["prison escape true story", "greatest escape in history"],
    "spy": ["spy operation true story", "cold war spy story"],
    "air_crash": ["plane crash investigation", "what went wrong flight"],
    "mystery": ["historical mystery finally solved", "unsolved mystery history"],
    "military_op": ["military operation true story", "special forces mission true story"],
    "invention_race": ["the race to invent", "invention that changed the world story"],
    "pov_history": ["what it was like to live in", "you wake up in ancient"],
    "expedition": ["expedition gone wrong", "mountain climbing disaster"],
    "smuggling": ["smuggling operation true story", "drug cartel smuggling explained"],
    "rise_fall_company": ["rise and fall of company", "how company lost everything"],
}
MEDIA = {"CNN", "BBC", "Netflix", "CNBC", "Bloomberg Originals", "60 Minutes", "Vox", "WSJ",
         "The Wall Street Journal", "Business Insider", "National Geographic", "History", "DW News",
         "Smithsonian Channel", "NBC News", "ABC News", "Sky News", "The Economist", "Forbes"}
SP = "CAMSBAgFGAM%3D"  # sort by views, this year, 4-20 min


def search(q):
    url = f"https://www.youtube.com/results?search_query={urllib.parse.quote_plus(q)}&sp={SP}"
    r = subprocess.run(["yt-dlp", "--no-warnings", "--flat-playlist", "-j", "--playlist-end", "10", url],
                       capture_output=True, text=True, encoding="utf-8")
    return [json.loads(l) for l in r.stdout.splitlines() if l.strip()]


out = {}
for niche, qs in NICHES.items():
    vids = {}
    for q in qs:
        for d in search(q):
            vids[d["id"]] = d
        time.sleep(1.5)
    v = list(vids.values())
    views = sorted((d.get("view_count") or 0 for d in v), reverse=True)
    chans = {d.get("channel") for d in v}
    media = sum(1 for d in v if (d.get("channel") or "") in MEDIA)
    out[niche] = dict(n=len(v), median=int(statistics.median(views)) if views else 0,
                      p25=int(views[int(len(views) * .75)]) if views else 0,
                      channels=len(chans), media=media,
                      top=[(d.get("view_count"), d.get("channel"), d.get("title"), d["id"])
                           for d in sorted(v, key=lambda d: -(d.get("view_count") or 0))[:4]])
    print(f"done {niche}", file=sys.stderr)

print(f"{'niche':20} {'n':>3} {'median':>10} {'p25':>9} {'chan':>4} {'media':>5}")
for k, r in sorted(out.items(), key=lambda kv: -kv[1]["median"]):
    print(f"{k:20} {r['n']:>3} {r['median']:>10,} {r['p25']:>9,} {r['channels']:>4} {r['media']:>5}")
    for vc, ch, t, i in r["top"]:
        print(f"      {vc or 0:>10,} | {(ch or '')[:22]:22} | {(t or '')[:62]} | {i}")
json.dump(out, open(sys.argv[1], "w", encoding="utf-8"), indent=1, ensure_ascii=False)
