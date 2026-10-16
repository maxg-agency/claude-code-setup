# Pricing page mockup v3 · state on 2026-10-14 · for the next agent
Model log: iterations 1–15 · opus · 2026-10-14 · Context: 132k / 1M (13%)

> This file is self-contained: read it, then look at the live page. Do not reread the iteration history, it is in [README.md](README.md). Next: I give edits block by block. Mode: edit, check the page returns 200, short message "refresh the page".

## 1. Where everything is

- **Code:** a clone of the site repository in the scratchpad, with the mockup patch applied. The base is `code/`.
- **Dev server:** http://127.0.0.1:4173/pricing and /de/preise. If it is down: `npm run dev -- --port 4173` in the clone.
- **Page texts:** `content/{en,de}/pricing.md` in the clone, copies next to this file. Edit both copies.
- **Styles:** `src/styles/global.css`, everything for the mockup starts at the "pricing v3 mockup" comment.
- **Patch:** `clone.patch` in this folder, the whole diff of the clone against `code/`.
- **Checks:** `npx tsc --noEmit` in the clone; `curl -s -o /dev/null -w "%{http_code}"` on both addresses.

## 2. The page now, top to bottom

| # | Block | What it looks like |
|---|---|---|
| 1 | Header | logo, menu, "Book now" button; burger below 1100 px |
| 2 | Plans | two cards side by side, the yearly one marked; one column on the phone |
| 3 | ... | ... |

## 3. Decided

- Two plans, not three (decision 2026-10-13, `DECISIONS.md`).
- ...

## 4. Open

- Spacing between blocks 2 and 3 on phones: waiting for my look.
- ...

## 5. Checkpoint

- **Status:** iteration 15 done, waiting for my edits.
- **Decided this chat:** two lines added to `DECISIONS.md`.
- **Open:** section 4.
- **Next step:** move the chosen set into `code/` by the umbrella plan `RELEASE-PLAN.md`.
- **Model for it:** the planning model for the plan, then the building model per piece.
