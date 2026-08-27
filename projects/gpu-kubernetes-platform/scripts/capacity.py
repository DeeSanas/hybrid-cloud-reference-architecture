#!/usr/bin/env python3
import json
import math
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"ERROR: {message}")
    raise SystemExit(1)


def main() -> None:
    if len(sys.argv) != 2:
        fail("usage: capacity.py <capacity.json>")

    data = json.loads(Path(sys.argv[1]).read_text())
    required = [
        "nodes",
        "gpus_per_node",
        "gpu_memory_gb",
        "schedulable_fraction",
        "maintenance_reserve_nodes",
        "average_gpus_per_workload",
    ]
    for key in required:
        if key not in data:
            fail(f"missing field: {key}")

    nodes = int(data["nodes"])
    gpus_per_node = int(data["gpus_per_node"])
    gpu_memory_gb = float(data["gpu_memory_gb"])
    schedulable_fraction = float(data["schedulable_fraction"])
    reserve_nodes = int(data["maintenance_reserve_nodes"])
    avg_per_workload = int(data["average_gpus_per_workload"])

    if nodes <= 0 or gpus_per_node <= 0 or gpu_memory_gb <= 0 or avg_per_workload <= 0:
        fail("node, GPU and workload values must be positive")
    if not 0 < schedulable_fraction <= 1:
        fail("schedulable_fraction must be greater than 0 and at most 1")
    if reserve_nodes < 0 or reserve_nodes >= nodes:
        fail("maintenance_reserve_nodes must be >= 0 and less than total nodes")

    physical_gpus = nodes * gpus_per_node
    failure_adjusted_gpus = (nodes - reserve_nodes) * gpus_per_node
    schedulable_gpus = math.floor(failure_adjusted_gpus * schedulable_fraction)
    workload_slots = schedulable_gpus // avg_per_workload
    physical_memory_tb = physical_gpus * gpu_memory_gb / 1024

    print(f"Cluster: {data.get('cluster', 'unnamed')}")
    print(f"Physical GPUs: {physical_gpus}")
    print(f"Physical GPU memory: {physical_memory_tb:.2f} TiB")
    print(f"GPUs after maintenance reserve: {failure_adjusted_gpus}")
    print(f"Target schedulable GPUs: {schedulable_gpus}")
    print(f"Approximate concurrent workload slots: {workload_slots}")


if __name__ == "__main__":
    main()
