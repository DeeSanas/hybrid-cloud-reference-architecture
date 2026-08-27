# Architecture Decision Record Summary

This document captures the key reference decisions behind the hybrid-cloud design. These are starting positions, not universal rules; production projects should validate each decision against business, technical, regulatory and operational constraints.

## ADR-001 — Use a hub-and-spoke / transit network model

**Decision:** Centralize cross-network connectivity and inspection through a transit/hub layer instead of creating uncontrolled point-to-point peering.

**Why:** It improves route governance, segmentation, shared-service integration and operational visibility as environments grow.

**Trade-offs:** The hub becomes strategically important and must be designed for scale, availability and clear ownership. Poor route-table design can create unexpected transitive paths.

## ADR-002 — Keep cloud address space non-overlapping

**Decision:** Allocate cloud CIDRs from an enterprise IP plan and prevent overlap with data-center, branch, partner and acquisition networks.

**Why:** Overlap complicates routing, DNS, migration and security policy, and often leads to temporary NAT designs that become permanent technical debt.

## ADR-003 — Prefer dynamic route exchange

**Decision:** Use BGP or the supported dynamic routing mechanism for hybrid route exchange when the environment is large enough to justify it.

**Controls:** Apply explicit prefixes, filtering, maximum-prefix controls, summarization and documented route preference. Never treat dynamic routing as permission to advertise every internal prefix.

## ADR-004 — Separate production, non-production and shared services

**Decision:** Place major trust and lifecycle domains in separate accounts/subscriptions/projects and network segments.

**Why:** Reduces blast radius and makes policy, billing, access control and change management more explicit.

## ADR-005 — Centralize identity, telemetry and security evidence

**Decision:** Workloads may be distributed, but identity governance, audit logs and operational telemetry should be aggregated into controlled shared services.

**Minimum evidence:** authentication activity, privileged actions, configuration changes, network/security events, platform health and application-level telemetry where available.

## ADR-006 — Treat private connectivity as an availability decision, not a security shortcut

A dedicated circuit can improve predictability and throughput, but traffic still requires appropriate authentication, authorization, segmentation, inspection and encryption based on the threat model.

## ADR-007 — Infrastructure changes should be reproducible

Terraform or equivalent IaC should represent stable infrastructure components. CI should at minimum run formatting and validation checks. Production pipelines should add policy/security scanning, approvals, protected environments, remote state controls and change evidence.

## ADR-008 — Design recovery per workload

A single 'DR architecture' for all applications is usually inappropriate. Classify workloads by business impact, RTO, RPO, dependency chain, data-consistency requirements and recovery sequencing before selecting replication or standby patterns.
