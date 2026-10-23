# Architecture Decision Records

Each record captures one decision: its context, the decision and its consequences. Records are immutable once accepted. To change a decision, add a new record that supersedes the old one, and update the old record's status.

| ADR | Decision | Status |
|---|---|---|
| [0001](0001-report-model-follows-implementing-decision-2025-264.md) | Report model follows Implementing Decision (EU) 2025/264, as a versioned template pack with value provenance | Proposed |
| [0002](0002-java-spring-boot-modular-monolith.md) | Java / Spring Boot modular monolith; C4 containers become modules | Proposed |
| [0003](0003-api-first-contract-first-openapi.md) | API-first: one contract-first public OpenAPI (`/api/v1`) replaces the BFF contract | Accepted |
| [0004](0004-thymeleaf-htmx-ui-through-public-api.md) | Thymeleaf + htmx UI that may only use the public API's delegates | Accepted |
| [0005](0005-itb-validator-container-and-adopter-rule-domains.md) | SHACL validation via the ITB mobilityDCAT-AP validator container; adopter rules as extra validator domains | Accepted |
| [0006](0006-docker-compose-behind-existing-nginx.md) | Docker Compose deployment behind the existing host nginx | Accepted |
| [0007](0007-eupl-1-2-licence.md) | EUPL-1.2 licence | Accepted (provisional) |

## Template

```markdown
# ADR-NNNN: <decision in one line>

- Status: Proposed | Accepted | Superseded by ADR-XXXX
- Date: YYYY-MM-DD

## Context
## Decision
## Consequences
```
