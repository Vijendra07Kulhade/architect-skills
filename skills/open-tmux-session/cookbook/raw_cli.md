# Raw commands in tmux

Use `--cli-tool bash`. `--context-payload` is the raw command string; `--context-file` instead reads a UTF-8 file containing that command. The launcher sends it unchanged to a new session's shell, or after a quoted `cd` on reuse. `--model` is invalid in this mode.

From the skill directory:

```bash
uv run --script tools/open_tmux.py \
  --session-name test-run \
  --cli-tool bash \
  --cd /absolute/path/to/project \
  --context-payload 'python3 -m unittest discover > /tmp/test-run.log 2>&1'
```

Pipes, redirections, substitutions, and command lists execute as shell code. Quote the outer payload argument so the invoking shell passes that code to the launcher intact. For Bash-specific syntax in a session whose shell may differ, submit an explicit `bash -lc 'COMMAND'` command, with the inner command quoted as a single argument.

Reusing the same session requires an idle shell in its active pane. For a long-running server or watcher, submit a separate session name for each concurrent job. Capture pane output or inspect an explicit log file to determine completion; the JSON response only confirms submission.
