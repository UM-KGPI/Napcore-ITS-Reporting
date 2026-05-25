# One-Page Architecture Brief

## Project

Razvoj pilotne aplikacije za avtomatizirano zbiranje in obdelavo metapodatkov mobilityDCAT-AP

## Objective

Vzpostaviti spletno aplikacijo, ki avtomatizira:

- odkrivanje in zajem metapodatkov iz NAP,
- preverjanje skladnosti z mobilityDCAT-AP in DG MOVE zahtevami,
- pripravo porocil z vodnim delovnim tokom in KPI preslikavami.

## Architecture at a glance

- Frontend: Web UI (SPA) za upravljanje tokov, pregled skladnosti in porocila.
- Edge/API: API Gateway/BFF kot enoten vstop za UI in zunanje odjemalce.
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
- Application DB (workflow, konfiguracija, audit)
- Document Store (porocila in izvozi)
- Integration: NAP API endpoints, DG MOVE predloge, zunanji IdP, event bus.

## Why this design

- Modularnost: mikroservisi omogocajo neodvisen razvoj in skaliranje.
- Interoperabilnost: standardni API contracts in RDF podpora (JSON-LD, TTL, RDF/XML).
- Skladnost: centralizirana pravila + verzionirani validacijski profili.
- Operativnost: guided workflow skrajsa cas porocanja in zmanjsa napake.
- Varnost: centralni AuthN/AuthZ, RBAC/ABAC in audit trail.

## Contract requirement coverage

- Specifikacija zahtev in arhitekture: C4 L1-L4 dokumenti in API osnutki.
- Implementacija prototipa: API-first pristop in jasna razmejitev storitev.
- Testiranje prototipa: zasnova podpira unit, integration, system in performance teste.
- Tehnicna dokumentacija: OpenAPI specifikacije + arhitekturni dokumenti za uvajanje.

## Delivery artifacts prepared

- C4 baseline: docs/architecture/c4-design.md
- C4 Level 4 validation: docs/architecture/c4-level4-validation.md
- C4 Level 4 reporting: docs/architecture/c4-level4-reporting.md
- OpenAPI BFF: docs/api/openapi-bff.yaml
- OpenAPI validation service: docs/api/openapi-validation.yaml
- OpenAPI reporting service: docs/api/openapi-reporting.yaml

## Suggested immediate next sprint

- Zakleni technology stack (frontend, backend, triplestore, queue).
- Implementiraj skeleton storitev + CI pipeline.
- Dodaj test harness za SHACL/SPARQL validacijo.
- Dodaj pilotni workflow za 1 porocevalski cikel (end-to-end).
