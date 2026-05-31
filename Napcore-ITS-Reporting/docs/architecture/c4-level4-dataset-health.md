# C4 Level 4 - NAP Dataset Health Status Service

This document describes the internal (code-level) design of the microservice responsible for trusted dataset readiness evaluation.

## Purpose

- Accepts a dataset health query for a specific `datasetId`.
- Resolves the dataset record from mobilityDCAT-AP metadata.
- Extracts the distribution or service endpoint for the dataset.
- Probes the target dataset service for availability and freshness.
- Persists a trustable dataset health status with supporting evidence.

## Dataset Health Semantics

The service evaluates health per `datasetId`.

- `ready`: dataset metadata resolves successfully, a usable access or distribution URL exists, the target service probe succeeds, and the result is still fresh enough to trust.
- `degraded`: dataset resolves, but probe quality is below policy threshold, for example intermittent failures or slow responses.
- `unavailable`: dataset resolves, but the referenced service is currently unreachable or returning failing status codes.
- `unknown`: metadata is missing, incomplete, or no trusted probe result is available yet.

## Why the Trust Evaluator and Cache Exist

The service does not treat probe results as the final answer. A raw endpoint check can succeed or fail for reasons that are too noisy to expose directly to API consumers, so `HealthTrustEvaluator` turns metadata, probe evidence, and freshness rules into a stable public status.

- `HealthTrustEvaluator` decides whether the current evidence is strong enough to publish as `ready`, `degraded`, `unavailable`, or `unknown`.
- `HealthStatusCache` stores the last trusted decision plus evidence so repeated reads can return quickly without probing every time.
- Together, they separate the expensive operation of checking a live dataset endpoint from the cheap operation of serving the latest trusted answer.
- This keeps the service fast, reduces load on NAP endpoints, and preserves the evidence needed to explain the published status.

## At a Glance

- `AvailabilityProbe` answers: “can I reach the dataset service right now?”
- `HealthTrustEvaluator` answers: “is this result trustworthy enough to publish as the current health status?”
- `HealthStatusCache` stores the evaluator’s last trusted decision so reads stay fast

## Trust and Cache Sketch

```mermaid
sequenceDiagram
    participant UI as Web UI
    participant API as DatasetHealthController
    participant ORCH as DatasetHealthOrchestrator
    participant CACHE as HealthStatusCache
    participant RES as DatasetMetadataResolver
    participant URL as DistributionEndpointExtractor
    participant PROBE as AvailabilityProbe
    participant TRUST as HealthTrustEvaluator
    participant DB as AppDB
    participant NAP as NAP dataset service

    UI->>API: GET /dataset-health/{datasetId}
    API->>ORCH: getDatasetHealth(datasetId, refresh?)
    ORCH->>CACHE: readLatestHealth(datasetId)
    CACHE-->>ORCH: cached status + evidence
    alt cache hit and fresh enough
        ORCH-->>API: cached readinessStatus
    else refresh requested or cache stale
        ORCH->>RES: resolveDataset(datasetId)
        RES-->>ORCH: mobilityDCAT-AP dataset record
        ORCH->>URL: extractEndpoint(dataset record)
        URL-->>ORCH: accessUrl, downloadUrl
        ORCH->>PROBE: probe(endpoint)
        PROBE->>NAP: HEAD/GET dataset endpoint
        NAP-->>PROBE: HTTP status + latency
        PROBE-->>ORCH: probe result
        ORCH->>TRUST: evaluate(metadata, probe, freshness)
        TRUST-->>ORCH: readinessStatus + trustLevel
        ORCH->>CACHE: persist latest health evidence
        ORCH->>DB: persist audit trail and evidence
        ORCH-->>API: dataset health status
    end
    API-->>UI: readinessStatus, checkedAt, evidence
```

## Module View

- Mermaid source: `docs/architecture/mermaid/dataset-health-module-view.mmd`
- SVG export: `docs/architecture/svg/dataset-health-module-view.svg`

