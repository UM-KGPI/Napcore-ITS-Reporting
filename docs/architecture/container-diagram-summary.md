# Container Diagram Summary

This note provides a short explanation of the C4 Container Diagram (Level 2) for NAP ITS Reporter.

## Purpose

The container diagram shows the main runtime building blocks, their responsibilities, and their data flow boundaries.

## Main Layers

- Presentation layer: Web UI and API Documentation Portal used by Member state users.
- Logical layer: API Gateway, Reporting Orchestrator, and domain services for ingestion, validation, KPI analytics, reporting, complementary data, recommendation, and authorization.
- Data layer: Metadata Store (RDF), Application DB (state/audit/configuration), Document Store (report artifacts), and Event Bus.

## Service Summaries

- API Gateway: Single API entry point for the UI; handles request routing and orchestration handoff.
- Reporting Orchestrator: Coordinates end-to-end reporting workflow steps across domain services.
- 2. Metadata Ingestion Service: Discovers, fetches, and normalizes metadata from NAP endpoints.
- Federated Registry and Discoverability Service: Resolves datasets/endpoints and supports cross-NAP discovery and readiness checks.
- NAP Dataset Health Status Service: Evaluates and publishes trusted dataset health status from metadata resolution and endpoint availability evidence.
- 2.1 Validation service: Executes mobilityDCAT-AP consistency checks and stores compliance findings.
- 4. KPI Mapping and Analytics Service: Maps metadata to KPI indicators and analytics-ready structures.
- 1. Reporting Service: Generates reporting outputs and applies DG MOVE template mappings.
- 3. Complementary Data Service: Obtains and stores additional data required for reporting outputs.
- Recommendation Service: Produces improvement suggestions from findings and KPI context.
- Authorization service: Enforces access control and supports policy/audit operations.

## Core Flow (Simplified)

1. Users interact through Web UI.
2. API Gateway routes requests and calls Reporting Orchestrator.
3. Reporting Orchestrator coordinates:
   - 2. Metadata Ingestion Service
   - NAP Dataset Health Status Service
   - 2.1 Validation service
   - 4. KPI Mapping and Analytics Service
   - 1. Reporting Service
   - 3. Complementary Data Service
   - Recommendation Service
4. Services read/write shared stores and publish/consume events through the Event Bus.
5. Reporting Service produces outputs using DG MOVE templates.

## External Interfaces

- NAP catalog and API endpoints for metadata and dataset endpoint discovery.
- DG MOVE templates for reporting output structure.
- European Mobility Dataspace (EMDS) interface as the architecture-level interoperability pattern marker.

## Scope Note

This is a container-level view. Internal components and implementation details are documented in the Level 3 and Level 4 architecture documents.
