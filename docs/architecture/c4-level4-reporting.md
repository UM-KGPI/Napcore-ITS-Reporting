# C4 Level 4 - Reporting Service

This document describes the internal (code-level) design of the microservice for DG MOVE report preparation based on collected and validated metadata.

## Purpose

- Manages a guided reporting workflow.
- Maps metadata (mobilityDCAT-AP) elements to KPI and DG MOVE templates.
- Supports partially or fully automated report generation.
- Provides documentation-ready report outputs and exports.

## Module View

```mermaid
flowchart TB
    classDef mod fill:#2563eb,stroke:#1e3a8a,color:#fff
    classDef data fill:#7c3aed,stroke:#4c1d95,color:#fff
    classDef ext fill:#d97706,stroke:#92400e,color:#fff

    API[ReportingController]:::mod
    AUTH[AuthorizationGuard]:::mod
    ORCH[ReportingOrchestrator]:::mod
    GUIDE[GuidedWorkflowEngine]:::mod
    MAP[KpiMappingEngine]:::mod
    DGMAP[DgMoveTemplateMapper]:::mod
    TPL[TemplateProvider]:::mod
    AUTO[AutomationModePlanner]:::mod
    GEN[ReportGenerator]:::mod
    QA[ReportQualityGate]:::mod
    EXP[ExportManager]:::mod
    PUB[EventPublisher]:::mod

    APPDB[(Application DB)]:::data
    DOCS[(Document Store)]:::data
    DGMOVE[DG MOVE Template Source]:::ext
    BUS[Event Bus]:::ext

    API --> AUTH
    AUTH --> ORCH
    ORCH --> GUIDE
    ORCH --> MAP
    ORCH --> DGMAP
    ORCH --> TPL
    ORCH --> AUTO
    ORCH --> GEN
    ORCH --> QA
    ORCH --> EXP
    ORCH --> PUB

    GUIDE --> APPDB
    MAP --> APPDB
    DGMAP --> DGMOVE
    TPL --> DGMOVE
    AUTO --> APPDB
    GEN --> DOCS
    QA --> APPDB
    EXP --> DOCS
    PUB --> BUS
```

## Primary Runtime Flow (Sequence)

- Mermaid source: `docs/architecture/mermaid/reporting-primary-runtime-flow.mmd`
- SVG export: `docs/architecture/svg/reporting-primary-runtime-flow-mermaid.svg`

```mermaid
sequenceDiagram
    participant UI as Web UI
    participant FAPI as Frontend API Layer
    participant API as ReportingController
    participant ORCH as ReportingOrchestrator
    participant MAP as KpiMappingEngine
    participant DGMAP as DgMoveTemplateMapper
    participant AUTO as AutomationModePlanner
    participant GEN as ReportGenerator
    participant QA as ReportQualityGate
    participant DOCS as DocumentStore

    UI->>FAPI: Start report generation
    FAPI->>API: POST /reports (period, scope, mode)
    API->>ORCH: startReportGeneration(cmd)
    ORCH->>MAP: resolve KPI mappings
    ORCH->>DGMAP: resolve DG MOVE template mapping
    ORCH->>AUTO: select mode (guided/semi/auto)
    MAP-->>ORCH: mapped indicators
    DGMAP-->>ORCH: mapped template fields
    ORCH->>GEN: generate draft report
    GEN-->>ORCH: draft artifact
    ORCH->>QA: validate report quality/completeness
    QA-->>ORCH: pass + warnings
    ORCH->>DOCS: save final report versions
    ORCH-->>API: reportId
    API-->>FAPI: 202 Accepted (reportId)
    FAPI-->>UI: 202 Accepted (reportId)
```

## Key Internal Components

- ReportingController: API for starting report generation, checking status, and downloading exports.
- GuidedWorkflowEngine: guides users through steps and validates required inputs.
- KpiMappingEngine: maps mobilityDCAT-AP elements to KPI and templates.
- DgMoveTemplateMapper: maps KPI outputs into DG MOVE template fields.
- TemplateProvider: manages DG MOVE template versions.
- AutomationModePlanner: applies guided, semi-automatic, or full-automatic generation mode.
- ReportGenerator: composes report outputs (narrative + tables + indicators).
- ReportQualityGate: validates completeness, compliance, and output consistency.
- ExportManager: exports outputs to PDF/HTML/JSON.

## Proposed Internal Code Contracts

- Command: StartReportGenerationCommand
- Query: GetReportStatusQuery
- Event: ReportGenerated, ReportPublished
- DTO: ReportSummaryDto, KpiSnapshotDto

## Non-Functional Requirements

- Support for partial and full automatic modes (manual assist / auto).
- Report versioning and reproducible generation.
- Audit trail of changes per workflow step.
- API response target for report submission: < 300 ms (p95).
