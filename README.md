# Hybrid Cloud Reference Architecture

[![Architecture](https://img.shields.io/badge/Focus-Hybrid%20Cloud-blue)](#)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA?logo=terraform&logoColor=white)](#)
[![Status](https://img.shields.io/badge/Status-Reference%20Implementation-success)](#)

A vendor-neutral **enterprise hybrid-cloud reference architecture** showing how an existing data center or private cloud can integrate with public-cloud landing zones while preserving consistent networking, identity, security, observability, automation, resilience and governance.

> **Scope:** This repository is a reference architecture and implementation lab. It is not presented as a customer production deployment. CIDRs, sizing, routing, controls and service selections must be validated for the target environment.

## Architecture objectives

The design is intended to demonstrate solution-architecture decisions for organizations that need to:

- retain selected workloads on-premises while adopting public cloud;
- create predictable connectivity between data-center and cloud environments;
- separate production, non-production and shared-service trust zones;
- standardize identity, logging, monitoring and security controls;
- automate repeatable infrastructure provisioning with Terraform;
- design for component, link and site failure rather than a single happy path;
- support phased workload migration without forcing an immediate full-cloud move.

## Logical architecture

```mermaid
flowchart TB
    U[Enterprise Users / Applications] --> ID[Central Identity & Access]
    ID --> ONPREM
    ID --> CLOUD

    subgraph ONPREM[Enterprise Data Center / Private Cloud]
      APP1[VM / Bare-metal Workloads]
      K8S1[Kubernetes / Platform Services]
      STG[Enterprise Storage]
      EDGE1[Redundant WAN Edge]
      APP1 --- K8S1
      APP1 --- STG
      K8S1 --- STG
      APP1 --> EDGE1
      K8S1 --> EDGE1
    end

    subgraph TRANSIT[Hybrid Connectivity]
      VPN[IPsec VPN - baseline]
      DX[Private Circuit / Cloud Interconnect - optional]
      BGP[Dynamic Routing / BGP]
      FW[Segmentation & Inspection]
      VPN --- BGP
      DX --- BGP
      BGP --- FW
    end

    subgraph CLOUD[Public Cloud Landing Zone]
      HUB[Transit / Hub Network]
      PROD[Production Spoke / VPC]
      NONPROD[Non-Production Spoke / VPC]
      SHARED[Shared Services]
      SEC[Security & Logging]
      HUB --> PROD
      HUB --> NONPROD
      HUB --> SHARED
      HUB --> SEC
    end

    EDGE1 --> VPN
    EDGE1 --> DX
    FW --> HUB
    OBS[Central Observability / SIEM] --- ONPREM
    OBS --- CLOUD
    CICD[GitHub Actions / IaC Pipeline] --> CLOUD
```

The editable Mermaid source is maintained in [`diagrams/reference-architecture.mmd`](diagrams/reference-architecture.mmd).

## Design principles

| Area | Reference decision |
|---|---|
| Network | Hub-and-spoke/transit pattern with non-overlapping address space and explicit route ownership |
| Connectivity | Dual path where justified: encrypted Internet VPN plus private connectivity for critical/high-volume traffic |
| Routing | Dynamic routing preferred for scalable route exchange; filtering and summarization at trust boundaries |
| Identity | Central identity federation; least privilege; role-based access; privileged access separated from user access |
| Security | Defense in depth: segmentation, workload controls, centralized logs, encryption, secrets management and controlled egress |
| Availability | Avoid single WAN edge, firewall or cloud gateway dependencies for production-class workloads |
| Operations | Common telemetry model for metrics, logs, traces, events and audit data |
| Automation | Infrastructure changes through reviewed IaC rather than undocumented console-only changes |
| DR | Application RTO/RPO drives replication and recovery design; DR is not assumed to equal HA |

## Repository structure

```text
.
├── README.md
├── diagrams/
│   └── reference-architecture.mmd
├── docs/
│   ├── architecture-decisions.md
│   └── security-ha-dr.md
├── terraform/
│   ├── aws/
│   └── azure/
└── .github/workflows/
    └── validate.yml
```

## Implementation path

1. **Discover** existing network ranges, identity, applications, dependencies, security zones and recovery requirements.
2. **Establish the landing zone** with account/subscription separation, logging, IAM and network foundations.
3. **Build hybrid connectivity** and validate route propagation, MTU, DNS and failure behavior.
4. **Integrate shared services** such as identity, DNS, PKI, NTP, logging and security monitoring.
5. **Pilot a low-risk workload** and measure latency, availability, observability and operational processes.
6. **Scale by migration wave**, with explicit rollback and acceptance criteria.

## What to validate before production use

- IP-address overlap and route ownership
- asymmetric routing and stateful-firewall behavior
- DNS resolution across environments
- latency and bandwidth under realistic traffic profiles
- identity failure modes and break-glass access
- log retention, auditability and time synchronization
- encryption requirements in transit and at rest
- service quotas and regional dependencies
- RTO/RPO and actual recovery procedures
- infrastructure cost, data-transfer cost and operational ownership

## Related portfolio projects

- [OpenStack Private Cloud Reference Architecture](https://github.com/DeeSanas/openstack-private-cloud-reference-architecture)
- [Data Center EVPN-VXLAN Architecture](https://github.com/DeeSanas/datacenter-evpn-vxlan-architecture)
- [Terraform Enterprise Module Library](https://github.com/DeeSanas/terraform-enterprise-module-library)
- [VMware to OpenStack Migration Framework](https://github.com/DeeSanas/vmware-to-openstack-migration-framework)

## Roadmap

- [x] Reference architecture and design principles
- [x] Security / HA / DR decision framework
- [x] Starter AWS and Azure Terraform examples
- [x] CI validation workflow
- [ ] Add GCP landing-zone example
- [ ] Add automated policy/security checks
- [ ] Add failure-test scenarios and sample validation evidence

## License

Reference material and sample code are intended for learning, architecture demonstration and adaptation. Validate all configuration before use in a real environment.
