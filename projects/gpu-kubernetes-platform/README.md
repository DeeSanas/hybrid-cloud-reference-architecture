# Enterprise GPU Infrastructure Reference Architecture

A reference architecture for operating GPU-backed AI/ML workloads on Kubernetes while separating general platform concerns from GPU scheduling, high-throughput data paths, accelerator observability and capacity governance.

> **Positioning:** This repository section is an architecture and capacity-planning lab. It does not represent a customer production deployment and does not prescribe a specific GPU model, Kubernetes distribution or AI framework.

## Design goals

- Dedicated GPU worker pools with explicit labels, taints and resource requests
- Clear separation between interactive development, batch training and inference workloads
- Capacity governance so expensive accelerator resources are schedulable and measurable
- High-throughput access to object/file storage and optional node-local caching
- Low-latency east-west networking for distributed workloads where required
- Central GPU, node, container and application telemetry
- Secure image, model and dataset supply chains
- Failure-domain-aware node placement and maintenance procedures

## Logical architecture

```text
Users / ML Pipelines / APIs
           |
  Kubernetes Control Plane
           |
   Scheduler / Quotas / Policy
           |
  +--------+---------+
  |                  |
General Nodes      GPU Node Pool
                     |
          Device Resource Exposure
                     |
         Training / Inference Pods
             |              |
       Local Cache      Shared Storage
             |              |
        High-speed Network / Object Store
                     |
       GPU + Platform Observability
```

## Reference architecture decisions

| Area | Reference decision |
|---|---|
| Scheduling | Require explicit GPU resource requests; avoid accidental placement on GPU nodes |
| Isolation | Use dedicated node pools and taints/tolerations |
| Capacity | Track physical GPUs, allocatable GPUs, reserved headroom and utilization |
| Storage | Separate durable model/data storage from optional ephemeral node-local cache |
| Network | Size east-west bandwidth for distributed training only when workloads justify it |
| Security | Control images, secrets, datasets and model access independently |
| Observability | Collect accelerator health/utilization plus Kubernetes and application telemetry |
| Operations | Drain and maintain GPU nodes through documented disruption procedures |

## Included artifacts

- [`models/capacity.json`](models/capacity.json) — sample GPU capacity model
- [`scripts/capacity.py`](scripts/capacity.py) — deterministic capacity calculator
- [`manifests/gpu-workload.json`](manifests/gpu-workload.json) — Kubernetes example requesting a GPU resource

## Capacity model

```bash
python projects/gpu-kubernetes-platform/scripts/capacity.py \
  projects/gpu-kubernetes-platform/models/capacity.json
```

The model distinguishes physical capacity from target schedulable capacity so operations can retain maintenance and failure headroom.

## Operational questions

- What percentage of GPU capacity must remain available for node failure or maintenance?
- Are workloads single-GPU, multi-GPU, or distributed across nodes?
- Is GPU partitioning supported and operationally justified for the target accelerator?
- What dataset and checkpoint throughput is required?
- Which jobs may be preempted and which have strict completion deadlines?
- How are model artifacts, container images and datasets promoted between environments?
- Which accelerator health signals trigger workload evacuation or node maintenance?

## Example acceptance criteria

- Non-GPU workloads do not schedule onto dedicated GPU nodes by default.
- GPU workloads request accelerators explicitly and are visible in capacity accounting.
- Operators can identify physical, allocated and headroom capacity.
- A GPU node can be drained without violating the documented disruption policy for critical services.
- Accelerator telemetry can be correlated with pod, node and application behavior.

## Trade-offs

Maximizing accelerator utilization is not always the same as maximizing platform reliability. High utilization targets reduce cost per workload but leave less room for failures, maintenance and burst demand. The appropriate reserve must be driven by workload criticality and recovery expectations.
