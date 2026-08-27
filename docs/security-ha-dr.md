# Security, Availability and Disaster Recovery

## Security baseline

The reference architecture assumes a zero-trust-oriented control model: network location alone does not establish trust.

- Federate workforce identity and require MFA for privileged access.
- Separate human identities, workload identities and automation identities.
- Apply least privilege and short-lived credentials where supported.
- Segment management, shared services, production and non-production traffic.
- Restrict outbound traffic where practical and monitor DNS/egress paths.
- Encrypt sensitive data in transit and at rest according to classification.
- Store secrets in a managed secrets service rather than code or CI variables in plaintext.
- Centralize audit logs and protect the logging destination from workload administrators.
- Define patching, vulnerability management and exception handling as operational processes.

## Availability model

For production-class workloads, review every dependency for a single point of failure:

| Layer | Availability question |
|---|---|
| WAN edge | Are there independent devices/paths and failure-tested routing? |
| Connectivity | Can the service operate during loss of the primary circuit? |
| Cloud gateway | Is the selected gateway/service deployed across fault domains as intended? |
| DNS | Is name resolution resilient across both environments? |
| Identity | What happens if federation or the identity provider is unavailable? |
| Application | Is the application stateless, clustered or restart-dependent? |
| Data | What replication/consistency model protects the workload? |
| Observability | Can operators diagnose a partial outage if one telemetry path fails? |

## DR framework

Define recovery targets before choosing technology.

- **RTO:** maximum acceptable time to restore the business service.
- **RPO:** maximum acceptable amount of data loss measured in time.
- **Recovery sequence:** infrastructure, identity, data, middleware, application and integration dependencies.
- **Recovery authority:** who can declare a disaster and initiate failover?
- **Failback:** how will data and traffic safely return to the preferred site?

### Example tiers

| Tier | Example target | Typical pattern |
|---|---|---|
| Tier 0 | Very low RTO/RPO | Active/active or engineered synchronous patterns where justified |
| Tier 1 | Low RTO/RPO | Warm standby with automated or controlled failover |
| Tier 2 | Hours | Replicated backup / pilot-light style recovery |
| Tier 3 | Longer recovery | Backup and rebuild from IaC |

Targets above are illustrative only; actual values must come from business-impact analysis.

## Failure testing

A design is not considered resilient merely because the diagram contains redundant components. Test at least:

1. primary hybrid link loss;
2. single edge-device loss;
3. route withdrawal/incorrect advertisement safeguards;
4. DNS dependency failure;
5. cloud-zone or service-component failure where testable;
6. identity/federation interruption;
7. backup restore and DR recovery;
8. observability during partial failure.
