# Raah by ZAP

Voice-first assistant for Indian government exam notifications. UI follows the
orb / prompt-card / chat layout, skinned in the Dawnlit (ZAP) palette:

- **Light:** white page, Atlantic Waves `#233E42` for the mic and your
  messages, Child of Light `#F0F4F8` cards, Aruba Aqua `#D2DDD4` glow.
- **Dark:** true black, neutral `#111111` surfaces, near-white `#F0F4F8`
  accent, silver orb. No tinted backgrounds.

Tokens live in `lib/core/theme/aura.dart` (same `Aura` extension as Dawnlit).

## Screens

| Tab | What it does | File |
| --- | --- | --- |
| Ask | Voice or typed questions, orb, chat | `lib/features/assistant/` |
| Updates | Latest jobs, results, admit cards, answer keys by state | `lib/features/updates/` |
| Websites | "Which website do I go to?" by need (law, crime, insurance, health...) | `lib/features/directory/` |

## Scraper (`scraper/`)

Reads state commission sites listed in `scraper/raah_scraper/sources.json` and
writes `assets/data/feed.json`, which the Updates tab shows.

```sh
cd scraper
python -m raah_scraper.scrape --out ../assets/data/feed.json
```

Each source has a `status`: `active` (scraped), `needs_browser` (page built by
JavaScript, needs Playwright), `blocked` (site refuses bots) or `broken`.
Links are kept only if they point at official `.gov.in` / `.nic.in` hosts or a
commission's own listed domain.

## Not wired yet

- **Speech:** the voice screen replays a sample question. Connect Bhashini ASR.
- **Answers:** `DemoAssistantService` returns canned replies with sample data.
  Implement `AssistantService.ask` against the feed + RAG backend.
- **Feed refresh:** the feed is bundled at build time. Run the scraper on a
  schedule and serve `feed.json` for live updates.

```sh
flutter run
flutter test
```
