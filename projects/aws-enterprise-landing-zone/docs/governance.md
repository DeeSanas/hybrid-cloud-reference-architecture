# AWS Landing Zone Governance Model

## Governance layers

### Organization and account boundaries
Use account separation to create blast-radius and ownership boundaries. Security/logging accounts should not be used as general workload accounts. Production and non-production should not depend on administrator access to a shared account.

### Identity and privileged access
Prefer federation and short-lived role sessions. Privileged roles should be separate from normal user access, protected by MFA and logged. Emergency access must be documented, monitored and tested.

### Preventive controls
Service Control Policies can restrict high-risk actions or unsupported regions, but they must be designed with an exception process and tested against legitimate operational workflows.

### Detective controls
Centralize CloudTrail, configuration-change evidence, security findings and workload logs. Retention and immutability should be matched to compliance and forensic requirements.

### Network governance
Define ownership for CIDRs, Transit Gateway route tables, DNS, egress, inspection, hybrid routing and public endpoints. Route propagation should be explicit at trust boundaries.

### Data and encryption
Define who owns KMS keys, rotation policy, cross-account use, backup retention and data-classification controls. Encryption alone does not replace access governance.

### FinOps
Apply mandatory tags, budgets, cost-allocation ownership and lifecycle controls. Track data-transfer and NAT/egress cost as architecture concerns rather than only billing concerns.

## Example decision register

| Decision | Reference choice | Production question |
|---|---|---|
| Account structure | Security / infrastructure / workload OUs | How does this align with business ownership? |
| Regions | Explicitly approved regions | What are residency and latency requirements? |
| Identity | Federated roles | Which IdP and approval workflow apply? |
| Network | Central transit | Is distributed egress required for any workload? |
| Logging | Central protected archive | What retention and legal-hold requirements apply? |
| Backup | Policy by workload tier | What RPO/RTO is contractually required? |
