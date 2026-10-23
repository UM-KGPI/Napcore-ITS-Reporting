# ADR-0005: SHACL validation via the ITB mobilityDCAT-AP validator container

- Status: Accepted
- Date: 2026-10-23

## Context

The C4 Compliance Validation Service has its own SHACL engine and rule repository. The mobilityDCAT-AP community already publishes a validator, [itb-validator-mobilitydcat-ap](https://github.com/mobilityDCAT-AP/itb-validator-mobilitydcat-ap). It is a configuration of the EC Interoperability Test Bed SHACL validator (`isaitb/shacl-validator`, EUPL-1.2) and ships as a Docker image. It supports mobilityDCAT-AP 1.0.0, 1.0.1, 1.1.0 and 3.0.0, with the profiles `core`, `range`, `full` and `cv`. Its REST call is:

```
POST /shacl/mobilityDCAT-AP/api/validate
{ "contentToValidate": "...", "embeddingMethod": "BASE64|URL|STRING",
  "contentSyntax": "text/turtle", "validationType": "v3.0.0.full",
  "reportSyntax": "application/json" }
```

Adopters must be able to add their own validation rules. This is a key requirement.

Upstream state, checked 2026-10-23:

- mobilityDCAT-AP 3.0.0 was published on 2026-10-19 as a NAPCORE Recommendation. Its shapes are at `releases/3.0.0/shacl/*.ttl`.
- The validator's `config.properties` still points the v3.0.0 profiles at `drafts/latest/shaclShapes/*.ttl`. All six of those URLs return HTTP 404, so the v3.0.0 profiles are expected to fail to load. Not yet confirmed by running the container.
- The Dockerfile builds `FROM isaitb/shacl-validator:latest`, and shapes are fetched remotely at runtime.
- The v3.0.0 shapes `owl:imports` the DCAT-AP 3.0.1 base shapes; inherited constraints are not restated. The validator sets `validator.loadImports = false` by default. It still has to be checked whether the inherited DCAT-AP constraints are applied.

## Decision

- The ITB validator runs as a **sidecar container**. Our validation module orchestrates calls, normalises findings, computes scores and builds recommendations. It does not embed its own SHACL engine for mobilityDCAT-AP conformance.
- **Our own image** builds `FROM isaitb/shacl-validator@sha256:<pinned digest>`. It carries our `resources/` with:
  - `mobilityDCAT-AP/`: the upstream configuration, with shape URLs corrected to `releases/3.0.0/shacl/` and **shape files bundled locally** (`validator.shaclFile.*.path`) for every supported version;
  - `napits-reporting/`: our reporting-readiness shapes, e.g. `applicableLegislation` present, Annex III theme mapping, `networkCoverage` present;
  - `<adopter>/`: **adopter rule domains**. Each adopter adds a folder with `config.properties` and SHACL files. No Java change is needed.
- **Supported profiles at start:** 1.0.1, 1.1.0 and 3.0.0. The profile is selected from the catalogue record's `dct:conformsTo` and can be overridden per run.
- Each `ValidationRun` stores the image digest, domain, validation type and shape-file checksums. This makes results reproducible: same input + same profile = same result.
- The shape-URL fix is offered upstream as a pull request. Until it is merged we keep our own corrected configuration.

## Consequences

- No duplicate SHACL implementation; upstream improvements arrive by bumping the pinned base image and shapes.
- Adopters' rules are configuration, versioned in their own folder, and appear as separate validation types in the API.
- Bundling DCAT-AP 3.0.1 base shapes may be required, depending on the `loadImports` check. To verify as the first task once the container runs.
- The upstream configuration repository has no licence file. Ask the maintainers to add one before redistributing a modified copy.
