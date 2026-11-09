# Gemini CLI in tmux

Use `--cli-tool gemini-cli`; the installed executable is `gemini`. The launcher invokes `gemini [--model MODEL] -- PROMPT` with the positional prompt requested by this skill. Session interactivity follows the installed CLI's positional-prompt behavior.

From the skill directory:

```bash
uv run --script tools/open_tmux.py \
  --session-name gemini-docs \
  --cli-tool gemini-cli \
  --model gemini-2.5-flash \
  --cd /absolute/path/to/project \
  --context-payload 'Read the source and propose documentation improvements.'
```

Omit `--model` to retain the configured default. For conversation background, use `--context-file /absolute/path/to/context.yaml` instead of `--context-payload`. Normal Gemini CLI permission settings apply.
