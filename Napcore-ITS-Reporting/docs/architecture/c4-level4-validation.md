# C4 Level 4 - Compliance Validation Service

Ta dokument opisuje notranjo (code-level) zasnovo mikroservisa za avtomatsko preverjanje skladnosti mobilityDCAT-AP metapodatkov.

## Namen

- Sprejme validacijsko opravilo za en ali vec metapodatkovnih zapisov.
- Izvede sintakticne, semanticne in poslovne kontrole.
- Shrani rezultat validacije in izpostavi porocilo za UI ter porocevalski tok.

## Modulni pogled

```mermaid
flowchart TB
    classDef mod fill:#2563eb,stroke:#1e3a8a,color:#fff
    classDef data fill:#7c3aed,stroke:#4c1d95,color:#fff
    classDef ext fill:#d97706,stroke:#92400e,color:#fff

    API[ValidationController]:::mod
    AUTH[AuthorizationGuard]:::mod
    ORCH[ValidationOrchestrator]:::mod
    RULES[RuleSetProvider]:::mod
    PARSER[RDFParserAdapter]:::mod
    SHACL[ShaclValidationEngine]:::mod
    SPARQL[SparqlRuleEngine]:::mod
    QCHECK[QualityChecksEngine]:::mod
    AGG[ResultAggregator]:::mod
    RECO[RecommendationBuilder]:::mod
    PUB[EventPublisher]:::mod

    META[(RDF Store)]:::data
    APPDB[(Application DB)]:::data
    PACKS[Versioned Rule Packs]:::ext
    BUS[Event Bus]:::ext

    API --> AUTH
    AUTH --> ORCH
    ORCH --> RULES
    ORCH --> PARSER
    ORCH --> SHACL
    ORCH --> SPARQL
    ORCH --> QCHECK
    SHACL --> AGG
    SPARQL --> AGG
    QCHECK --> AGG
    AGG --> RECO
    RECO --> APPDB
    AGG --> APPDB
    ORCH --> PUB

    RULES --> PACKS
    PARSER --> META
    SHACL --> META
    SPARQL --> META
    QCHECK --> META
    PUB --> BUS
```

## Primarni runtime tok (sekvenca)

```mermaid
sequenceDiagram
    participant UI as BFF/UI
    participant API as ValidationController
    participant ORCH as ValidationOrchestrator
    participant RULES as RuleSetProvider
    participant ENGINES as SHACL+SPARQL+Quality
    participant DB as AppDB
    participant BUS as EventBus

    UI->>API: POST /validations (datasetRef, profileVersion)
    API->>ORCH: startValidation(job)
    ORCH->>RULES: loadRules(profileVersion)
    RULES-->>ORCH: compiled rules
    ORCH->>ENGINES: run(rules, datasetRef)
    ENGINES-->>ORCH: findings
    ORCH->>DB: persist findings + score + status
    ORCH->>BUS: publish ValidationCompleted
    ORCH-->>API: validationId
    API-->>UI: 202 Accepted
```

## Kljuicne notranje komponente

- ValidationController: REST vhod, validacija payload in idempotency key.
- ValidationOrchestrator: orkestracija vseh korakov validacije.
- RuleSetProvider: nalaganje verzioniranih pravil mobilityDCAT-AP in DG MOVE.
- ShaclValidationEngine: SHACL shape kontrole.
- SparqlRuleEngine: semanticna pravila in cross-record kontrole.
- QualityChecksEngine: popolnost, konsistentnost, formatna pravilnost, unikatnost.
- ResultAggregator: normalizacija findings in izracun skupnega compliance score.
- RecommendationBuilder: predlogi izboljsav po tipu napake.

## Predlagane kode pogodbe (notranje)

- Command: StartValidationCommand
- Query: GetValidationStatusQuery
- Event: ValidationCompleted, ValidationFailed
- DTO: ValidationFindingDto, ValidationSummaryDto

## Nefunkcionalne zahteve

- Asinhrono izvajanje (queue-based) za vecje pakete metapodatkov.
- Deterministicni rezultati za isti vhod + isti profil pravil.
- Popolna sledljivost (audit trail) in verzioniranje pravil.
- Cilj odziva API za oddajo opravila: < 300 ms (p95).
