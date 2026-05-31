# One-Page Architecture Brief

## Project

NAP ITS Reporter - Pilot application for automated mobilityDCAT-AP metadata collection and processing

## Objective

Establish a web application that automates:

- metadata discovery and ingestion from NAP,
- compliance checking against mobilityDCAT-AP and DG MOVE requirements,
- report preparation through a guided workflow and KPI mappings.

## Architecture at a glance

- Frontend: Web UI (SPA) for workflow management, compliance views, and reports.
- Edge/API: API Gateway (frontend-oriented API composition layer) as a single entry point for UI and external clients.
- Core services:
- Metadata Ingestion Service
- Compliance Validation Service
- KPI Mapping and Analytics Service
- Reporting Service
- Recommendation Service
- Workflow Orchestrator
- AuthN/AuthZ Service
- Data layer:
- RDF Metadata Store (triplestore)
- Application DB (workflow, configuration, audit)
- Document Store (reports and exports)
- Integration: NAP API endpoints, DG MOVE templates, external IdP, event bus.

## Why this design

- Modularity: microservices enable independent development and scaling.
- Interoperability: standardized API contracts and RDF support (JSON-LD, TTL, RDF/XML).
- Compliance: centralized rules and versioned validation profiles.
- Operational efficiency: guided workflow reduces reporting time and errors.
- Security: centralized AuthN/AuthZ, RBAC/ABAC, and audit trail.

## Contract requirement coverage

- Requirements and architecture specification: C4 L1-L4 documents and API drafts.
- Prototype implementation: API-first approach and clear service boundaries.
- Prototype testing: design supports unit, integration, system, and performance testing.
- Technical documentation: OpenAPI specifications and architecture documents for rollout.

## Delivery artifacts prepared

- C4 baseline: docs/architecture/c4-design.md
- C4 Level 4 validation: docs/architecture/c4-level4-validation.md
- C4 Level 4 reporting: docs/architecture/c4-level4-reporting.md
- OpenAPI BFF: docs/api/openapi-bff.yaml
- OpenAPI validation service: docs/api/openapi-validation.yaml
- OpenAPI reporting service: docs/api/openapi-reporting.yaml

## Suggested immediate next sprint

- Finalize technology stack (frontend, backend, triplestore, queue).
- Implement service skeletons and CI pipeline.
- Add a test harness for SHACL/SPARQL validation.
- Add a pilot workflow for one end-to-end reporting cycle.
