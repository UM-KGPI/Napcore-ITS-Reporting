# ADR-0004: Thymeleaf + htmx UI through the public API

- Status: Accepted
- Date: 2026-10-23

## Context

The UI is mostly forms and review steps: the Annex I sections, the 2.5 tables, the KPI inputs, then review and sign-off. The team wants a light UI and a single Java codebase. Because the solution is API-first (ADR-0003), every feature the UI offers must also be available to adopters through the API.

## Decision

- **Rendering:** server-side with Thymeleaf; interactions with htmx. The UI is served by the application itself.
- **Business rules stay on the server.** Workflow state, Annex II obligations and completeness checks live in the domain modules, not in client-side code.
- **The UI uses the public API only.** Web controllers call the generated API delegate interfaces (ADR-0003) in-process, the same ones the REST controllers serve. They do not call domain services or repositories directly.
- **Enforcement:** an ArchUnit / Spring Modulith test fails the build if the `web` package depends on anything other than the generated API package and view models.
- **Templates hold no logic:** they render prepared view models only.

## Consequences

- Anything the UI can do is, by construction, also available over REST.
- Adopters can replace the UI entirely (e.g. with their own SPA) and lose nothing.
- Job progress uses server-sent events through htmx; the proxy must not buffer that endpoint (ADR-0006).
- i18n message bundles are needed from the start, for national languages.
