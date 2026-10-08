# Extra skills

Skills are folders under `~/.claude/skills/<name>/SKILL.md`. The ones below are either included here or linked to their source. My other skills are personal and are not published.

## Included in this repo

| Skill | What it does |
|---|---|
| `feature-dev` | The feature pipeline with the size check, plus its three helper agents in `agents/`. See `docs/feature-dev.md`. |

## Third-party skills I use, linked to their sources

| Skill | Source | Why it is here |
|---|---|---|
| `grill-me` | Matt Pocock, https://github.com/mattpocock/skills | Interviews you about a plan one question at a time, with a recommended answer for each, until every branch of the decision tree is resolved. I run it on my own plans before the model builds them. Install: copy `grill-me/SKILL.md` from that repo into `~/.claude/skills/grill-me/`. |
| `seo-audit` | Part of a marketing skills collection (search for "seo-audit SKILL.md"; the file carries its own version header) | A structured technical and on-page audit for a site. I run it before and after writing long-form pages. |
| `ui-ux-pro-max` | https://github.com/nextlevelbuilder/ui-ux-pro-max-skill | A searchable local database of styles, palettes, font pairings, UX guidelines and chart types with a Python search script. Domain searches ("fintech dashboard", "landing for a studio") are useful; vague ones ("premium") miss. |

The `agent-teams` plugin by Ilia Izmailov adds five more skills for team-style builds; see `docs/tools.md`.

## A skill I keep private: the editor

There is a skill that edits my native-language copy. It works from meaning: first the structure and what each block must say, then the prose, then a checker that flags my four recurring mistakes and the tells of machine-written text. It keeps a journal of what I accepted and rejected after every piece, so the next edit starts from my taste rather than from scratch.

It is not published because the rules are specific to one language and one voice. The pattern is reusable, though: a skill that owns a journal of your corrections learns faster than one that relies on the general memory.

## How to write your own

A skill is a Markdown file with a frontmatter `name` and `description`. The description is what the model matches against your request, so it lists the phrases you actually say. The body is instructions, in the order the model should follow them. Two habits that made mine better:

- A state file. Anything longer than one turn writes its state to a file the next session can resume from.
- A journal. Anything with taste involved writes "took / did not take" after each run, and reads it before the next.
