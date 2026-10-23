# ADR-0003: API-first with one contract-first public OpenAPI

- Status: Accepted
- Date: 2026-10-23

## Context

The solution must be API-based so that other Member States and NAPs can adapt it. There are three drafts: [openapi-bff.yaml](../../api/openapi-bff.yaml), [openapi-validation.yaml](../../api/openapi-validation.yaml) and [openapi-reporting.yaml](../../api/openapi-reporting.yaml). A backend-for-frontend contract is, by design, shaped around one UI, which makes it the wrong contract to publish to adopters. The per-service contracts follow internal service boundaries, which ADR-0002 merges into one deployable.

## Decision

- **One public API**, versioned as `/api/v1`, organised by domain: harvests, registry and datasets, dataset health, validations, reports (sections, table values, KPIs), network references, workflow.
- **Contract-first:** the OpenAPI 3.1 document is the source of truth. Server interfaces are generated from it (openapi-generator, `spring` generator, delegate pattern), and so are clients for tests.
- **Conventions:**
  - errors as `application/problem+json` (RFC 9457);
  - long-running work as asynchronous jobs (`202` and a job resource);
  - cursor pagination;
  - an `Idempotency-Key` header on POST;
  - OIDC bearer tokens;
  - JSON-LD as an alternative representation for registry and dataset resources.
- **Report resources use the template pack's stable IDs**, e.g. `/api/v1/reports/{reportId}/sections/2.1.3`, `/api/v1/reports/{reportId}/tables/2.5.1/rows/tunnels-core`, `/api/v1/reports/{reportId}/kpis/deploy-rtti`.
- **Quality gates in CI:** OpenAPI linting (Spectral) and a breaking-change check against the last released contract.

## Consequences

- The BFF, validation and reporting drafts are replaced by the single public contract. The API Gateway container becomes the edge (nginx, ADR-0006) plus the API module, not a composition layer.
- `/api/v1` changes are governed: additive changes within v1, breaking changes only in a new major version.
- The API documentation portal is generated from the same contract.
