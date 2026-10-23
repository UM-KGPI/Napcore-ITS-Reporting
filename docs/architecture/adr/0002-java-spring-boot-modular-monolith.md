# ADR-0002: Java / Spring Boot modular monolith

- Status: Proposed
- Date: 2026-10-23

## Context

The team chose Java for the core and the API. The C4 container view has eleven logical services, with an event bus, triplestore, relational DB and document store. The Structurizr DSL labels them Node.js, Python and Java.

The expected load is low: about 30 national reporting teams, with an intense period every three years and NAP harvesting in between. In the current DSL, services publish events but no service consumes them. Several services overlap: Workflow Orchestrator, Guided Workflow Engine and BFF workflow endpoints; Recommendation Service and Recommendation Builder.

## Decision

- **Language and runtime:** Java, current LTS (21 or 25, fixed at project setup), with Spring Boot.
- **Deployable unit:** one **modular monolith**. Each C4 container becomes a module with its own package boundary, verified by Spring Modulith:
  - ingestion
  - registry
  - dataset health
  - validation
  - complementary data
  - KPI
  - reporting
  - recommendation
  - workflow
- **Integration between modules:** in-process application events, with a transactional outbox where durability is needed. No Kafka or RabbitMQ.
- **RDF:** Apache Jena for parsing JSON-LD, Turtle and RDF/XML and for SPARQL. Apache Jena Fuseki (TDB2) is the RDF store, with one named graph per harvest snapshot.
- **Relational data:** PostgreSQL with Flyway migrations.
- **Merged components:** workflow state is owned by one module (workflow); recommendations by one module (recommendation).

## Consequences

- The C4 *logical* view stays valid. The Structurizr DSL technology labels and the deployment view need updating.
- The event bus container leaves the deployment; the module boundaries keep a later split into services possible.
- One build, one pipeline and one runtime to operate, which suits a pilot and the adopters who will run it.
- The Node.js scaffold (`scaffold/`) is superseded and should be replaced by the Java project skeleton.
