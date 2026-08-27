# Kubernetes Production Platform Reference Architecture

A production-oriented Kubernetes reference design for enterprise workloads that need resilient control-plane services, segmented networking, controlled workload placement, persistent storage, observability, policy enforcement and recoverability.

> **Positioning:** This is a reference architecture and implementation lab. It is not presented as a customer production deployment. Kubernetes distribution, CNI, CSI, ingress, backup and security products must be selected and validated for the target environment.

## Design goals

- Highly available Kubernetes control plane across independent failure domains
- Dedicated worker pools for platform, general application and specialized workloads
- Default-deny network posture with explicit east-west and north-south access
- Resource quotas, disruption budgets and scheduling controls
- Storage through CSI-backed enterprise block/file/object platforms
- Git-based change control for cluster and application configuration
- Central metrics, logs, traces and audit telemetry
- Backup and restore for cluster state plus application data
- Controlled upgrade, rollback and failure-testing procedures

## Logical architecture

See [`diagrams/architecture.mmd`](diagrams/architecture.mmd).

```text
Users / CI-CD / Operators
          |
   Ingress / API LB
          |
  Kubernetes Control Plane
    |       |       |
 Worker  Worker  Worker Pools
    |       |       |
 CNI / Network Policy / Service Mesh (optional)
          |
 CSI Storage + Secrets + Observability
          |
 Backup / DR / External Shared Services
```

## Reference node model

| Layer | Reference pattern |
|---|---|
| Control plane | 3 nodes minimum, distributed across failure domains |
| General workers | 3+ nodes with anti-affinity for critical workloads |
| Platform workers | Separate pool for ingress, monitoring and shared platform services where justified |
| GPU/specialized workers | Taints, tolerations and explicit resource requests |
| API access | Redundant load-balancer or managed endpoint |
| Pod networking | CNI with NetworkPolicy support |
| Storage | CSI-backed persistent volumes with application-aligned RPO/RTO |
| Identity | Federated authentication plus RBAC and least privilege |

## Security baseline

- Disable anonymous administrative access.
- Use RBAC groups instead of direct user grants.
- Apply default-deny NetworkPolicies and add only required flows.
- Enforce non-root execution where applications support it.
- Set CPU/memory requests and limits for production namespaces.
- Separate secrets from application images and source code.
- Protect the Kubernetes API and etcd paths from general user networks.
- Collect audit events centrally and retain them according to policy.

## Availability and recovery

HA protects against component failure; it does not replace backup or DR. A production implementation should independently validate:

- control-plane node loss;
- worker-node loss during application traffic;
- ingress/load-balancer failure;
- CNI or network-path failure;
- storage-path or storage-node failure;
- restore of Kubernetes objects and stateful application data;
- cluster upgrade and rollback procedures.

## Included artifacts

- [`diagrams/architecture.mmd`](diagrams/architecture.mmd) — editable architecture diagram
- [`manifests/base/platform.json`](manifests/base/platform.json) — portable Kubernetes baseline objects
- [`scripts/validate.py`](scripts/validate.py) — structural/security validation for the baseline manifest

## Validation

```bash
python projects/kubernetes-production-platform/scripts/validate.py \
  projects/kubernetes-production-platform/manifests/base/platform.json
```

The validator checks for a dedicated namespace, ResourceQuota, PodDisruptionBudget and default-deny NetworkPolicy.

## Example acceptance criteria

These are example engineering criteria, not service guarantees:

- Kubernetes API remains reachable after loss of one control-plane node.
- A replicated application remains available after loss of one worker node.
- Production namespace has explicit resource governance and network policy.
- Backup/restore procedure is tested rather than documented only.
- Platform metrics and audit data remain visible during controlled component failures.

## Design trade-offs

A small cluster minimizes cost but concentrates failure risk. More node pools increase isolation but also operational complexity. Service mesh, policy engines and advanced security agents should be introduced only when their control value justifies the lifecycle and troubleshooting overhead.
