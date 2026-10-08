---
name: feedback_look_at_page_after_content_change
description: After a content change that alters the page's shape, take full frames at four window sizes and look at them before saying done
metadata:
  type: feedback
---
If a text transfer changes the shape of a page (the text got noticeably longer, new Markdown elements appeared: tables, lists, several paragraphs in a block), take the page as a full frame at 1440 and 390 before handing over, and look at it. Name the layout breaks to the user yourself; do not wait for them to find them.

**Why:** SEO versions of the case pages (seven blocks instead of four, a table and a list in each) went into the code with the UI check at 515/515. The user opened a case page and saw an empty right column, an unstyled table, steps without numbers and paragraphs stuck together: "Look with your eyes: you can see it is broken." The UI check compared block headings and highlights; it had nothing about columns, lists and tables.

**Second time, three days later.** Card text doubled in length, verify 553/553, I took frames at 1440 and 390 under reduced motion. The user opened the page in a 1173×708 window and found four breaks: the portrait aligned to a line under the badges, the lead narrower than the badge row, on the phone the photo first, the stacked cards overlapping before they could be read. Reduced motion turns the stack into a plain list, so my frames hid the problem.

**How to apply:**
- Frames without reduced motion. Windows: 1440×900, laptop 1280×720 or 1173×708, tablet 820×1180, phone 390×844, both languages.
- Anything that depends on scrolling (sticky cards, decks) is captured mid-scroll, and the margin is computed: window height minus sticky top minus card height. A margin under a third of the window means the card cannot be read in time.
- Alignment is checked by measuring edges (`getBoundingClientRect`), not by eye.
- A long word in a heading is checked separately in each narrow column.
- For each new element type in the text, check that the site has a style for it (grep the global stylesheet). Related: [[feedback_orphan_processes_headless_chrome]].
