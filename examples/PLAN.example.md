# About link on the home page
Status: done
Scale: S, 3 files, one approach (a link in the existing compact footer), area known from the footer plan a week earlier

## 1. Task

The home page renders a compact footer: contacts and a language switch, without the Work · About · Contact links of the full footer. Now the home page needs a link to About too: visitors from social profiles land on the home page, and About is the page that sells.

Constraints: the home page stays one screen tall; the link appears only when the About page is released (`isReleased("about")`), so it ships the same day as About with no separate release; both languages.

## 2. What we found in the code

- `src/components/Footer.tsx`: `variant="compact"` renders `<div class="wrap crow">` with a `<nav>` of contacts and `<LangSwitch>`; the full footer filters its small links through `isReleased`.
- `src/lib/release.ts`: `isReleased(key)` is true when `SITE_PAGES` is unset (local, preview) or contains the key. Production sets `SITE_PAGES="home"`.
- `scripts/check-ui.mjs`: the UI check already asserts the compact footer's contents; it has to learn about the new link.

## 3. Questions and answers

None needed. Decision by the agent: the link sits next to the language switch, not among the contacts (it is not a contact, and putting it there would break the contact list check).

## 4. Approach

A right-hand group `<div class="crow-end">` in the compact footer: the About link (when `isReleased("about")`) and `LangSwitch`. Rejected: the link as a third child of `.crow` (with `space-between` it would land in the middle); inside the contacts `<nav>` (breaks the contacts check).

Files:
1. `src/components/Footer.tsx`: the `crow-end` group in the compact variant.
2. `src/app/globals.css`: `.crow-end` (flex, gap matching the full footer).
3. `scripts/check-ui.mjs`: compact footer contains the About link, and it points to About in the current language.

Steps: (1) Footer, (2) CSS, (3) check, (4) verify.

Verify: `npm run verify`; `SITE_PAGES=home npm run verify` (no link) and `SITE_PAGES=home,about` (link present); screenshots of the home page at 1440×900, 1280×720 and phone, both languages.

Do not touch: the full footer; the About release itself.

## 5. Build log

1. Footer: done as planned.
2. CSS: done; the gap is the full footer's `--gap-s`, no new token.
3. Check: two new assertions. Deviation: the check reads the expected About path from the routes table instead of hard-coding `/about` and `/ru/about`, so a future slug change does not break it silently.
4. `npm run verify`: all green. Both `SITE_PAGES` variants behave as expected. Screenshots look right at all three sizes.

## 6. Review

Scale S: self-review of the diff, plus one reviewer agent on the check script because it is shared. No issues at confidence 80 or above; one note that the page-path helper is fragile, taken as a follow-up.

## 7. Summary

The home page footer shows "About" in both languages once About is released. Files: `Footer.tsx`, `globals.css`, `check-ui.mjs`. Follow-up: harden the page-path helper in the check script.
