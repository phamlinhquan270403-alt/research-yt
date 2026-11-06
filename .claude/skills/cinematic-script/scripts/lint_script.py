"""Lint a narration script for AI-sounding prose and pacing problems.

usage: python lint_script.py <script.md|.txt> [--wpm 150]
Ignores markup: headings, [VISUAL ...], [F1], [RECON], [PAUSE], [mm:ss], tables, and anything after a '### Sources' heading.
Exit code 1 if any RED issue.
"""
import re, sys, statistics, argparse

RED_PHRASES = [
    # openers
    "in a world where", "throughout history", "since the dawn of time", "imagine a world", "picture this",
    # AI vocabulary
    "delve", "tapestry", "testament to", "a symphony of", "realm of", "navigate the complexities",
    "embark on a journey", "unwavering", "indomitable", "pivotal moment",
    # cliché drama
    "little did they know", "little did he know", "little did she know", "fate had other plans",
    "fate is already", "what happened next will shock", "but here's the thing", "the rest is history",
    "and so it began",
    # philosophical endings
    "stands as a testament", "the human spirit", "echoes through history", "only time will tell",
    "a reminder that", "serves as a reminder",
]
YELLOW_PHRASES = [
    "intricate", "unravel", "shrouded in mystery", "captivating", "remarkable", "incredible", "fascinating",
    "it's worth noting", "it is worth noting", "needless to say", "in conclusion", "ultimately",
    "like a banshee", "like a ballet", "like clockwork", "like a swiss watch", "cut through steel like butter",
    "and then", "subscribe",
]
TRANSITION_GOOD = re.compile(r"\b(but|so|therefore|because|which meant|until)\b", re.I)


def clean(text):
    text = re.split(r"^#{2,3}\s*Sources", text, flags=re.M | re.I)[0]
    keep = []
    for line in text.splitlines():
        s = line.strip()
        if not s or s.startswith(("#", "|", "- Genre", "- Target", "- Central", "- Title", "---")):
            continue
        if re.fullmatch(r"\[(VISUAL|PAUSE)[^\]]*\]", s, re.I):
            continue
        keep.append(s)
    t = " ".join(keep)
    t = re.sub(r"\[(?:F\d+|RECON|PAUSE|music|applause|Music|Applause|\d{2}:\d{2})\]", " ", t)
    t = re.sub(r"\[VISUAL:[^\]]*\]", " ", t)
    t = t.replace(">>", " ")
    return re.sub(r"\s+", " ", t).strip()


def sentences(t):
    parts = re.split(r"(?<=[.!?])\s+(?=[A-Z0-9\"'“])", t)
    return [p for p in parts if re.search(r"[A-Za-z]", p)]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("path")
    ap.add_argument("--wpm", type=int, default=150)
    a = ap.parse_args()
    raw = open(a.path, encoding="utf-8").read()
    t = clean(raw)
    low = t.lower()
    words = t.split()
    n = len(words)
    sents = sentences(t)
    lens = [len(s.split()) for s in sents]
    red, yellow = [], []

    for p in RED_PHRASES:
        c = low.count(p)
        if c:
            red.append(f"cụm từ cấm '{p}' ×{c}")
    for p in YELLOW_PHRASES:
        c = len(re.findall(r"\b" + re.escape(p) + r"\b", low))
        # "and then" is fine inside a sentence for cumulative rhythm (MrBallen); flag only heavy use
        if c >= (4 if p == "and then" else 2 if p in ("remarkable", "incredible") else 1):
            yellow.append(f"cụm nên tránh '{p}' ×{c}")

    first = sents[0].lower() if sents else ""
    if re.match(r"(throughout|since|in a world|imagine|picture|history|there is|there was|have you ever)", first):
        red.append(f"câu mở đầu khái quát: \"{sents[0][:80]}\"")

    mean = statistics.mean(lens) if lens else 0
    sd = statistics.pstdev(lens) if len(lens) > 1 else 0
    long_share = sum(l > 30 for l in lens) / max(len(lens), 1)
    short_share = sum(l <= 5 for l in lens) / max(len(lens), 1)
    no_punct = len(sents) < n / 60
    if no_punct:
        yellow.append("văn bản gần như không có dấu câu (phụ đề tự động?), bỏ qua chỉ số câu")
    elif mean > 22:
        red.append(f"câu trung bình quá dài ({mean:.1f} từ)")
    if not no_punct and sd < 6:
        yellow.append(f"nhịp câu đều đều (độ lệch {sd:.1f} < 6)")
    if not no_punct and long_share > 0.15:
        yellow.append(f"{long_share:.0%} câu > 30 từ")
    if not no_punct and short_share < 0.08:
        yellow.append(f"ít câu ngắn ≤5 từ ({short_share:.0%}); thiếu câu lật")

    per_k = 1000 / max(n, 1)
    dashes = (raw.count("—") + raw.count(" -- ")) * per_k
    if dashes > 6:
        yellow.append(f"gạch ngang dày ({dashes:.1f}/1000 từ)")
    triplets = len(re.findall(r"\b\w+(?: \w+)?, \w+(?: \w+)?,? and \w+", t)) * per_k
    if triplets > 8:
        yellow.append(f"liệt kê 3 ý quá nhiều ({triplets:.1f}/1000 từ)")

    # open-loop proxy: non-overlapping ~90s windows with no question, pivot, or foreshadowing marker
    hooks_re = re.compile(r"\?|\bBut\b|\byet\b|\buntil\b|\bwould (?:prove|become|never|later)\b|\bwill\b|\bnobody\b|\bnever\b", re.I)
    win = int(a.wpm * 1.5)
    dry_at = []
    for i in range(0, n, win):
        if not hooks_re.search(" ".join(words[i:i + win])):
            dry_at.append(f"~{i / a.wpm:.1f}p")
    hints = []
    if dry_at:
        hints.append(f"đoạn ~90 giây không có câu hỏi / cú lật / báo trước tại: {', '.join(dry_at)} (kiểm tra open loop)")
    good_tr = len(TRANSITION_GOOD.findall(t)) * per_k

    print(f"File: {a.path}")
    print(f"Từ: {n} · ước tính {n / a.wpm:.1f} phút @ {a.wpm} wpm · {len(sents)} câu")
    print(f"Độ dài câu: TB {mean:.1f} · lệch {sd:.1f} · >30 từ {long_share:.0%} · ≤5 từ {short_share:.0%}")
    print(f"Từ chuyển but/so/because: {good_tr:.1f}/1000 từ · câu hỏi: {t.count('?')}")
    for r in red:
        print(f"  ĐỎ   {r}")
    for y in yellow:
        print(f"  VÀNG {y}")
    for h in hints:
        print(f"  GỢI Ý {h}")
    if not red and not yellow:
        print("  OK   không phát hiện vấn đề")
    sys.exit(1 if red else 0)


if __name__ == "__main__":
    main()
