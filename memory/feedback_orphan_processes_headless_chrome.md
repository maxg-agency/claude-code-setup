---
name: feedback_orphan_processes_headless_chrome
description: Throwaway scripts with headless Chrome and test runners with timeouts leave orphan processes; cleanup must sit on every exit path
metadata:
  type: feedback
---
Throwaway scripts (in the scratchpad) that drive headless Chrome over the DevTools protocol, and test runners with a timeout, leave orphan processes that live for days and eat CPU. Cleanup must be on every exit path, not only at the end of the happy path.

**Why:** the user asked what was loading the CPU. Four headless Chromes (one GPU process at ~15% for 28 hours) and four hung test runners were found. From the transcripts:
- `node shot.mjs … | head -6`: `head` closed the pipe, node died on EPIPE before the `chrome.kill("SIGKILL")` line, the exit code was hidden by the pipeline. Three Chromes left.
- another script crashed on a missing path (a slash in a frame name) two lines before `chrome.kill()`. One more Chrome.
- a Python runner called tests one by one through `subprocess.run([uv, "run", "python", …], timeout=45)`. On timeout `uv` is killed; the grandchild `python` lives forever in a socket wait. Four orphans.
- Chrome profiles in the temp directory are never deleted: 136 folders, 3.9 GB in ten days.

**How to apply:**
- Any script that starts Chrome: `process.on("exit", cleanup)` plus `SIGINT`/`SIGTERM` → `process.exit`, where `cleanup` = `chrome.kill("SIGKILL")` + remove the profile folder. The `exit` hook fires after an unhandled exception too.
- Port only `--remote-debugging-port=0` (read from `DevToolsActivePort`). A fixed or random port collides with another session's Chrome.
- Do not cut node output with `| head -N`: write to a file and read the file, or use `sed -n '1,6p'` (sed drains the stream).
- A Python runner with a timeout: `start_new_session=True` and on `TimeoutExpired` `os.killpg(p.pid, SIGKILL)`; or run the venv's python directly without `uv run` in between.
- After a crash of a script that started a browser or a server: `pgrep -fl -- --headless=new` and kill the strays. Check before "done" if the session ran even one such script.
