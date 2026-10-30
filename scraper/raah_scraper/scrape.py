"""Fetch every active source and write one feed.json for the app.

    python -m raah_scraper.scrape --out ../assets/data/feed.json
"""

from __future__ import annotations

import argparse
import asyncio
import hashlib
import json
import re
import ssl
import sys
from datetime import date, datetime, timezone
from urllib.parse import urljoin, urlsplit

import httpx
import truststore
from bs4 import BeautifulSoup

from .registry import Source, load_sources

UA = "Mozilla/5.0 (compatible; RaahBot/0.1; +public-information-aggregator)"
DATE_RE = re.compile(r"\b(\d{1,2})[./-](\d{1,2})[./-](20\d\d)\b")
PER_SOURCE = 60  # some sites list their whole archive
SKIP_TEXT = re.compile(
    r"tender|quotation|grievance|instruction|login|sitemap|rti\b|tenders", re.I
)

# First match wins, so order matters.
KINDS = [
    ("result", re.compile(r"result|merit list|cut.?off|selected candidates", re.I)),
    ("admit_card", re.compile(r"admit card|e-admission|call letter|intimation letter|hall ticket", re.I)),
    ("answer_key", re.compile(r"answer key", re.I)),
    ("exam_date", re.compile(r"exam(ination)? (schedule|date|calendar)|postpone|reschedul|date of (commencement|exam)", re.I)),
    ("recruitment", re.compile(r"recruitment|advertisement|advt|vacanc|notification|apply|posts? of", re.I)),
]


def kind_of(text: str) -> str:
    for kind, rx in KINDS:
        if rx.search(text):
            return kind
    return "notice"


def find_date(text: str) -> date | None:
    m = DATE_RE.search(text)
    if not m:
        return None
    d, mo, y = (int(x) for x in m.groups())
    try:
        return date(y, mo, d)
    except ValueError:
        return None


def client_for(src: Source) -> httpx.AsyncClient:
    ctx = truststore.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    if src.tls == "legacy":
        ctx.options |= 0x4  # OP_LEGACY_SERVER_CONNECT, for old government servers
    return httpx.AsyncClient(
        headers={"User-Agent": UA}, follow_redirects=True, timeout=30, verify=ctx
    )


def parse(src: Source, html: str, base_url: str) -> list[dict]:
    soup = BeautifulSoup(html, "lxml")
    seen: set[str] = set()
    items = []
    for a in soup.select(src.selector or "a[href]"):
        href = a.get("href", "").strip()
        title = re.sub(r"\s+", " ", a.get_text(" ", strip=True))
        if len(title) < 20 or href.startswith(("#", "javascript:", "mailto:")):
            continue
        url = urljoin(base_url, href)
        parts = urlsplit(url)
        if parts.scheme not in ("http", "https") or not src.allows(parts.hostname or ""):
            continue
        if SKIP_TEXT.search(title) or url in seen:
            continue
        seen.add(url)
        around = a.parent.get_text(" ", strip=True)[:300] if a.parent else title
        published = find_date(title) or find_date(around)
        items.append(
            {
                "id": hashlib.sha1(f"{src.id}|{url}".encode()).hexdigest()[:12],
                "title": title[:220],
                "url": url,
                "source": src.id,
                "sourceName": src.name,
                "state": src.state,
                "kind": kind_of(title),
                "date": published.isoformat() if published else None,
            }
        )
    return items


async def run_one(src: Source) -> tuple[Source, list[dict], str | None]:
    try:
        async with client_for(src) as c:
            r = await c.get(src.url)
        if r.status_code != 200:
            return src, [], f"HTTP {r.status_code}"
        return src, parse(src, r.text, str(r.url)), None
    except Exception as e:  # one bad site must not stop the rest
        return src, [], f"{type(e).__name__}: {str(e)[:80]}"


async def main_async(args) -> int:
    sources = [s for s in load_sources() if s.status == "active"]
    if args.only:
        sources = [s for s in sources if s.id in args.only]
    sem = asyncio.Semaphore(6)

    async def guarded(s):
        async with sem:
            return await run_one(s)

    results = await asyncio.gather(*(guarded(s) for s in sources))

    items, report = [], []
    today = date.today()
    for src, found, err in results:
        report.append({"source": src.id, "count": len(found), "error": err})
        found.sort(key=lambda i: i["date"] or "0000", reverse=True)
        items.extend(found[:PER_SOURCE])
        print(f"{src.id:8} {len(found):4} items  {err or 'ok'}", file=sys.stderr)

    # Newest first; undated items last. Drop dates that can't be right.
    def key(i):
        d = i["date"]
        return d if d and d <= today.isoformat() else "0000"

    items.sort(key=key, reverse=True)
    feed = {
        "generatedAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "sources": report,
        "items": items,
    }
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(feed, f, ensure_ascii=False, indent=1)
    print(f"wrote {len(items)} items to {args.out}", file=sys.stderr)
    return 0


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--out", default="feed.json")
    p.add_argument("--only", nargs="*")
    return asyncio.run(main_async(p.parse_args()))


if __name__ == "__main__":
    raise SystemExit(main())
