# kitty hints "customize-processing" handler.
#
# Why this file exists:
#   1. kitty's built-in `--type=linenum` action can ONLY substitute {path} and
#      {line} -- it throws away any `column` group, so it can't open at a column.
#   2. Passing a regex on the kitty.conf `map` line is fragile: spaces and
#      backslashes get mangled by config/arg parsing. So we do BOTH the matching
#      (mark) and the opening (handle_result) here in Python.
#
# Wired up from kitty.conf with just:
#   map ctrl+shift+m kitten hints --customize-processing hints_open.py --hints-text-color=green
#
# Detects  path:line  or  path:line:column  and opens it in the running nvim
# (via nvr) at the exact line and column. See ~/notes/kitty.md.

import os
import re
import shutil
import subprocess
import traceback
from typing import Any, Generator, List, Sequence

LOG = os.path.expanduser("~/.cache/kitty-hints_open.log")

# path = run of non-space, non-colon chars; line/column = digits, column opt.
PAT = re.compile(r"(?P<path>[^\s:]+):(?P<line>\d+)(?::(?P<column>\d+))?")


def _log(msg: str) -> None:
    try:
        with open(LOG, "a") as f:
            f.write(msg.rstrip() + "\n")
    except Exception:
        pass


def mark(
    text: str, args: Any, Mark: Any, extra_cli_args: Sequence[str], *a: Any
) -> Generator[Any, None, None]:
    for idx, m in enumerate(PAT.finditer(text)):
        start, end = m.span()
        mark_text = text[start:end].replace("\n", "").replace("\0", "")
        # 5th field is an arbitrary dict carried through to handle_result.
        yield Mark(idx, start, end, mark_text, m.groupdict())


def handle_result(
    args: List[str],
    data: dict,
    target_window_id: int,
    boss: Any,
    extra_cli_args: Sequence[str],
    *a: Any,
) -> None:
    try:
        _log("---- handle_result ---- cwd=%r match=%r groupdicts=%r" % (
            data.get("cwd"), data.get("match"), data.get("groupdicts")))
        nvr = shutil.which("nvr") or os.path.expanduser("~/.local/bin/nvr")
        for g in data["groupdicts"]:
            path = g.get("path")
            if not path:
                continue
            line = g.get("line") or 1
            col = g.get("column") or 1
            cmd = [nvr, "--remote", path, "-c", f"call cursor({line},{col})"]
            _log("running: %r" % (cmd,))
            try:
                boss.run_background_process(
                    cmd, cwd=data["cwd"], allow_remote_control=False
                )
            except Exception:
                _log("run_background_process failed:\n" + traceback.format_exc())
                subprocess.Popen(cmd, cwd=data["cwd"])
    except Exception:
        _log("EXCEPTION:\n" + traceback.format_exc())
