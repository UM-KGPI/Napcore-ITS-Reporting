# C4 Level 4 - Reporting Service

This document describes the internal (code-level) design of the microservice for DG MOVE report preparation based on collected and validated metadata.

## Purpose

- Manages a guided reporting workflow.
- Maps metadata elements to KPI and DG MOVE templates.
- Supports partially or fully automated report generation.

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
    TPL[TemplateProvider]:::mod
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
    ORCH --> TPL
    ORCH --> GEN
    ORCH --> QA
    ORCH --> EXP
    ORCH --> PUB

    GUIDE --> APPDB
    MAP --> APPDB
    TPL --> DGMOVE
    GEN --> DOCS
    QA --> APPDB
    EXP --> DOCS
    PUB --> BUS
```

## Primary Runtime Flow (Sequence)

```mermaid
sequenceDiagram
    participant UI as BFF/UI
    participant API as ReportingController
    participant ORCH as ReportingOrchestrator
    participant MAP as KpiMappingEngine
    participant GEN as ReportGenerator
    participant QA as ReportQualityGate
    participant DOCS as DocumentStore

    UI->>API: POST /reports (period, scope, mode)
    API->>ORCH: startReportGeneration(cmd)
    ORCH->>MAP: resolve KPI mappings
    MAP-->>ORCH: mapped indicators
    ORCH->>GEN: generate draft report
    GEN-->>ORCH: draft artifact
    ORCH->>QA: validate report quality/completeness
    QA-->>ORCH: pass + warnings
    ORCH->>DOCS: save final report versions
    ORCH-->>API: reportId
    API-->>UI: 202 Accepted
```

## Key Internal Components

- ReportingController: API for starting report generation, checking status, and downloading exports.
- GuidedWorkflowEngine: guides users through steps and validates required inputs.
- KpiMappingEngine: maps mobilityDCAT-AP elements to KPI and templates.
- TemplateProvider: manages DG MOVE template versions.
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
