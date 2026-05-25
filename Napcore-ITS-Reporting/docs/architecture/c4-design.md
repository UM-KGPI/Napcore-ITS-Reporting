# NAP ITS Reporter - C4 Architecture Design

This document provides the initial C4 architecture design for the web application based on the requirements.

## Pattern and Principles

Primary pattern: Federated Registry and Discoverability architecture for cross-NAP interoperability.

The central registry not only interlinks heterogeneous NAPs, but also provides searchable, explainable, and continuously updated discovery of NAP endpoints, datasets, and cross-NAP relationships.

## 1) C4 - System Context (Level 1)

For strict C4 notation (Structurizr DSL), see: `docs/architecture/c4-structurizr.dsl`.

```mermaid
flowchart LR
    classDef system fill:#0b3d91,stroke:#08295f,color:#fff
    classDef app fill:#0f766e,stroke:#0a4f4a,color:#fff
    classDef ext fill:#d97706,stroke:#92400e,color:#fff
    classDef user fill:#374151,stroke:#111827,color:#fff

    U[Member state / NAP operator]:::user

    APP["NAP ITS Reporter\n(Web Application)"]:::app
    PATTERN["Federated Registry and Discoverability architecture for cross-NAP interoperability"]:::system

    NAP[NAP catalog and API endpoints]:::ext
    INFRA[Infrastructure services\nregistry, storage, messaging]:::ext
    DGMOVE[DG MOVE templates and reporting requirements]:::ext
    STD[mobilityDCAT-AP and RDF standards\nJSON-LD, TTL, RDF/XML]:::ext

    U -->|review, validate, report| APP
    APP -.implements.-> PATTERN
    APP -->|interlink heterogeneous NAPs and discover endpoints, datasets, and relations| NAP
    APP -->|interoperable integrations| INFRA
    APP -->|apply reporting templates and KPI mappings| DGMOVE
    APP -->|apply validation rules and semantics| STD
```

## 2) C4 - Container Diagram (Level 2)

