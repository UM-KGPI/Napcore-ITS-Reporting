# C4 Level 4 - Reporting Service

Ta dokument opisuje notranjo (code-level) zasnovo mikroservisa za pripravo porocil DG MOVE na podlagi zbranih in validiranih metapodatkov.

## Namen

- Upravljanje vodnega (guided) porocevalskega toka.
- Preslikava metapodatkovnih elementov v KPI in DG MOVE predloge.
- Delno ali v celoti avtomatizirana izdelava porocil.

## Modulni pogled

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

## Primarni runtime tok (sekvenca)

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

## Kljucne notranje komponente

- ReportingController: API za zagon porocila, pregled statusa, prevzem exportov.
- GuidedWorkflowEngine: vodi uporabnika po korakih in preverja obvezna polja.
- KpiMappingEngine: mapira mobilityDCAT-AP elemente v KPI in predloge.
- TemplateProvider: upravlja verzije predlog DG MOVE.
- ReportGenerator: sestavi porocilo (narrative + tabele + kazalniki).
- ReportQualityGate: kontrola popolnosti, skladnosti in konsistentnosti outputa.
- ExportManager: izvoz v PDF/HTML/JSON.

## Predlagane kode pogodbe (notranje)

- Command: StartReportGenerationCommand
- Query: GetReportStatusQuery
- Event: ReportGenerated, ReportPublished
- DTO: ReportSummaryDto, KpiSnapshotDto

## Nefunkcionalne zahteve

- Podpora za delni in polni avtomatski nacin (manual assist / auto).
- Verzije porocil in ponovljivost generiranja.
- Audit trail sprememb po korakih workflow.
- Cilj odziva API za oddajo porocila: < 300 ms (p95).
