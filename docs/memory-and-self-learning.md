# Memory and self-learning

The model does not remember between sessions. What it has is a folder of small files and an index that is loaded every time. The folder grows by one file each time I correct it. After a few months it holds the things a colleague would know: how I like pages laid out, which tools are broken on my machine, what I decided last week and why.

## The shape

```
memory/
  MEMORY.md                 one line per file, loaded into every session
  feedback_*.md             corrections: what the rule is, why, how to apply
  project_*.md              ongoing work and constraints not derivable from the code
  reference_*.md            pointers: URLs, ports, gotchas of a tool
  user_*.md                 who I am, how I work
```

One fact per file. Each file has frontmatter with a name, a one-line description used for recall, and a type. Files link to each other with `[[name]]`.

```markdown
---
name: site-verify-cpu
description: The site's verify script eats ~70% CPU for 6–9 minutes; run it once at the end, not after every edit
metadata:
  type: feedback
---
Run the full `verify` once at the end of the work. During the work use `tsc` and the linters only.

**Why:** the user noticed the laptop slowing down after the fifth full run in one session; it is their working machine.

**How to apply:** before "done", one verify. Portrait click checks in it are flaky; rerun once before reporting a failure. Related: [[look-at-page-after-content-change]].
```

## The loop

1. I correct the model, or confirm an approach it proposed.
2. It writes one file. For a correction, the "why" is the incident and the "how to apply" is the concrete check to run next time. Relative dates become absolute.
3. It adds one line to `MEMORY.md`: title, filename, a hook of a few words.
4. Next session the index is in context. The model opens a file only when the index line looks relevant to the task.

Before writing, it looks for an existing file that already covers the fact and updates it rather than creating a duplicate. Facts that turn out wrong get deleted. Things the repository already records (code structure, git history, project docs) are not saved.

## What goes in and what does not

In: rules I gave and why; approaches I confirmed; project state that is not in the code (what is waiting for my decision, what was deprioritized); tool gotchas with the date they were observed.

Not in: anything derivable from the code; conversation-only details; secrets; other people's personal data.

## Where the "self-learning" actually lives

There is no hook that logs sessions and trains anything. The learning is three layers of plain files:

| Layer | What | Who reads it |
|---|---|---|
| Memory folder | rules, decisions, gotchas | every session, via the index |
| Plan files and blueprints | the full context of each feature: findings, answers, chosen architecture, review results | the next agent on that feature; a later feature in the same area |
| Project journals | `DECISIONS.md`, a roadmap with a dated log section, a tone-of-voice journal with "took / did not take" after each post, an errors log for language practice | the skill that owns the journal |

Claude Code also stores full session transcripts locally. They are useful for forensics (finding which script left an orphan process) but they are not something the model reads back on its own, and they are not published.

## Sample

The `memory/` folder in this repo holds a handful of real rules, cleaned of personal detail, and an index. They are there to show the format. Do not copy them into your own memory folder: they would teach your agent my preferences. Your memory grows from your corrections; Claude Code writes the files itself when it is told to remember something or when it is corrected.
