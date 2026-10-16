# Pricing link in the compact footer
Status: done
Scale: S, 3 files, one approach (a link in the existing compact footer), area known from the footer plan a week earlier
Model log: phases 0–7 · sonnet (building; scale S does not stop) · 2026-10-12 · Context: 41k / 200k (21%)

## 1. Task

The home page renders a compact footer: contacts and a language switch, without the Services · Pricing · Contact links of the full footer. Now the home page needs a link to Pricing too: visitors from ads land on the home page, and Pricing is the page that books.

Constraints: the home page stays one screen tall; the link appears only when the Pricing page is live (`isLive("pricing")`), so it ships the same day as Pricing with no separate release; both languages.

## 2. What we found in the code

- `src/components/SiteFooter.tsx`: `variant="compact"` renders `<div class="wrap row">` with a `<nav>` of contacts and `<LangSwitch>`; the full footer filters its small links through `isLive`.
- `src/lib/pages.ts`: `isLive(key)` is true when `LIVE_PAGES` is unset (local, preview) or contains the key. Production sets `LIVE_PAGES="home"`.
- `scripts/check-pages.mjs`: the page check already asserts the compact footer's contents; it has to learn about the new link.

## 3. Questions and answers

None needed. Decision by the agent: the link sits next to the language switch, not among the contacts (it is not a contact, and putting it there would break the contact list check).

## 4. Approach

A right-hand group `<div class="row-end">` in the compact footer: the Pricing link (when `isLive("pricing")`) and `LangSwitch`. Rejected: the link as a third child of `.row` (with `space-between` it would land in the middle); inside the contacts `<nav>` (breaks the contacts check).

Files:
1. `src/components/SiteFooter.tsx`: the `row-end` group in the compact variant.
2. `src/styles/global.css`: `.row-end` (flex, gap matching the full footer).
3. `scripts/check-pages.mjs`: compact footer contains the Pricing link, and it points to Pricing in the current language.

Steps: (1) footer, (2) CSS, (3) check, (4) verify.

Verify: `npm run check`; `LIVE_PAGES=home npm run check` (no link) and `LIVE_PAGES=home,pricing` (link present); screenshots of the home page at 1440×900, 1280×720 and phone, both languages.

Do not touch: the full footer; the Pricing release itself.

## 5. Build log

1. Footer: done as planned.
2. CSS: done; the gap is the full footer's `--gap-s`, no new token.
3. Check: two new assertions. Deviation: the check reads the expected Pricing path from the routes table instead of hard-coding `/pricing` and `/de/preise`, so a future slug change does not break it silently.
4. `npm run check`: all green. Both `LIVE_PAGES` variants behave as expected. Screenshots look right at all three sizes.

## 6. Review

Scale S: self-review of the diff, plus one reviewer agent on the check script because it is shared. No issues at confidence 80 or above; one note that the page-path helper is fragile, taken as a follow-up.

## 7. Summary

The home page footer shows "Pricing" in both languages once Pricing is live. Files: `SiteFooter.tsx`, `global.css`, `check-pages.mjs`. Follow-up: harden the page-path helper in the check script.

Proposed commit: `feat(footer): Pricing link in the compact footer, shown once Pricing is live`
