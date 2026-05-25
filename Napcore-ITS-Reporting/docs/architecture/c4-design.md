# NAP ITS Reporter - C4 Architecture Design

This document provides the initial C4 architecture design for the web application based on the contract requirements.

## 1) C4 - System Context (Level 1)

For strict C4 notation (Structurizr DSL), see: `docs/architecture/c4-structurizr.dsl`.

```mermaid
flowchart LR
    classDef system fill:#0b3d91,stroke:#08295f,color:#fff
    classDef app fill:#0f766e,stroke:#0a4f4a,color:#fff
    classDef ext fill:#d97706,stroke:#92400e,color:#fff
    classDef user fill:#374151,stroke:#111827,color:#fff

    U1[Pilot User\nNAP Analyst]:::user
    U2[Administrator]:::user

    APP["NAP ITS Reporter\n(Web Application)"]:::app

    NAP[NAP catalogs and API endpoints]:::ext
    DGMOVE[DG MOVE templates and reporting requirements]:::ext
    STD[mobilityDCAT-AP and RDF standards\nJSON-LD, TTL, RDF/XML]:::ext
    IDP[External IdP\nOIDC/SAML]:::ext

    U1 -->|review, validate, report| APP
    U2 -->|manage system, rules, and access| APP
    APP -->|discover and ingest metadata| NAP
    APP -->|apply reporting templates and KPI mappings| DGMOVE
    APP -->|apply validation rules and semantics| STD
    APP -->|authentication and authorization| IDP
```

## 2) C4 - Container Diagram (Level 2)

```mermaid
flowchart TB
    classDef app fill:#0f766e,stroke:#0a4f4a,color:#fff
    classDef svc fill:#2563eb,stroke:#1e3a8a,color:#fff
    classDef data fill:#7c3aed,stroke:#4c1d95,color:#fff
    classDef ext fill:#d97706,stroke:#92400e,color:#fff
    classDef user fill:#374151,stroke:#111827,color:#fff

    U[User]:::user

    subgraph PLATFORM[NAP ITS Reporter]
        UI[Web UI\nSPA + guided workflow]:::app
        BFF[API Gateway / BFF\nREST API + API contracts]:::svc

        ING[Metadata Ingestion Service\nNAP discovery, fetch, normalization]:::svc
        VAL[Compliance Validation Service\nrules + SHACL/SPARQL validation]:::svc
        KPI[KPI Mapping & Analytics Service\nmetadata mappings -> KPI -> DG MOVE]:::svc
        REP[Reporting Service\nsemi-automated/automated report generation]:::svc
        REC[Recommendation Service\nnon-compliance improvement suggestions]:::svc
        WF[Workflow Orchestrator\nreporting workflow orchestration]:::svc
        IAM[AuthN/AuthZ Service\nRBAC/ABAC, auditing]:::svc

        MQ[(Event Bus / Queue)]:::data
        META[(Metadata Store\nRDF triplestore)]:::data
        APPDB[(Application DB\nusers, configuration, jobs)]:::data
        DOCS[(Document Store\nreports, export files)]:::data
    end

    NAP[NAP API endpoints]:::ext
    DGMOVE[DG MOVE templates]:::ext
    IDP[External Identity Provider]:::ext

    U --> UI
    UI --> BFF
    BFF --> IAM
    BFF --> WF
    WF --> ING
    WF --> VAL
    WF --> KPI
    WF --> REP
    WF --> REC

    ING --> NAP
    ING --> META
    VAL --> META
    VAL --> APPDB
    KPI --> META
    KPI --> APPDB
    REP --> DGMOVE
    REP --> DOCS
    REP --> APPDB
    REC --> APPDB

    ING <--> MQ
    VAL <--> MQ
    KPI <--> MQ
    REP <--> MQ

    IAM --> IDP
    IAM --> APPDB
```

## 3) C4 - Component Diagram (Level 3)

### 3.1 Compliance Validation Service

