#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"ERROR: {message}")
    raise SystemExit(1)


def main() -> None:
    if len(sys.argv) != 2:
        fail("usage: validate_workload.py <gpu-workload.json>")

    pod = json.loads(Path(sys.argv[1]).read_text())
    if pod.get("kind") != "Pod":
        fail("example must be a Kubernetes Pod")

    spec = pod.get("spec", {})
    if spec.get("nodeSelector", {}).get("workload-class") != "gpu":
        fail("GPU workload must target the gpu workload class")

    tolerations = spec.get("tolerations", [])
    if not any(t.get("key") == "workload-class" and t.get("value") == "gpu" for t in tolerations):
        fail("GPU workload must tolerate the dedicated GPU node taint")

    containers = spec.get("containers", [])
    if not containers:
        fail("pod must contain at least one container")

    for container in containers:
        resources = container.get("resources", {})
        req = resources.get("requests", {})
        lim = resources.get("limits", {})
        if int(req.get("nvidia.com/gpu", "0")) < 1:
            fail("container must request at least one GPU")
        if req.get("nvidia.com/gpu") != lim.get("nvidia.com/gpu"):
            fail("GPU request and limit must match in the reference workload")
        if not req.get("cpu") or not req.get("memory"):
            fail("CPU and memory requests are required")

    print("GPU workload validation: PASS")


if __name__ == "__main__":
    main()
