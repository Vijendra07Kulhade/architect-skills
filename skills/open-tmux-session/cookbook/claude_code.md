# Claude Code in tmux

Use `--cli-tool claude-code`; the installed executable is `claude`. The launcher invokes `claude [-m MODEL] -p -- PROMPT`. The requested `-p` mode prints a response and exits, leaving the tmux shell available for another command.

From the skill directory:

```bash
uv run --script tools/open_tmux.py \
  --session-name claude-analysis \
  --cli-tool claude-code \
  --model sonnet \
  --cd /absolute/path/to/project \
  --context-payload 'Analyze the parser and summarize its edge cases.'
```

Omit `--model` to retain the configured default. For conversation background, use `--context-file /absolute/path/to/context.yaml` instead of `--context-payload`. Normal Claude Code permission settings apply.
