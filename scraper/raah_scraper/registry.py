"""The list of government pages Raah watches (see sources.json)."""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path
from urllib.parse import urlsplit

_FILE = Path(__file__).with_name("sources.json")


@dataclass(frozen=True)
class Source:
    id: str
    state: str
    name: str
    url: str
    status: str = "active"
    tls: str = "default"
    selector: str | None = None
    allow_domains: tuple[str, ...] = field(default_factory=tuple)
    note: str | None = None

    @property
    def host(self) -> str:
        return urlsplit(self.url).hostname or ""

    def allows(self, host: str) -> bool:
        """Only keep links that stay on official ground. Government pages get
        defaced with SEO spam links, and we must never send people there."""
        host = host.lower()
        if host == self.host or host.endswith("." + self.host.removeprefix("www.")):
            return True
        if host.endswith((".gov.in", ".nic.in")) or host in ("gov.in", "nic.in"):
            return True
        return any(host == d or host.endswith("." + d) for d in self.allow_domains)


def load_sources(path: Path = _FILE) -> list[Source]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    out = []
    for s in raw["sources"]:
        s = dict(s)
        s["allow_domains"] = tuple(s.get("allow_domains", ()))
        out.append(Source(**s))
    ids = [s.id for s in out]
    dupes = {i for i in ids if ids.count(i) > 1}
    if dupes:
        raise ValueError(f"duplicate source ids: {sorted(dupes)}")
    return out
