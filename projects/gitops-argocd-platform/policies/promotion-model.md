# Promotion and Rollback Model

## Environment promotion

Use immutable application versions and Git-reviewed configuration changes. Promotion should move a known version from development to higher environments rather than rebuilding an untracked artifact.

Reference flow:

```text
feature branch
   ↓
pull request + CI
   ↓
development sync
   ↓
functional / security validation
   ↓
version promotion PR
   ↓
production approval
   ↓
production sync
```

## Production controls

- production branch or path changes require review;
- synchronization windows may restrict deployment timing;
- high-risk changes can use manual sync even when development uses auto-sync;
- database/schema changes require forward/backward compatibility planning;
- rollback instructions are defined before deployment for critical services.

## Rollback

Rollback is not simply a Git revert when external state has changed. Validate:

1. application image/version compatibility;
2. database migration reversibility;
3. persistent-volume/data compatibility;
4. configuration and secret versioning;
5. API contract compatibility with dependent services;
6. traffic-management implications.

For stateless compatible changes, reverting the Git commit and synchronizing can restore a previous desired state. Stateful workloads need application-specific recovery procedures.
