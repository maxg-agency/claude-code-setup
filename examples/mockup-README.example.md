# Reason cards as the second block of the home page — mockup

**The request (verbatim):** put three reason cards after the hero instead of the photo strip. Cards should be more visual, in the style of the hero: floating, animated, so the page hooks with the picture as well as the text. Three theses: you see the free slots at once; you confirm in one tap; you get a reminder before the visit.

**Run:** `node serve.mjs` → http://localhost:4173/ . Switch bottom right: variant A / B / C, background shapes on/off. A static frame of the hero above and a placeholder of the reviews block below, so the block order is visible.

## Variants (same scenes, different presentation)

| | How it looks | Pluses | Risks |
|---|---|---|---|
| **A · Floating** | Three glass cards in a row, the outer ones tilted, all drifting up and down, a diagonal light sweep passes over them in turn as in the hero; tilt follows the cursor | Closest to the current block; all three theses visible at once | The calmest of the three |
| **B · Depth on scroll** | The block pins to the screen; cards come out of the depth one by one at full width (scene left, text right), the finished one flies up; dots on the right: See / Tap / Remember | The strongest scroll; each scene gets a whole screen | About three screens long; on the phone it falls back to a plain list |
| **C · Bento** | The first card (free slots) large on the left, the other two on the right | The main thesis is the biggest | Scenes in the small cards are smaller |

In every variant soft shapes drift behind the cards, like the hero's background pattern (some with an accent edge), with parallax on scroll. A switch turns them off.

## The three scenes

1. **You see the free slots.** A week grid fills in; taken slots dim one by one, the free ones light up in the accent colour; the cursor hovers one and a tooltip shows the time. 8-second loop.
2. **You confirm in one tap.** A tap on a slot; a ticket slides in with the date, the time and the name of the person you booked; a checkmark. 6-second loop.
3. **You get a reminder.** A phone screen, the calendar flips to the day before, a notification drops in with "Tomorrow 10:00"; the person taps "I'll be there". 10-second loop.

## Copy (as on the mockup)

- Kicker: Why book here
- Heading: See a free slot, tap, done
- Paragraph: No calls, no "is Tuesday free?". The week is on the screen, the slot is yours after one tap, and a reminder arrives the day before.

## Decision

The user chose **B** without the background shapes (2026-10-06), with the mobile fallback as described. A is kept for a future block. Transfer to the site: a feature in the pipeline, plan in `.claude/feature-dev/home-reason-stack/`.
