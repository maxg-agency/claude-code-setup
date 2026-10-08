# Testing in a browser the model can drive

Most of what I build has a face: a landing page, a dashboard, a form. "The tests pass" says little about whether the page looks right. So the model gets browsers. Two of them, because they do different jobs.

## 1. My real Chrome, through the Claude in Chrome extension

When I type `@browser` in a session, the extension's tools appear and the model can open tabs in my own Chrome: navigate, read page text, run JavaScript, click, hover, take screenshots, record a short GIF.

**What it is for.** Other people's websites. Design references, checking a hover effect on a live page, filling a form on a service that has no API, research where a plain fetch does not see JavaScript-rendered content. Anything that needs my logged-in state.

**Rules that keep it safe.**

- The model works in its own tab group and starts by asking the extension for the tab context.
- My clipboard is off limits. I am working in parallel and keep my own text there.
- Downloading a file needs my explicit "yes" in the chat.
- If the extension does not respond after two or three tries, the model says "turn on the browser" and continues with the rest of the work instead of retrying.

**Gotchas the model learned** (each is a memory file with a date):

- The agent's tab is hidden, so timers in it barely run and the page renders only at the moment of a screenshot. A script that waits inside the page times out. Pattern: script without waits, then screenshot, then next script.
- JavaScript results are cut at about a thousand characters. Large data comes out in batches of a dozen rows, verified by a hash the page computes.
- Results that look like cookies or query strings are blocked by a filter. Do not print class names or `a=b; c=d` patterns.
- Clicking by element reference does not always work; coordinates from a fresh screenshot are the fallback, and the window size changes between calls.

## 2. Headless Chrome over the DevTools protocol, for our own pages

For pages I am building, the model starts Chrome itself with `--headless=new` and a random debugging port, connects over the DevTools protocol and drives it from a Node script. The project's UI check script works the same way and is the template.

**What it is for.** Full-page screenshots at several window sizes, measuring element edges, checking that a sticky card stack does not overlap before it can be read, verifying that every section of a page is present.

**The rule that came from two incidents.** The automated check passed 515 of 515 while the page had an empty right column and an unstyled table. A week later it passed again while the portrait on the About page was misaligned and cards on the phone overlapped. So now, after any content change that alters the shape of a page:

- Screenshots at four windows: desktop 1440×900, laptop 1280×720, tablet 820×1180, phone 390×844. Both languages if the site has two.
- Without reduced motion. Reduced motion turns a card stack into a plain list and hides exactly the overlap I was looking for.
- Anything scroll-dependent is captured mid-scroll, and the model computes the reading margin: window height minus the sticky offset minus the card height. Less than a third of the window means the card cannot be read in time.
- Alignment is checked by measuring `getBoundingClientRect` edges, not by eye.
- A long word in a heading is checked separately in each narrow column.
- The model names the layout breaks itself in the report. It does not wait for me to find them.

**The orphan rule.** Scripts that start a browser left processes running for a day. Four headless Chromes, one of them eating fifteen percent of a core for 28 hours, and a hundred and thirty temporary profiles taking four gigabytes. The causes were mundane: a script piped through `head` died on a closed pipe before reaching its cleanup line; a path with a slash in a filename crashed another two lines before `chrome.kill`. So:

- Cleanup runs on `exit`, `SIGINT` and `SIGTERM`, not only at the end of the happy path. The `exit` hook fires after an unhandled exception too.
- Debugging port `0`, read from the `DevToolsActivePort` file. A fixed port collides with another session's Chrome.
- Output goes to a file, never through `| head`.
- A Python test runner with a timeout starts the child in a new session and kills the process group on timeout, otherwise the grandchild lives forever.
- Before "done", if any script in the session started a browser or a server: list the headless processes and kill the strays.

## Local servers and the release ladder

The browsers above look at pages served locally. Two servers run for the site: one with everything (where I proofread), one that mirrors production by building a clone with only the released pages. The model starts both when asked to "start the servers". A phone-reachable address is given only when I ask for it.

Forms are a trap: locally, the hosting's form endpoint does not exist, so a submit fails and I once concluded the form was broken. Now any change that touches a form puts a tiny proxy in front of the dev server that answers 200 to the form post and sends nothing anywhere, and the message to me says so.

In my own projects changes go local first, then staging after my check, then production. That is my habit for sites with paid deploys, not part of the installed rules.
