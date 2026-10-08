# Tools worth setting up

What is actually running on the laptop behind this setup, and why each piece is there.

## Claude Code plugins

| Plugin | Why |
|---|---|
| `feature-dev` (official) | Supplies the three Sonnet agents the pipeline uses: code-explorer, code-architect, code-reviewer. The wrapper in this repo replaces the plugin's main flow but keeps its agents. |
| `agent-teams` (community, by Ilia Izmailov) | Team-style development for larger tasks: a short interview, then a tech lead, coders and permanent reviewers that talk to each other. Used for comparison and for the occasional large build. |
| `frontend-design` (official) | Guidance for UI that does not look like a template. Loaded when building new interface. |

Install from inside Claude Code with `/plugin install <name>@<marketplace>`.

## Browsers the model can drive

Two of them, each for a different job. Covered in `docs/browser-testing.md`.

## Toolchain without a package manager

The laptop has no Homebrew. Everything the model needs is installed under `~/.local` and added to `PATH` in the shell profile:

- Node 24 LTS from the official tarball. Used for scripts that drive headless Chrome and for validators.
- `uv` and Python 3.12. Scripts run through `uv run`, never the system Python (which is old and has no imaging library).
- `ffmpeg` through `uv` and `imageio-ffmpeg` when a video needs cutting.

Why this matters for the model: it has to know the absolute paths, because subprocesses it spawns do not always get a login shell's `PATH`. That fact is a memory file.

## The Claude CLI itself

Two binaries exist: the standalone one in `~/.local/bin` and the one shipped with the VS Code extension. Both work headless under the subscription with `claude -p`. Things the model learned about them, each one a memory file:

- A cleaned environment (`env -i`) breaks the keychain login. Spawn with the inherited environment.
- A working directory at the root of a large notes vault pulls the global rules, memory and skill list into every call, about 114k input tokens for "read one file". For frequent calls use a clean working directory.
- Since a certain version every headless call can receive messages from neighbouring sessions. Disable with `--settings '{"crossSessionInbound":"refuse"}'`.
- A prompt passed as a positional argument must not start with `-`; a prompt that begins with a YAML header is parsed as a flag and the call fails silently. Pass the prompt through stdin.
- Every headless call under the user's login also mounts the claude.ai connectors (Gmail, Drive, Calendar). With untrusted text in the prompt that is an injection path. Switch them off per call; see `docs/subscription-not-api-keys.md`.

## Hosting

Netlify for the sites, behind Cloudflare DNS. Three things the model keeps in memory because they bit: `[[headers]]` in the Netlify config do not reach a Next.js site (use `next.config` headers instead), Netlify Forms need a static HTML file to register the form, and a build-ignore rule can silently cancel a deploy after a pause ("no content change").
