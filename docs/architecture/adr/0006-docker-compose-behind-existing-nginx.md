# ADR-0006: Docker Compose deployment behind the existing nginx

- Status: Accepted
- Date: 2026-10-23

## Context

The solution must run in Docker, and adopters need a simple way to run it. The deployment server already runs nginx as the edge for the Helpdesk solution, handling TLS, certificates, headers and logs. The validator (ADR-0005) is a container.

## Decision

- **Docker Compose services:**
  - `app`: the Spring Boot modular monolith, including the UI;
  - `validator`: our pinned ITB validator image (ADR-0005);
  - `fuseki`: RDF store;
  - `postgres`;
  - `keycloak`: OIDC; Member State as tenant and role. Only if the Helpdesk has no identity provider that can be reused.
- **Exposure:** only `app` publishes a port, bound to `127.0.0.1`. The validator, Fuseki, Postgres and Keycloak's admin console stay on the internal Compose network.
- **Edge:** the existing host nginx is the edge. The reporter gets its own config file (e.g. `conf.d/its-reporter.conf`), separate from the Helpdesk blocks. It sets:
  - TLS with the existing certificate setup;
  - `client_max_body_size` for catalogue uploads (value set after measuring real NAP dumps);
  - `proxy_buffering off` on the job-progress (SSE) endpoint;
  - long cache lifetimes for static assets;
  - `X-Forwarded-*` headers.
- **Spring side:** `server.forward-headers-strategy=framework`. A matching `server.servlet.context-path` if mounted under a sub-path.
- **What we publish for adopters:** container images, a `compose.yaml`, an `.env.example` and an example nginx file.
- **Tests:** integration tests use Testcontainers with the same images, including the validator.

## Consequences

- One edge for both systems; no second TLS setup.
- A configuration error in the shared nginx could affect the Helpdesk. Every change is validated with `nginx -t` before reload and kept in the reporter's own file.
- Adopters without nginx can use any reverse proxy; only the headers and SSE buffering are required.
