# Problem cards as the second block of /building/websites — mockup

**The request (verbatim):** put problem cards as the second block after the hero instead of the work previews. Cards should be more visual, in the style of the hero's head: floating, flying, animated, so the site hooks with the picture as well as the text. Three theses: the eye stops on your site; people remember it and come back; ads pay off because visitors read the message and reach the button.

**Run:** `node serve.mjs` → http://localhost:8792/ . Switch bottom right: variant A / B / C, cubes on/off. A static frame of the hero above and a placeholder of the gallery below, so the block order is visible.

## Variants (same scenes, different presentation)

| | How it looks | Pluses | Risks |
|---|---|---|---|
| **A · Floating** | Three glass cards in a row, the outer ones tilted, all drifting up and down, a diagonal light sweep passes over them in turn as in the hero; tilt follows the cursor | Closest to the current block; all three theses visible at once | The calmest of the three |
| **B · Depth on scroll** | The block pins to the screen; cards come out of the depth one by one at full width (scene left, text right), the finished one flies up; dots on the right: Noticed / Remembered / Read | The strongest scroll; each scene gets a whole screen | About three screens long; on the phone it falls back to a plain list |
| **C · Bento** | The first card (the eye stops) large on the left, the other two on the right | The main thesis is the biggest | Scenes in the small cards are smaller |

In every variant glass cubes fly and rotate behind the cards, like the plates of the hero's face (some with a yellow edge), with parallax on scroll. A switch turns them off.

## The three scenes

1. **The eye stops.** A feed of identical sites with AI-sounding headlines ("Elevate your business", "Unlock your potential") drifts upward; a gaze reticle jumps between them, dimming everything around, and stops on your site (a mini face of cubes). The card lifts, glows yellow, badge "The eye stops here". 8-second loop.
2. **They remember and come back.** A ring of eight sites rotates in 3D, a day counter (Day 1 → 3 → 7 → 14), other sites fade and blur one by one, yours stays; at the end the cursor clicks it, badge "They come back to you". 12-second loop.
3. **Ads pay off.** One "Sponsored" ad, dots-visitors fly out of it: on the generic page on the left they bounce back out; on yours on the right they zigzag along the message lines (lines light up) and reach the button, which flashes on each. No numbers.

## Copy (as on the mockup)

- Kicker: Why people scroll past
- Heading: The eye stops on your site
- Paragraph: Template layouts and AI-written copy look the same from site to site; people skim and leave. A design nobody else has holds attention, and a business with such a site gets remembered.

## Decision

The user chose **B** without the cubes (06.10), with the mobile fallback as described. A is kept for a future block. Transfer to the site: a feature in the pipeline, plan in `.claude/feature-dev/websites-problem-stack/`.