```mermaid
flowchart TB
    classDef app fill:#0f766e,stroke:#0a4f4a,color:#fff
    classDef svc fill:#2563eb,stroke:#1e3a8a,color:#fff
    classDef data fill:#7c3aed,stroke:#4c1d95,color:#fff
    classDef ext fill:#d97706,stroke:#92400e,color:#fff
    classDef user fill:#374151,stroke:#111827,color:#fff

    U[Member state / NAP operator]:::user

    subgraph PLATFORM["NAP ITS Reporter"]
        subgraph PRESENTATION["Presentation Layer"]
            UI[Web UI\nvalidation dashboard + workflow view]:::app
            APIDOC[API Documentation Portal\nOpenAPI/Swagger]:::app
        end

        subgraph LOGIC["Logical Layer (Microservices/API)"]
            BFF[API Gateway / BFF\nREST API + API contracts]:::svc
            ING[Metadata Ingestion Service\nautomated discovery + fetch + normalization]:::svc
            REGDISC[Federated Registry and Discoverability Service\nfor cross-NAP interoperability]:::svc
            PATTERN2["Federated Registry and Discoverability architecture for cross-NAP interoperability"]:::system
            VAL[Compliance Validation Service\ncompleteness + accuracy + consistency checks]:::svc
            KPI[KPI Mapping & Analytics Service\nmetadata -> KPI -> DG MOVE mappings]:::svc
            REP[Reporting Service\nguided + semi-auto + full-auto reporting]:::svc
            REC[Recommendation Service\nnon-compliance improvement suggestions]:::svc
            WF[Workflow Orchestrator\nend-to-end reporting workflow]:::svc
            IAM[AuthN/AuthZ Service\nRBAC/ABAC, auditing]:::svc
        end

        subgraph DATA["Data Layer"]
            MQ[(Event Bus / Queue)]:::data
            META[(Metadata Store\nRDF triplestore)]:::data
            APPDB[(Application DB\nusers, configuration, jobs)]:::data
            DOCS[(Document Store\nreports, exports, compliance outputs)]:::data
        end
    end

    NAP[NAP catalog and API endpoints]:::ext
    INFRA[Infrastructure services]:::ext
    DGMOVE[DG MOVE templates]:::ext

    U --> UI
    UI --> BFF
    U --> APIDOC
    APIDOC --> BFF
    BFF --> IAM
    BFF --> WF
    WF --> ING
    WF --> REGDISC
    WF --> VAL
    WF --> KPI
    WF --> REP
    WF --> REC

    ING --> REGDISC
    REGDISC -.implements.-> PATTERN2
    REGDISC --> NAP
    REGDISC --> INFRA
    ING --> META
    VAL --> META
    VAL --> APPDB
    VAL --> DOCS
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
    DataQuality[Completeness + Accuracy + Consistency\nChecks]:::svc
    NonComplianceReport[Non-compliance Report Generator]:::svc
    ReportBuilder[Recommendation Report Builder]:::svc

    META[(RDF Metadata Store)]:::data
    APPDB[(Application DB)]:::data
    STD[Standard packs\nversioned rules]:::ext

    API --> RuleRepo
    API --> ShapeEngine
    API --> SemanticChecks
    API --> DataQuality
    ShapeEngine --> META
    SemanticChecks --> META
    DataQuality --> META
    RuleRepo --> STD
    ShapeEngine --> NonComplianceReport
    SemanticChecks --> NonComplianceReport
    DataQuality --> NonComplianceReport
    NonComplianceReport --> ReportBuilder
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
    DgMoveMapper[DG MOVE Template Mapper]:::svc
    Guide[Guided Report Assistant]:::svc
    AutomationPlanner[Automation Planner\n(manual assist / semi / full)]:::svc
    Generator[Report Generator\n(partial/full auto)]:::svc
    Exporter[Exporter\nPDF/HTML/JSON]:::svc

    APPDB[(Application DB)]:::data
    DOCS[(Document Store)]:::data
    DGT[DG MOVE templates]:::ext

    RAPI --> Mapper
    RAPI --> DgMoveMapper
    RAPI --> Guide
    RAPI --> AutomationPlanner
    RAPI --> Generator
    Mapper --> DGT
    DgMoveMapper --> DGT
    Guide --> APPDB
    AutomationPlanner --> APPDB
    Generator --> APPDB
    Generator --> DOCS
    Generator --> Exporter
```

## 4) Requirement-to-C4 Coverage (Summary)

- Metadata collection: `Metadata Ingestion Service` and `Federated Registry & Discoverability Service` with automated discovery/fetch from NAP and support for JSON-LD, Turtle (.ttl), and RDF/XML (.rdf).
- Compliance verification: `Compliance Validation Service` with completeness, accuracy, and consistency checks, plus non-compliance report and recommendation generation.
- Reporting workflow: `Workflow Orchestrator`, `Guided Report Assistant`, KPI mappings, DG MOVE template mappings, and semi/full automation modes.
- Modular architecture and interoperability: microservices with explicit presentation, logical, and data layers; clear service-to-service data flows; federated registry and discoverability modules for NAP catalog and infrastructure services.
- System architecture and security: `API Gateway/BFF`, standardized data models and API contracts, `AuthN/AuthZ`, access control, and event-driven integration.
- UI requirements: `Web UI` with intuitive workflow control, compliance visualization, recommendation access, and transparent reporting workflow progress.

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

- Mermaid System Context source: `docs/architecture/mermaid/system-context.mmd`
- Mermaid System Context SVG: `docs/architecture/svg/system-context-mermaid.svg`
- PUML System Context: `docs/architecture/puml/system-context.puml`
- SVG System Context: `docs/architecture/svg/system-context.svg`
- PUML Container: `docs/architecture/puml/container.puml`
- SVG Container: `docs/architecture/svg/container.svg`
- PUML Validation Components: `docs/architecture/puml/validation-components.puml`
- SVG Validation Components: `docs/architecture/svg/validation-components.svg`
- PUML Reporting Components: `docs/architecture/puml/reporting-components.puml`
- SVG Reporting Components: `docs/architecture/svg/reporting-components.svg`
