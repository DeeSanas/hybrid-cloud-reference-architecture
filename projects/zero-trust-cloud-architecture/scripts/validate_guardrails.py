#!/usr/bin/env python3
import json
import sys
from pathlib import Path

REQUIRED_FIELDS = {"id", "domain", "control", "enforcement", "owner", "evidence", "required"}
REQUIRED_DOMAINS = {"identity", "authorization", "network", "workload-identity", "data", "telemetry", "resilience"}


def fail(message: str) -> None:
    print(f"ERROR: {message}")
    raise SystemExit(1)


def main() -> None:
    if len(sys.argv) != 2:
        fail("usage: validate_guardrails.py <guardrails.json>")

    data = json.loads(Path(sys.argv[1]).read_text())
    controls = data.get("controls")
    if not isinstance(controls, list) or not controls:
        fail("controls must be a non-empty list")

    ids = set()
    domains = set()
    for index, control in enumerate(controls, start=1):
        missing = REQUIRED_FIELDS - set(control)
        if missing:
            fail(f"control {index} missing fields: {', '.join(sorted(missing))}")
        if control["id"] in ids:
            fail(f"duplicate control id: {control['id']}")
        ids.add(control["id"])
        domains.add(control["domain"])
        if control["required"] is not True:
            fail(f"reference baseline control {control['id']} must be marked required")
        for field in ("control", "enforcement", "owner", "evidence"):
            if not str(control[field]).strip():
                fail(f"control {control['id']} has empty {field}")

    missing_domains = REQUIRED_DOMAINS - domains
    if missing_domains:
        fail(f"missing baseline domains: {', '.join(sorted(missing_domains))}")

    print(f"Zero Trust guardrail validation: PASS ({len(controls)} controls)")


if __name__ == "__main__":
    main()
