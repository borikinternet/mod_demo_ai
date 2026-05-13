#!/usr/bin/env python3

from pathlib import Path

TOKENS = (
    "NORMAL_TEMPORARY_FAILURE",
    "UNALLOCATED_NUMBER",
    "9196",
    "INVITE",
    "SIP/2.0",
    "sofia/internal",
    "403",
    "404",
    "480",
    "488",
    "503",
)


for role in ("callee", "primary"):
    path = Path("/opt/fs-ha-lab") / role / "log" / "freeswitch.log"
    print(f"== {role} ==")
    if not path.exists():
        print(f"missing: {path}")
        continue

    selected = [
        line.rstrip()
        for line in path.read_text(errors="ignore").splitlines()
        if any(token in line for token in TOKENS)
    ]
    for line in selected[-60:]:
        print(line)