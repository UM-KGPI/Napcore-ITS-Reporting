# ADR-0007: EUPL-1.2 licence

- Status: Accepted (provisional, to be confirmed by the institution's legal office)
- Date: 2026-10-23

## Context

The solution is meant to be reused and adapted by other Member States and NAP operators, mostly public bodies that will host it rather than redistribute it. Key dependencies have these licences:

- the ITB SHACL validator: EUPL-1.2;
- the mobilityDCAT-AP specification: CC-BY-4.0;
- the planned libraries (Spring, Jena, Thymeleaf, htmx, Keycloak, PostgreSQL): permissive licences.

## Decision

The NAP ITS Reporter source code is licensed under **EUPL-1.2**. Template packs and documentation are published under CC-BY-4.0, in line with the mobilityDCAT-AP specification.

## Consequences

- **Fits EU public bodies:** the licence is drafted by the European Commission, equally valid in all official EU languages, and governed by the law of the licensor's Member State.
- **Hosted use is covered:** providing online access to the software's functionality counts as communication, so adopters who modify and host it must share their modifications.
- **Combinable:** the appendix lists compatible licences (GPL, AGPL, LGPL, MPL-2.0, EPL, CeCILL, OSL, among others), so the code can be combined with code under them.
- **Rules don't have to flow back:** adopters' own SHACL rule domains (ADR-0005) are most likely their own configuration, not a derivative work. Sharing them back is a governance matter, e.g. a shared rules repository, not something the licence enforces.
- **May deter commercial integrators** who want closed derivatives. If uptake matters more than reciprocity, a later ADR may supersede this with Apache-2.0.
- A `LICENSE` file and SPDX headers (`EUPL-1.2`) are added when the code skeleton is created.
