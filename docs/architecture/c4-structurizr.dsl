workspace "NAP ITS Reporter" "C4 model for the web application using a Federated Registry and Discoverability architecture for cross-NAP interoperability" {

    model {
        napOperator = person "Member state" "Reviews compliance, validates metadata, and prepares reports."

        nap = softwareSystem "NAP endpoints" "NAP catalog and API endpoints for metadata."
        dgMove = softwareSystem "DG MOVE templates" "Reporting templates and KPI requirements."

        reporter = softwareSystem "NAP ITS Reporter" "Web application for automated metadata ingestion, validation, and reporting." {
            webUi = container "Web UI" "SPA for guided reporting workflows, compliance dashboard, and non-compliance visualization." "TypeScript"
            apiDocs = container "API Documentation Portal" "OpenAPI/Swagger portal for API endpoint documentation and contracts." "Static web app"
            bff = container "API Gateway" "Frontend-oriented API composition layer serving as a single API entry point and request orchestration for the UI." "Node.js"

            ingestion = container "2. Metadata Ingestion Service" "Discovers, fetches, and normalizes metadata from NAP in JSON-LD, TTL, and RDF/XML formats." "Node.js"
            registryDiscoverability = container "Federated Registry and Discoverability Service" "Implements the Federated Registry and Discoverability architecture for cross-NAP interoperability by interlinking heterogeneous NAPs, providing searchable discovery of endpoints, datasets, and cross-NAP relationships, and maintaining trustable dataset health readiness derived from mobilityDCAT-AP metadata and active availability checks." "Node.js" {
                datasetCatalogController = component "Dataset Catalog Controller" "REST entry point for registry dataset lookup and dataset health queries." "HTTP API"
                datasetMetadataResolver = component "Dataset Metadata Resolver" "Resolves dataset identifiers to mobilityDCAT-AP metadata records and distributions." "Domain service"
                distributionEndpointExtractor = component "Distribution Endpoint Extractor" "Extracts access, download, or service URLs from dataset distributions." "Domain service"
                availabilityProbe = component "Availability Probe" "Executes HEAD, GET, or API probes against dataset delivery services." "Integration component"
                healthTrustEvaluator = component "Health Trust Evaluator" "Computes ready, degraded, unavailable, or unknown readiness states from metadata resolution, probe results, and freshness policy." "Policy component"
                healthStatusCache = component "Health Status Cache" "Stores the latest trusted dataset health result and evidence." "Caching component"
            }
            datasetHealthStatus = container "NAP Dataset Health Status Service" "Evaluates and publishes trusted dataset health status for NAP datasets using metadata resolution and endpoint availability checks." "Node.js"
            validation = container "2.1 Validation service" "mobilityDCAT-AP consisteny check" "Java" {
                validationController = component "Validation Controller" "REST entry point for validation jobs." "HTTP API"
                validationOrchestrator = component "Validation Orchestrator" "Executes SHACL, SPARQL, and quality checks." "Application service"
                ruleSetProvider = component "Rule Set Provider" "Loads versioned validation rules." "Domain service"
                shaclEngine = component "SHACL Engine" "Runs SHACL validation on RDF graphs." "Validation engine"
                sparqlEngine = component "SPARQL Rule Engine" "Runs semantic and cross-record checks." "Validation engine"
                qualityEngine = component "Quality Checks Engine" "Checks completeness, accuracy, and consistency." "Validation engine"
                nonComplianceReportGenerator = component "Non-Compliance Report Generator" "Builds non-compliance report outputs." "Reporting component"
                findingsAggregator = component "Findings Aggregator" "Normalizes findings and calculates score." "Domain service"
                recommendationBuilder = component "Recommendation Builder" "Builds improvement recommendations." "Domain service"
            }
            kpi = container "4. KPI Mapping and Analytics Service" "Maps metadata to KPI and reporting templates." "Python"
            reporting = container "1. Reporting Service" "Guided, semi-automated, and automated report generation." "Node.js" {
                reportingController = component "Reporting Controller" "REST entry point for reporting jobs." "HTTP API"
                reportingOrchestrator = component "Reporting Orchestrator" "Coordinates mapping, generation, and quality gate." "Application service"
                guidedWorkflowEngine = component "Guided Workflow Engine" "Maintains step state and user guidance." "Domain service"
                kpiMappingEngine = component "KPI Mapping Engine" "Maps metadata elements to KPI and templates." "Domain service"
                dgMoveTemplateMapper = component "DG MOVE Template Mapper" "Maps KPI outputs into DG MOVE template fields." "Domain service"
                templateProvider = component "Template Provider" "Manages DG MOVE template versions." "Integration component"
                automationModePlanner = component "Automation Mode Planner" "Selects guided, semi-auto, or full-auto report mode." "Policy component"
                reportGenerator = component "Report Generator" "Builds final reporting artifacts." "Generation engine"
                reportQualityGate = component "Report Quality Gate" "Enforces report completeness and consistency checks." "Policy component"
                exportManager = component "Export Manager" "Exports PDF/HTML/JSON outputs." "Output component"
            }
            complementaryData = container "3. Complementary Data Service" "Obtains additional data needed for reporting outputs." "Node.js"
            recommendation = container "Recommendation Service" "Provides improvement recommendations from findings." "Python"
            workflow = container "Reporting Orchestrator" "Orchestrates guided reporting workflow steps." "Node.js"
            iam = container "Authorization service" "RBAC/ABAC, auditing, and policy enforcement." "Node.js"

            metadataStore = container "Metadata Store" "RDF triplestore for metadata semantics." "RDF store"
            appDb = container "Application DB" "Configuration, jobs, statuses, and audit trail." "PostgreSQL"
            docsStore = container "Document Store" "Generated reports and export artifacts." "Object storage"
            eventBus = container "Event Bus" "Asynchronous service integration." "Kafka/RabbitMQ"
        }

        napOperator -> reporter "Uses for validation and reporting"

        reporter -> nap "Discovers and ingests metadata"
        reporter -> dgMove "Uses reporting templates"

        webUi -> bff "HTTPS/JSON"
        napOperator -> apiDocs "Reads endpoint docs"
        apiDocs -> bff "Documents endpoint contracts"
        bff -> registryDiscoverability "Queries registry and dataset health"
        bff -> datasetHealthStatus "Queries trusted dataset health status"
        bff -> workflow "Calls workflow APIs"
        bff -> iam "Authorizes requests"

        workflow -> ingestion "Starts ingestion"
        workflow -> registryDiscoverability "Calls interlinking and discovery services"
        workflow -> datasetHealthStatus "Requests health status refresh"
        workflow -> validation "Starts validation"
        workflow -> kpi "Calculates KPI"
        workflow -> reporting "Starts reporting"
        workflow -> complementaryData "Fetches complementary reporting data"
        workflow -> recommendation "Builds recommendations"

        ingestion -> registryDiscoverability "Uses ingestion and discovery connectors"
        datasetHealthStatus -> registryDiscoverability "Resolves dataset metadata and endpoints"
        datasetHealthStatus -> nap "Probes dataset delivery endpoints"
        datasetHealthStatus -> appDb "Persists and reads health evidence"
        registryDiscoverability -> nap "HTTP API"
        ingestion -> metadataStore "Stores RDF"

        validation -> metadataStore "Reads RDF"
        validation -> appDb "Stores findings"
        validation -> docsStore "Stores non-compliance reports"
        validation -> eventBus "Publishes ValidationCompleted"

        kpi -> metadataStore "Reads RDF"
        kpi -> appDb "Stores KPI results"
        kpi -> eventBus "Publishes KpiCalculated"

        complementaryData -> appDb "Stores complementary reporting data"
        complementaryData -> eventBus "Publishes ComplementaryDataReady"

        reporting -> dgMove "Reads templates"
        reporting -> appDb "Reads KPI and workflow data"
        reporting -> docsStore "Stores reports"
        reporting -> eventBus "Publishes ReportGenerated"

        recommendation -> appDb "Reads findings and KPI"
        recommendation -> appDb "Stores recommendations"

        iam -> appDb "Stores policy and audit data"

        validationController -> validationOrchestrator "startValidation"
        validationOrchestrator -> ruleSetProvider "loadRules"
        validationOrchestrator -> shaclEngine "execute"
        validationOrchestrator -> sparqlEngine "execute"
        validationOrchestrator -> qualityEngine "execute"
        shaclEngine -> findingsAggregator "findings"
        sparqlEngine -> findingsAggregator "findings"
        qualityEngine -> findingsAggregator "findings"
        findingsAggregator -> nonComplianceReportGenerator "buildNonComplianceReport"
        nonComplianceReportGenerator -> appDb "persistReportMetadata"
        nonComplianceReportGenerator -> docsStore "persistReportArtifacts"
        findingsAggregator -> recommendationBuilder "deriveRecommendations"
        findingsAggregator -> appDb "persistSummary"
        recommendationBuilder -> appDb "persistRecommendations"

        reportingController -> reportingOrchestrator "startReport"
        reportingOrchestrator -> guidedWorkflowEngine "resolveStepState"
        reportingOrchestrator -> kpiMappingEngine "resolveMappings"
        reportingOrchestrator -> dgMoveTemplateMapper "resolveTemplateMappings"
        reportingOrchestrator -> templateProvider "loadTemplate"
        reportingOrchestrator -> automationModePlanner "selectMode"
        reportingOrchestrator -> reportGenerator "generate"
        reportingOrchestrator -> reportQualityGate "validate"
        reportingOrchestrator -> exportManager "export"
        templateProvider -> dgMove "retrieveVersions"
        reportGenerator -> docsStore "writeDraftAndFinal"
        exportManager -> docsStore "writeExports"
        reportQualityGate -> appDb "persistQualityResults"

        datasetCatalogController -> datasetMetadataResolver "resolveDataset"
        datasetMetadataResolver -> metadataStore "readDatasetGraph"
        datasetMetadataResolver -> distributionEndpointExtractor "extractDistributionEndpoints"
        distributionEndpointExtractor -> availabilityProbe "probeTarget"
        availabilityProbe -> nap "HTTP API"
        availabilityProbe -> healthTrustEvaluator "probeResult"
        datasetMetadataResolver -> healthTrustEvaluator "metadataResolution"
        healthTrustEvaluator -> healthStatusCache "persistHealthStatus"
        datasetCatalogController -> healthStatusCache "readLatestHealth"
        healthStatusCache -> appDb "persistAndReadStatus"
    }

    views {
        systemContext reporter "SystemContext" {
            include *
            autoLayout lr
        }

        container reporter "Container" {
            include *
            autoLayout tb
        }

        component validation "ValidationComponents" {
            include validationController
            include validationOrchestrator
            include ruleSetProvider
            include shaclEngine
            include sparqlEngine
            include qualityEngine
            include nonComplianceReportGenerator
            include findingsAggregator
            include recommendationBuilder
            include metadataStore
            include appDb
            include docsStore
            include eventBus
            include dgMove
            autoLayout lr
        }

        component reporting "ReportingComponents" {
            include reportingController
            include reportingOrchestrator
            include guidedWorkflowEngine
            include kpiMappingEngine
            include dgMoveTemplateMapper
            include templateProvider
            include automationModePlanner
            include reportGenerator
            include reportQualityGate
            include exportManager
            include appDb
            include docsStore
            include dgMove
            autoLayout lr
        }

        component registryDiscoverability "RegistryDiscoverabilityComponents" {
            include datasetCatalogController
            include datasetMetadataResolver
            include distributionEndpointExtractor
            include availabilityProbe
            include healthTrustEvaluator
            include healthStatusCache
            include metadataStore
            include appDb
            include nap
            autoLayout lr
        }

        theme default
    }
}
