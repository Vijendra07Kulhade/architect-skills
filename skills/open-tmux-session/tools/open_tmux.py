#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""Create or reuse a detached tmux session and submit one command as JSON."""

import argparse
import json
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys


class InputError(ValueError):
    """A CLI usage error that should be reported as JSON."""


class JsonParser(argparse.ArgumentParser):
    def error(self, message):
        raise InputError(message)


def parse_args(argv=None):
    parser = JsonParser(description=__doc__)
    parser.add_argument("--session-name", default="agent-session")
    parser.add_argument("--cli-tool", choices=("codex", "claude-code", "gemini-cli", "bash"),
                        required=True)
    parser.add_argument("--model", help="Omit to use the AI CLI's configured default")
    context = parser.add_mutually_exclusive_group(required=True)
    context.add_argument("--context-file", type=Path, help="UTF-8 prompt or raw command file")
    context.add_argument("--context-payload", help="Prompt text, or a raw command for bash")
    parser.add_argument("--cd", type=Path, default=Path.cwd(), dest="directory")
    return parser.parse_args(argv)


def build_command(cli_tool, model, payload):
    if cli_tool == "bash":
        if model is not None:
            raise InputError("--model applies only to AI CLIs")
        return payload
    executable, model_flag = {
        "codex": ("codex", "--model"),
        "claude-code": ("claude", "-m"),
        "gemini-cli": ("gemini", "--model"),
    }[cli_tool]
    parts = [executable]
    if model is not None:
        if not model.strip() or model.startswith("-"):
            raise InputError("--model must be a nonempty model identifier")
        parts.extend([model_flag, model])
    if cli_tool == "claude-code":
        parts.append("-p")
    # End options so a prompt beginning with '-' stays a positional argument.
    parts.extend(["--", payload])
    return shlex.join(parts)


def main(argv=None):
    response = {"status": "error", "session_name": "agent-session",
                "command_executed": "", "stdout": "", "stderr": ""}
    try:
        args = parse_args(argv)
        response["session_name"] = args.session_name
        if not re.fullmatch(r"[A-Za-z0-9_-]+", args.session_name):
            raise InputError("Session names must contain only letters, digits, '_' or '-'")
        directory = args.directory.expanduser().resolve()
        if not directory.is_dir():
            raise InputError(f"Working directory does not exist: {directory}")
        payload = (args.context_file.expanduser().read_text(encoding="utf-8")
                   if args.context_file is not None else args.context_payload)
        if not payload.strip():
            raise InputError("Context or raw command must not be empty")
        if any(ord(char) < 32 and char not in "\n\t" for char in payload) or "\x7f" in payload:
            raise InputError("Context or raw command contains unsupported terminal control characters")
        command = build_command(args.cli_tool, args.model, payload)
        tmux = shutil.which("tmux")
        if tmux is None:
            raise InputError("tmux is not installed or is not on PATH; install tmux and retry")

        def run(*arguments):
            return subprocess.run([tmux, *arguments], capture_output=True, text=True,
                                  encoding="utf-8", errors="replace", check=False)

        def require_success(result):
            response["stdout"] += result.stdout
            response["stderr"] += result.stderr
            if result.returncode:
                raise RuntimeError(f"tmux failed with exit code {result.returncode}")

        # '=' prevents tmux's prefix matching from selecting a similarly named session.
        target = "=" + args.session_name
        probe = run("has-session", "-t", target)
        if probe.returncode == 1:
            require_success(run("new-session", "-d", "-s", args.session_name,
                                "-c", str(directory)))
        elif probe.returncode != 0:
            require_success(probe)
        else:
            # new-session -c applies only to creation; honor --cd on reuse too.
            command = f"cd -- {shlex.quote(str(directory))} && {command}"
        response["command_executed"] = command
        # Send literal text and Enter separately so strings such as 'C-c' stay text.
        require_success(run("send-keys", "-t", target, "-l", "--", command))
        require_success(run("send-keys", "-t", target, "C-m"))
        response["status"] = "success"
    except (InputError, OSError, UnicodeError, RuntimeError) as exc:
        response["stderr"] += ("\n" if response["stderr"] else "") + str(exc)
    print(json.dumps(response, ensure_ascii=True))
    return 0 if response["status"] == "success" else 1


if __name__ == "__main__":
    sys.exit(main())
