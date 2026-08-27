# GCP Network Foundation Governance Model

## Governance layers

### Resource hierarchy
Use folders and projects to separate platform, production, non-production and sandbox responsibilities. Project creation should be controlled by an accountable provisioning process.

### Shared VPC
Centralize network ownership in a host project while allowing application teams to operate service projects. Subnet attachment and IAM delegation should be explicit rather than broad.

### Identity and workload access
Prefer group-based workforce IAM and service accounts/workload identity for applications. Avoid unmanaged user keys and long-lived static credentials.

### Network controls
Define ownership for CIDRs, firewall policies, Cloud Router advertisements, DNS, Internet egress and hybrid connectivity. Document which team can change each routing boundary.

### Organization policy
Use organization policies to enforce platform guardrails where practical. Exceptions should have an owner, reason, review date and compensating control.

### Logging and security evidence
Centralize administrative, network and security evidence through controlled logging sinks and retention policies. Access to forensic data should be restricted.

### FinOps
Use project ownership, labels, budgets and lifecycle controls to reduce orphaned resources and make shared-platform costs visible.

## Example decision register

| Decision | Reference choice | Production question |
|---|---|---|
| Network model | Shared VPC | Which teams own host and service projects? |
| Hybrid connectivity | Cloud Router + VPN/Interconnect | What SLA and route scale are required? |
| IAM | Groups + workload identities | Are external identities or workforce pools required? |
| Public exposure | Explicit exceptions | Which workloads genuinely require public ingress? |
| Logging | Central sinks | What retention and residency constraints apply? |
| Cost | Project-level accountability | How are shared network costs allocated? |
