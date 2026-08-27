#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "models/recovery-tiers.json")
    data = json.loads(path.read_text())
    tiers = data.get("tiers", [])
    if not tiers:
        raise SystemExit("No recovery tiers defined")

    failed = False
    print(f"Recovery tiers: {len(tiers)}")
    for tier in tiers:
        name = tier.get("name", "unnamed")
        rto = tier.get("rto_minutes")
        rpo = tier.get("rpo_minutes")
        if not isinstance(rto, (int, float)) or not isinstance(rpo, (int, float)):
            print(f"FAIL {name}: RTO/RPO must be numeric")
            failed = True
            continue
        if rto <= 0 or rpo < 0:
            print(f"FAIL {name}: invalid RTO/RPO values")
            failed = True
        elif rpo > rto:
            print(f"WARN {name}: RPO ({rpo}m) exceeds RTO ({rto}m)")
        else:
            print(f"PASS {name}: RTO={rto}m RPO={rpo}m")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
