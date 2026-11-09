# Codex in tmux

Use `--cli-tool codex`. The launcher invokes `codex [--model MODEL] -- PROMPT`, keeping Codex interactive in the target pane. Omit `--model` to retain its configured default; pass an explicit requested identifier unchanged.

From the skill directory:

```bash
uv run --script tools/open_tmux.py \
  --session-name codex-review \
  --cli-tool codex \
  --cd /absolute/path/to/project \
  --context-payload 'Review the authentication module and report concrete defects.'
```

For a background handoff, replace `--context-payload` with `--context-file /absolute/path/to/context.yaml` containing a filled context template. Add `--model MODEL` when requested. The model flag does not change Codex's normal permission settings.
