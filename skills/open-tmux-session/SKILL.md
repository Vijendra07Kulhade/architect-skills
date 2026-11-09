---
name: open-tmux-session
description: Open a named tmux session or send a command to an existing session using Codex, Claude Code, Gemini CLI, or raw shell commands. Use when asked to launch an agent in tmux, hand off conversation context to a tmux agent, or run a command in a detached tmux session.
---

# Open tmux Session

Launch a task in a detached tmux session, with optional conversation background and model selection. Follow the progressive workflow and read only the matching recipe.

## Variables

Resolve these from the request; preserve explicit user choices.

| Variable | Default / meaning |
| --- | --- |
| `SESSION_NAME` | `agent-session`; letters, digits, underscores, hyphens |
| `CLI_TOOL` | Infer `codex`, `claude-code`, `gemini-cli`, or `bash` from the task; use `codex` for an unspecified AI agent |
| `MODEL` | Omit to use the selected CLI's configured default |
| `WORKING_DIRECTORY` | Current working directory |
| `CONTEXT` | AI task prompt, or the exact shell command for `bash` |

Paths below are relative to this skill's directory. Resolve the skill directory to an absolute path before invoking its script from another working directory.

## Workflow

1. Determine the target session, tool, task, working directory, and optional model. Reusing a session sends input to its active pane: establish that it is at a shell prompt before submitting a shell command. If an agent or other foreground program is running there, use a different session name or clarify the intended input.
2. Read the matching cookbook:
   - Codex: [cookbook/codex.md](cookbook/codex.md).
   - Claude Code: [cookbook/claude_code.md](cookbook/claude_code.md).
   - Gemini CLI: [cookbook/gemini_cli.md](cookbook/gemini_cli.md).
   - Raw commands: [cookbook/raw_cli.md](cookbook/raw_cli.md).
3. For a conversation handoff, read [prompts/context_summary.yaml](prompts/context_summary.yaml). Fill its fields with the relevant history, concrete next task, and constraints. Keep the template intact; pass a filled copy as `--context-payload` or write it to a UTF-8 file and use `--context-file`. The launcher forwards this text verbatim; it does not parse YAML. For a task without background, pass the task itself. In `bash` mode the payload is executable shell code, so use only the intended command.
4. Run [tools/open_tmux.py](tools/open_tmux.py) with `uv run --script`, the selected recipe, and shell-quoted argument values. Python 3.9+ can also run it directly; it has no third-party dependencies. The environment needs tmux and the chosen CLI installed and authenticated.
5. Read the JSON result. `success` means tmux accepted the command and Enter, not that the task completed. `stdout` and `stderr` describe tmux operations, not the detached task's output. On error, report the error and any session already created; inspect its pane before retrying because a failed Enter may leave text pending.

## Inspect and attach

For `SESSION_NAME=agent-session`:

```bash
tmux capture-pane -p -t '=agent-session' -S -100
tmux attach-session -t '=agent-session'
```

The launcher creates detached sessions and leaves them available after submission. On reuse, it changes to `WORKING_DIRECTORY` before running the command. It assumes a POSIX-compatible shell in the target pane. Quoting protects AI prompt text from shell expansion; raw commands intentionally retain shell syntax. Model identifiers are passed through, so use a model supported by the installed CLI and account.
