# HTML mockups: how design decisions get made

A design question is never answered in prose. The model builds two or three variants as a single HTML file, serves it locally with a switch in the corner, I look, I pick, and only then does the chosen variant go into the real codebase through the feature pipeline.

## The method

1. **References first.** For a new block or page the model collects two or three references (screenshots of live pages it visited through the browser) and writes under each how it works, what to take and what not to take. The default visual direction is premium black; anything else needs a reason.
2. **Variants as a picture, not a description.** Two or three variants in one HTML file, same content, different treatment. A switch in the corner flips between them; a second switch turns an effect on and off so its contribution is visible.
3. **A README with a table.** Each mockup folder has a README: my request verbatim, how to run it, a table of variants with "how it looks / pluses / risks", the scenes or animations described one by one, and the copy with its meaning.
4. **I pick, the model records.** The choice goes into the README and into the project's decisions file. Rejected variants stay in the folder; they are often reused weeks later.
5. **Transfer through the pipeline.** The chosen variant becomes a feature. The explorer phase reads the mockup, the architecture phase decides how it maps onto the site's components, and the review checks it against the site's conventions. The mockup is the specification; the code is not a copy of it.

## The folder

```
mockups/problem-cards-2026-10-06/
  README.md        request, how to run, variants table, scenes, copy
  index.html       the mockup, all variants, switches in the corner
  serve.mjs        a static server on a fixed port
  refs/            reference screenshots
```

`examples/mockup-README.example.md` is a real one, translated.

## Rules the model follows

- **Scale from a design pixel.** Anything drawn (a face made of cubes, a card scene) is built in design units with one CSS variable `--u` that equals one pixel at the design size and scales with the container. Checked byte for byte at 1x before scaling.
- **Pick in context.** The mockup shows the block between a static frame of the block above and a placeholder of the block below, so the order and the rhythm of the page are visible.
- **Motion has a lab.** Animations are tried on a separate lab page before they are committed to a variant. What worked gets a name and goes into the site's motion pack.
- **Phone first for the breakpoint, not last.** Each variant has its phone behaviour described in the table's risk column. "Falls back to a plain list on the phone" is a legitimate answer, but it is said upfront.
- **Heavy rendering asks first.** Recording a WebGL scene headless starves the GPU and freezes my browser. Before a long recording the model asks.
- **Look at it with eyes.** Same as for the site: full-page frames at four window sizes before the mockup is handed over.

## Why not describe it in words

Early on, the model asked me to choose a visual style from a list of words. I picked the option marked "recommended", and the prototype built on it was thrown out whole: it was not what I wanted at all. Taste shows up only in a picture. Three weeks later it happened again with three variants built from existing components; I rejected all three and asked for references instead: one page with screenshots of how other sites solve the same block, with "how it works / what to take / what not to take" under each. A switch between variants on a real page, or a page of real references, costs the model less than a wrong prototype.
