# C4 Level 4 - Reporting Service

This document describes the internal (code-level) design of the microservice for DG MOVE report preparation based on collected and validated metadata.

## Purpose

- Guides the Member State through the Annex I template of Implementing Decision (EU) 2025/264, section by section.
- Collects narrative answers, and shows metadata-derived evidence and suggested values next to them. A person confirms every reported value; full-auto generation is not a goal (ADR-0001).
- Checks completeness against the Annex II obligations and manages the report lifecycle: draft, in-review, approved, exported.
- Renders the report in the Annex I structure and exports it as DOCX, PDF and JSON.

## Module View

Components of the Reporting module, and the other modules and stores it uses. Aligned with ADR-0001, ADR-0002 and ADR-0003; ownership follows [report-data-model.md, section 6](../domain/report-data-model.md#6-ownership-by-c4-container).

- PlantUML source: `docs/architecture/puml/reporting-components.puml`
- SVG export: `docs/architecture/svg/reporting-components.svg`

```mermaid
flowchart TB
    classDef mod fill:#2563eb,stroke:#1e3a8a,color:#fff
    classDef other fill:#6b7280,stroke:#374151,color:#fff
    classDef data fill:#7c3aed,stroke:#4c1d95,color:#fff
    classDef ext fill:#d97706,stroke:#92400e,color:#fff

    API["Reporting API (/api/v1/reports/...)"]:::mod

    subgraph REP[Reporting module]
        ORCH[ReportingOrchestrator]:::mod
        GUIDE[StepByStepGuidance]:::mod
        ANS[AnswerManager]:::mod
        EVID[EvidenceAndSuggestionCollector]:::mod
        QA[ReportQualityGate]:::mod
        LIFE[ReportLifecycleManager]:::mod
        GEN[ReportGenerator]:::mod
        EXP[ExportManager]:::mod
        OBL[ObligationResolver]:::mod
        TPL[TemplateProvider]:::mod
    end

    subgraph OTHER[Other modules]
        WF[Workflow]:::other
        COMP[Complementary Data]:::other
        KPI[KPI Mapping and Analytics]:::other
        VAL[Validation]:::other
    end

    APPDB[(Report Database)]:::data
    ARCH[(Report Archive)]:::data
    META[(Metadata Store - harvest snapshots)]:::data
    PACK[Template pack eu-2025-264]:::ext
    LAW["Official Template - Implementing Decision (EU) 2025/264"]:::ext

    API --> ORCH
    ORCH --> GUIDE & ANS & EVID & QA & LIFE & GEN & EXP

    GUIDE --> TPL
    GUIDE -->|required markers| OBL
    GUIDE -->|step state| WF
    OBL -->|obligationTiers| TPL
    TPL -->|reads| PACK
    PACK -.->|transcribed verbatim from| LAW
    ANS --> APPDB
    EVID -->|evidence, suggestions| KPI
    EVID -->|validation results| VAL
    QA --> OBL
    QA -->|table / KPI values| COMP
    QA -->|quality results| APPDB
    LIFE -->|status, audit| APPDB
    LIFE -->|freeze snapshots at approval| META
    GEN --> TPL
    GEN -->|table / KPI values| COMP
    GEN -->|drafts, final versions| ARCH
    EXP -->|exports| ARCH
```

Removed from the earlier design:

- **Automation Mode Planner**: full-auto generation is dropped (ADR-0001). Automation is recorded per value as provenance (`metadata-suggested`, `computed`, ...), not as a report-wide mode.
- **KPI Mapping Engine**: KPI computation and the metadata mapping are owned by the KPI Mapping and Analytics module.
- **DG MOVE Template Mapper**: report resources use the template pack's stable section, row and KPI IDs directly, so no separate mapping step is needed.
- **Event Publisher**: there is no event bus (ADR-0002).

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

- ReportingController (Reporting API): report resources under `/api/v1/reports`, using the template pack IDs (ADR-0003).
- ReportingOrchestrator: coordinates the components for one report.
- TemplateProvider: loads the versioned template pack; a report keeps the pack version it was created with.
- ObligationResolver: evaluates `obligation(kpi, scope, cycleYear)` from the pack's Annex II data.
- StepByStepGuidance: section and prompt sequence, guidance text and required-field markers; step state is held by the Workflow module.
- AnswerManager: narrative answers with their provenance.
- EvidenceAndSuggestionCollector: metadata facts and suggested values from the KPI Mapping and Analytics module, plus validation results.
- ReportQualityGate: completeness against Annex II obligations, and consistency checks.
- ReportLifecycleManager: draft, in-review, approved, exported; audit trail, revisions, and freezing the harvest snapshots the report cites.
- ReportGenerator: renders the report in the Annex I structure.
- ExportManager: exports DOCX, PDF and JSON to the Report Archive.

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
