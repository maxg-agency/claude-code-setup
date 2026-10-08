# The model runs through the subscription, not an API key

Every demo, bot and personal tool here calls the model the same way: a local `claude -p` subprocess under my Claude subscription. There are no API keys in those projects. This page is the rule, the pattern, and the limits.

## The rule

- For demos and personal projects, the model is called by spawning the `claude` CLI in print mode. No key is created, no billing exists at a stage where there are no clients.
- The call lives in exactly one module of the project. When a client version is needed, that module is replaced with an API-key implementation and nothing else changes.
- Cost is measured as a share of the subscription's limits, not in dollars. A frequent call gets the smallest model that does the job and thinking turned off.
- When I check whether an assistant "works with keys", I do not create a key. I start a local session and point the assistant at it.

## The pattern

A thin runner module:

- Spawns the CLI with `-p`, `--output-format json` (or `stream-json` for a long-lived session), and the model by its full name, not an alias. Aliases mean different models in different CLI versions.
- Inherits the environment. A cleaned environment breaks the keychain login.
- Strips the variables that mark "I am inside a Claude Code session" before spawning, otherwise the child refuses to start.
- Has a watchdog: a timeout, and a kill of the process group on timeout so no grandchild survives.
- For structured answers passes `--json-schema` and no tools, so the output is parseable without prompt tricks.
- For images passes `--allowedTools Read` and the file path; the model reads the file itself.

For frequent calls, one living session with `--input-format stream-json --output-format stream-json` and state through `--resume` answers in 1.4–1.7 seconds per turn on the small model with thinking disabled. That was measured for a call assistant that suggests the next line during a live conversation.

Working directory matters: starting the CLI at the root of a large notes vault pulls the global rules, memory index and skill list into every call. Measured at about 114k input tokens for "read one file". Frequent calls get a clean working directory and `--add-dir` for what they need.

## Security: untrusted text in the prompt

Every headless call under my login mounts the same things my interactive session has: the claude.ai connectors (Gmail with send, Drive, Calendar, Docs), the Telegram plugin, and about thirty built-in tools. A bot that feeds other people's posts, emails or messages into the prompt with permissions skipped is an injection path: a planted instruction could send mail or run a shell command.

So a "text in, text out" call is made with tools and connectors switched off explicitly:

```
claude -p --tools "" --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
  --settings '{"crossSessionInbound":"refuse"}' --model <full model name> \
  --output-format json < prompt.txt
```

`--tools ""` removes the built-in tools. `--strict-mcp-config` with an empty server list removes the connectors and plugins. The settings flag stops neighbouring sessions from sending messages into the call. The prompt goes through stdin, because a prompt that begins with a YAML header is otherwise parsed as a flag and the call fails without an answer.

## What is allowed and what is not

Checked against the subscription terms and the CLI's behaviour as of October 2026; re-check before relying on it.

Allowed:
- My own tools calling the CLI under my login on my machines, including a server with a long-lived token created by `claude setup-token` and stored in an environment variable.
- A client bringing their own subscription and logging in themselves on their own machine.

Not allowed:
- Letting other people's requests flow through my subscription.
- Using the subscription token inside third-party SDKs or wrappers; the server rejects it.
- Storing other people's tokens.

For a paid product the two legal models are: my API key with token cost built into the price, or the client's own subscription. The runner module exists so that switching between them is a one-file change.