```mermaid
flowchart TB
    classDef mod fill:#2563eb,stroke:#1e3a8a,color:#fff
    classDef data fill:#7c3aed,stroke:#4c1d95,color:#fff
    classDef ext fill:#d97706,stroke:#92400e,color:#fff

    API[DatasetHealthController]:::mod
    AUTH[AuthorizationGuard]:::mod
    ORCH[DatasetHealthOrchestrator]:::mod
    RES[DatasetMetadataResolver]:::mod
    URL[DistributionEndpointExtractor]:::mod
    PROBE[AvailabilityProbe]:::mod
    TRUST[HealthTrustEvaluator]:::mod
    CACHE[HealthStatusCache]:::mod
    PUB[EventPublisher]:::mod

    META[(RDF Metadata Store)]:::data
    APPDB[(Application DB)]:::data
    NAP[NAP dataset delivery service]:::ext
    BUS[Event Bus]:::ext

    API --> AUTH
    AUTH --> ORCH
    ORCH --> RES
    ORCH --> URL
    ORCH --> PROBE
    ORCH --> TRUST
    ORCH --> CACHE
    ORCH --> PUB

    RES --> META
    URL --> META
    PROBE --> NAP
    TRUST --> APPDB
    CACHE --> APPDB
    PUB --> BUS
```

## Primary Runtime Flow (Sequence)

- Mermaid source: `docs/architecture/mermaid/dataset-health-primary-runtime-flow.mmd`
- SVG export: `docs/architecture/svg/dataset-health-primary-runtime-flow.svg`

```mermaid
sequenceDiagram
    participant UI as Web UI
    participant FAPI as Frontend API Layer
    participant API as DatasetHealthController
    participant ORCH as DatasetHealthOrchestrator
    participant CACHE as HealthStatusCache
    participant RES as DatasetMetadataResolver
    participant URL as DistributionEndpointExtractor
    participant PROBE as AvailabilityProbe
    participant TRUST as HealthTrustEvaluator
    participant DB as AppDB
    participant NAP as NAP dataset service

    UI->>FAPI: View dataset health(datasetId)
    FAPI->>API: GET /dataset-health/{datasetId}
    API->>ORCH: getDatasetHealth(datasetId, refresh?)
    ORCH->>CACHE: readLatestHealth(datasetId)
    CACHE-->>ORCH: cached status + evidence
    alt cache hit and fresh enough
        ORCH-->>API: cached readinessStatus
    else refresh requested or cache stale
        ORCH->>RES: resolveDataset(datasetId)
        RES-->>ORCH: mobilityDCAT-AP dataset record
        ORCH->>URL: extractEndpoint(dataset record)
        URL-->>ORCH: accessUrl, downloadUrl
        ORCH->>PROBE: probe(endpoint)
        PROBE->>NAP: HEAD/GET dataset endpoint
        NAP-->>PROBE: HTTP status + latency
        PROBE-->>ORCH: probe result
        ORCH->>TRUST: evaluate(metadata, probe, freshness)
        TRUST-->>ORCH: readinessStatus + trustLevel
        ORCH->>CACHE: persist latest health evidence
        ORCH->>DB: persist audit trail and evidence
        ORCH-->>API: dataset health status
    end
    API-->>FAPI: 200 OK
    FAPI-->>UI: readinessStatus, checkedAt, evidence
```

## Key Internal Components

- DatasetHealthController: REST entry point for dataset health lookup and refresh.
- DatasetHealthOrchestrator: coordinates metadata resolution, probing, trust evaluation, and response composition.
- DatasetMetadataResolver: resolves `datasetId` to the authoritative mobilityDCAT-AP dataset graph.
- DistributionEndpointExtractor: extracts probeable URLs from distributions and data services.
- AvailabilityProbe: performs HTTP or service-level checks and records latency and status.
- HealthTrustEvaluator: applies readiness and freshness policy to determine whether the result is trusted and publishable.
- HealthStatusCache: stores the latest trusted health snapshot, its evidence, and the timestamp used to decide whether a refresh is needed.

## Proposed Internal Code Contracts

- Query: GetDatasetHealthQuery
- Command: RefreshDatasetHealthCommand
- Event: DatasetHealthEvaluated, DatasetHealthChanged
- DTO: DatasetHealthStatusDto, HealthEvidenceDto

## Non-Functional Requirements

- Dataset health lookup should return cached status in < 300 ms (p95) when no refresh is requested.
- Fresh probes should be policy-driven and bounded by configurable timeout budgets.
- Health evaluation must be deterministic for the same metadata snapshot and probe evidence.
- All health decisions must keep audit evidence for traceability and trust review.
