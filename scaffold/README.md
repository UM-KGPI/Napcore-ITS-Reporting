# Implementation Scaffold (API-First)

This scaffold provides a minimal monorepo starter aligned with:

- docs/api/openapi-bff.yaml
- docs/api/openapi-validation.yaml
- docs/api/openapi-reporting.yaml

## Structure

- services/bff: Backend-for-Frontend service
- services/validation: Compliance validation service
- services/reporting: Report generation service
- packages/shared: shared types and utilities

## Suggested stack

- Runtime: Node.js 22+
- Language: TypeScript
- HTTP: Fastify
- OpenAPI validation: @fastify/swagger, @fastify/swagger-ui, ajv
- Logging: pino

## Next implementation steps

1. Install dependencies and run type checks.
2. Replace TODO handlers with business logic.
3. Add adapters for RDF store, DB, and queue/event bus.
4. Add contract tests against OpenAPI specs.
