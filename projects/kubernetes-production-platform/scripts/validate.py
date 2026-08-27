#!/usr/bin/env python3
import json
import sys
from pathlib import Path

REQUIRED_KINDS = {"Namespace", "ResourceQuota", "NetworkPolicy", "PodDisruptionBudget"}


def fail(message: str) -> None:
    print(f"ERROR: {message}")
    raise SystemExit(1)


def main() -> None:
    if len(sys.argv) != 2:
        fail("usage: validate.py <platform.json>")

    path = Path(sys.argv[1])
    data = json.loads(path.read_text())

    if data.get("kind") != "List" or not isinstance(data.get("items"), list):
        fail("manifest must be a Kubernetes List with items")

    items = data["items"]
    kinds = {item.get("kind") for item in items}
    missing = REQUIRED_KINDS - kinds
    if missing:
        fail(f"missing required Kubernetes objects: {', '.join(sorted(missing))}")

    namespaces = [i for i in items if i.get("kind") == "Namespace"]
    if not any(i.get("metadata", {}).get("name") == "platform-prod" for i in namespaces):
        fail("platform-prod namespace is required")

    policies = [i for i in items if i.get("kind") == "NetworkPolicy"]
    default_deny = False
    for policy in policies:
        spec = policy.get("spec", {})
        if spec.get("podSelector") == {} and set(spec.get("policyTypes", [])) == {"Ingress", "Egress"}:
            default_deny = True
            break
    if not default_deny:
        fail("default-deny ingress and egress NetworkPolicy is required")

    quotas = [i for i in items if i.get("kind") == "ResourceQuota"]
    if not all(i.get("spec", {}).get("hard") for i in quotas):
        fail("ResourceQuota must define hard limits")

    pdbs = [i for i in items if i.get("kind") == "PodDisruptionBudget"]
    if not any("minAvailable" in i.get("spec", {}) or "maxUnavailable" in i.get("spec", {}) for i in pdbs):
        fail("PodDisruptionBudget must define minAvailable or maxUnavailable")

    print("Kubernetes platform baseline validation: PASS")


if __name__ == "__main__":
    main()