```mermaid
flowchart LR
    classDef svc fill:#2563eb,stroke:#1e3a8a,color:#fff
    classDef data fill:#7c3aed,stroke:#4c1d95,color:#fff
    classDef ext fill:#d97706,stroke:#92400e,color:#fff

    API[Validation API\n(start/check/status)]:::svc
    RuleRepo[Rule Repository\nmobilityDCAT-AP + DG MOVE rules]:::svc
    ShapeEngine[SHACL Engine]:::svc
    SemanticChecks[SPARQL Semantic Checks]:::svc
    Completeness[Completeness & Consistency Checker]:::svc
    ReportBuilder[Non-compliance + recommendations\nReport Builder]:::svc

    META[(RDF Metadata Store)]:::data
    APPDB[(Application DB)]:::data
    STD[Standard packs\nversioned rules]:::ext

    API --> RuleRepo
    API --> ShapeEngine
    API --> SemanticChecks
    API --> Completeness
    ShapeEngine --> META
    SemanticChecks --> META
    Completeness --> META
    RuleRepo --> STD
    ShapeEngine --> ReportBuilder
    SemanticChecks --> ReportBuilder
    Completeness --> ReportBuilder
    ReportBuilder --> APPDB
```

### 3.2 Reporting Service

```mermaid
flowchart LR
    classDef svc fill:#2563eb,stroke:#1e3a8a,color:#fff
    classDef data fill:#7c3aed,stroke:#4c1d95,color:#fff
    classDef ext fill:#d97706,stroke:#92400e,color:#fff

    RAPI[Reporting API]:::svc
    Mapper[KPI/Template Mapper]:::svc
    Guide[Guided Report Assistant]:::svc
    Generator[Report Generator\n(partial/full auto)]:::svc
    Exporter[Exporter\nPDF/HTML/JSON]:::svc

    APPDB[(Application DB)]:::data
    DOCS[(Document Store)]:::data
    DGT[DG MOVE templates]:::ext

    RAPI --> Mapper
    RAPI --> Guide
    RAPI --> Generator
    Mapper --> DGT
    Guide --> APPDB
    Generator --> APPDB
    Generator --> DOCS
    Generator --> Exporter
```

## 4) Requirement-to-C4 Coverage (Summary)

- Metadata collection: `Metadata Ingestion Service`, `NAP adapters`, and RDF format support in API contracts.
- Compliance verification: `Compliance Validation Service`, `Rule Repository`, and `SHACL/SPARQL`.
- Reporting workflow: `Workflow Orchestrator`, `Reporting Service`, `Guided Report Assistant`, and `KPI Mapping`.
- Modular architecture: microservices plus separated data, logic, and presentation layers.
- System architecture: `API Gateway/BFF`, standardized API contracts, `AuthN/AuthZ`, and event-driven integration.
- UI requirements: `Web UI` with dashboard views for validation, non-compliance findings, recommendations, and reporting workflows.

## 5) Completed Next-Step Artifacts

- C4 Level 4 (Code) for Validation Service: `docs/architecture/c4-level4-validation.md`
- C4 Level 4 (Code) for Reporting Service: `docs/architecture/c4-level4-reporting.md`
- OpenAPI draft for BFF: `docs/api/openapi-bff.yaml`
- OpenAPI draft for Validation Service: `docs/api/openapi-validation.yaml`
- OpenAPI draft for Reporting Service: `docs/api/openapi-reporting.yaml`
- One-page architecture brief: `docs/brief/architecture-one-pager.md`
- Strict C4 notation (Structurizr DSL): `docs/architecture/c4-structurizr.dsl`
- Implementation API-first scaffold: `scaffold/README.md`

## 6) Proposed Next Step

- Define C4 Level 4 for remaining services (Ingestion, Workflow, IAM).
- Define the data model (RDF named graphs plus relational workflow state model).
- Prepare a testing strategy (unit/integration/system/performance) per module.

## 7) PUML and SVG Diagrams

- PUML System Context: `docs/architecture/puml/system-context.puml`
- SVG System Context: `docs/architecture/svg/system-context.svg`
- PUML Container: `docs/architecture/puml/container.puml`
- SVG Container: `docs/architecture/svg/container.svg`
- PUML Validation Components: `docs/architecture/puml/validation-components.puml`
- SVG Validation Components: `docs/architecture/svg/validation-components.svg`
- PUML Reporting Components: `docs/architecture/puml/reporting-components.puml`
- SVG Reporting Components: `docs/architecture/svg/reporting-components.svg`
