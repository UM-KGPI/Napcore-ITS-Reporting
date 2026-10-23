# ADR-0001: Report model follows Implementing Decision (EU) 2025/264

- Status: Proposed
- Date: 2026-10-23

## Context

The C4 design describes reporting as a metadata pipeline: "metadata -> KPI -> DG MOVE mappings", with guided, semi-automatic and fully automatic modes. The legally binding template is Annex I of Commission Implementing Decision (EU) 2025/264. Annex II sets which KPIs are mandatory, by geographical scope and cycle. The template consists mostly of:

- narrative sections;
- network-length shares per data type and TEN-T scope;
- deployment, benefit and financial KPIs computed from national figures.

mobilityDCAT-AP metadata can supply evidence for parts of sections 2.1, 2.3 and 2.5. It cannot supply network lengths or any KPI input. The current API drafts model the report as `period: 2026-Q2` and `scope: national | regional | operator`, which does not match one report per Member State every three years (2025, 2028, ...).

The README cited the Decision as a "Delegated Regulation"; it is an Implementing Decision.

## Decision

1. The report domain model is defined in [docs/domain/report-data-model.md](../../domain/report-data-model.md).
2. The template is a **versioned template pack** held as data ([template.yaml](../../domain/template-packs/eu-2025-264/template.yaml)), transcribed verbatim from the Official Journal. Amendments add a new pack version; reports keep the version they were created with.
3. The metadata-to-template mapping is a **separate file per mobilityDCAT-AP version** ([mapping-mobilitydcat-ap-3.0.0.yaml](../../domain/template-packs/eu-2025-264/mapping-mobilitydcat-ap-3.0.0.yaml)).
4. Every reported value carries **provenance**: manual, estimate, metadata-suggested, previous-report or computed, plus evidence references. Metadata produces suggestions and evidence, never a final reported value without user confirmation.
5. A report is identified by **Member State + cycle year**. It links to the previous report and freezes the harvest snapshots it cites at approval.
6. Annex II obligations are resolved by a data-driven rule, `obligation(kpi, scope, cycleYear)`.

## Consequences

- "Full-auto" report generation is dropped as a goal. Automation means pre-filling, evidence collection, KPI computation, completeness checks and export.
- The Complementary Data Service gets a concrete scope: manual inputs, national network reference lengths, previous-report import.
- The KPI Mapping Service is scoped to evidence derivation and KPI computation from entered inputs.
- The OpenAPI report resources follow the template's stable section, row and KPI IDs.
- An amended Decision, or a new mobilityDCAT-AP version, needs a new data file, not new code.
- Open points are tracked in section 7 of the data model: TEN-T scope wording, coarse network coverage, legislation IRIs.
