# Azure Landing Zone Governance Model

## Governance layers

### Management hierarchy
Use management groups to create policy and ownership boundaries. Avoid placing all subscriptions directly under the tenant root without a structure for platform, workload and sandbox responsibilities.

### Identity and privileged administration
Use Entra ID groups and role assignments rather than direct individual permissions where possible. Privileged access should be time-bound, strongly authenticated and monitored.

### Subscription model
Separate connectivity, management and identity platform responsibilities from application workloads. Production and non-production subscriptions should have independent operational boundaries where risk warrants it.

### Policy and compliance
Use Azure Policy for measurable guardrails, but design exemptions as governed exceptions with owners, expiry dates and compensating controls.

### Network governance
Define authoritative CIDR ownership, peering rules, UDRs, firewall/NVA routing, private DNS, hybrid connectivity and public-endpoint policy.

### Monitoring and security
Centralize subscription activity and selected resource/security telemetry. Define retention, workspace ownership and access to security evidence.

### Cost governance
Use consistent tags, budgets and management-group/subscription ownership to support showback/chargeback and lifecycle cleanup.

## Example decision register

| Decision | Reference choice | Production question |
|---|---|---|
| Hierarchy | Platform / Landing Zones / Sandbox | Does the hierarchy match policy inheritance requirements? |
| Network | Central hub-and-spoke | Is Virtual WAN more appropriate at expected scale? |
| Identity | Entra federation + RBAC | Which roles require PIM and approval? |
| Policy | Central baseline with scoped exceptions | Who owns exemption approval and expiry? |
| Monitoring | Central management subscription | What telemetry must stay region-local? |
| Backup | Workload-tier policies | Which applications require isolated recovery vaults? |
