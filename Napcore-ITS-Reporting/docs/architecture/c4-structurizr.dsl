workspace "NAP ITS Reporter" "C4 model for the web application" {

    model {
        pilotAnalyst = person "Pilot User (NAP Analyst)" "Reviews compliance and prepares reports."
        administrator = person "Administrator" "Manages rules, configuration, and access."

        nap = softwareSystem "NAP endpoints" "National catalogs and API endpoints for metadata."
        dgMove = softwareSystem "DG MOVE templates" "Reporting templates and KPI requirements."
        idp = softwareSystem "Identity Provider" "External OIDC/SAML identity provider."

        reporter = softwareSystem "NAP ITS Reporter" "Web application for automated metadata ingestion, validation, and reporting." {
            webUi = container "Web UI" "SPA for guided reporting workflows and compliance dashboard." "TypeScript"
            bff = container "API Gateway/BFF" "Single API entry point and request orchestration for the UI." "Node.js"

            ingestion = container "Metadata Ingestion Service" "Discovers, fetches, and normalizes metadata from NAP." "Node.js"
            validation = container "Compliance Validation Service" "Validates compliance with mobilityDCAT-AP and DG MOVE rules." "Java"
            kpi = container "KPI Mapping and Analytics Service" "Maps metadata to KPI and reporting templates." "Python"
            reporting = container "Reporting Service" "Semi-automated and automated report generation." "Node.js"
            recommendation = container "Recommendation Service" "Provides improvement recommendations from findings." "Python"
            workflow = container "Workflow Orchestrator" "Orchestrates guided reporting workflow steps." "Node.js"
            iam = container "AuthN/AuthZ Service" "RBAC/ABAC, auditing, and policy enforcement." "Node.js"

            metadataStore = container "Metadata Store" "RDF triplestore for metadata semantics." "RDF store"
            appDb = container "Application DB" "Configuration, jobs, statuses, and audit trail." "PostgreSQL"
            docsStore = container "Document Store" "Generated reports and export artifacts." "Object storage"
            eventBus = container "Event Bus" "Asynchronous service integration." "Kafka/RabbitMQ"

            validationController = component "Validation Controller" "REST entry point for validation jobs." "HTTP API"
            validationOrchestrator = component "Validation Orchestrator" "Executes SHACL, SPARQL, and quality checks." "Application service"
            ruleSetProvider = component "Rule Set Provider" "Loads versioned validation rules." "Domain service"
            shaclEngine = component "SHACL Engine" "Runs SHACL validation on RDF graphs." "Validation engine"
            sparqlEngine = component "SPARQL Rule Engine" "Runs semantic and cross-record checks." "Validation engine"
            qualityEngine = component "Quality Checks Engine" "Checks completeness, accuracy, and consistency." "Validation engine"
            findingsAggregator = component "Findings Aggregator" "Normalizes findings and calculates score." "Domain service"
            recommendationBuilder = component "Recommendation Builder" "Builds improvement recommendations." "Domain service"

            reportingController = component "Reporting Controller" "REST entry point for reporting jobs." "HTTP API"
            reportingOrchestrator = component "Reporting Orchestrator" "Coordinates mapping, generation, and quality gate." "Application service"
            guidedWorkflowEngine = component "Guided Workflow Engine" "Maintains step state and user guidance." "Domain service"
            kpiMappingEngine = component "KPI Mapping Engine" "Maps metadata elements to KPI and templates." "Domain service"
            templateProvider = component "Template Provider" "Manages DG MOVE template versions." "Integration component"
            reportGenerator = component "Report Generator" "Builds final reporting artifacts." "Generation engine"
            reportQualityGate = component "Report Quality Gate" "Enforces report completeness and consistency checks." "Policy component"
            exportManager = component "Export Manager" "Exports PDF/HTML/JSON outputs." "Output component"
        }

        pilotAnalyst -> reporter "Uses for validation and reporting"
        administrator -> reporter "Manages configuration and access"

        reporter -> nap "Discovers and ingests metadata"
        reporter -> dgMove "Uses reporting templates"
        reporter -> idp "Delegates authentication"

        webUi -> bff "HTTPS/JSON"
        bff -> workflow "Calls workflow APIs"
        bff -> iam "Authorizes requests"

        workflow -> ingestion "Starts ingestion"
        workflow -> validation "Starts validation"
        workflow -> kpi "Calculates KPI"
        workflow -> reporting "Starts reporting"
        workflow -> recommendation "Builds recommendations"

        ingestion -> nap "HTTP API"
        ingestion -> metadataStore "Stores RDF"

        validation -> metadataStore "Reads RDF"
        validation -> appDb "Stores findings"
        validation -> eventBus "Publishes ValidationCompleted"

        kpi -> metadataStore "Reads RDF"
        kpi -> appDb "Stores KPI results"
        kpi -> eventBus "Publishes KpiCalculated"

        reporting -> dgMove "Reads templates"
        reporting -> appDb "Reads KPI and workflow data"
        reporting -> docsStore "Stores reports"
        reporting -> eventBus "Publishes ReportGenerated"

        recommendation -> appDb "Reads findings and KPI"
        recommendation -> appDb "Stores recommendations"

        iam -> idp "OIDC/SAML"
        iam -> appDb "Stores policy and audit data"

        validationController -> validationOrchestrator "startValidation"
        validationOrchestrator -> ruleSetProvider "loadRules"
        validationOrchestrator -> shaclEngine "execute"
        validationOrchestrator -> sparqlEngine "execute"
        validationOrchestrator -> qualityEngine "execute"
        shaclEngine -> findingsAggregator "findings"
        sparqlEngine -> findingsAggregator "findings"
        qualityEngine -> findingsAggregator "findings"
        findingsAggregator -> recommendationBuilder "deriveRecommendations"
        findingsAggregator -> appDb "persistSummary"
        recommendationBuilder -> appDb "persistRecommendations"

        reportingController -> reportingOrchestrator "startReport"
        reportingOrchestrator -> guidedWorkflowEngine "resolveStepState"
        reportingOrchestrator -> kpiMappingEngine "resolveMappings"
        reportingOrchestrator -> templateProvider "loadTemplate"
        reportingOrchestrator -> reportGenerator "generate"
        reportingOrchestrator -> reportQualityGate "validate"
        reportingOrchestrator -> exportManager "export"
        templateProvider -> dgMove "retrieveVersions"
        reportGenerator -> docsStore "writeDraftAndFinal"
        exportManager -> docsStore "writeExports"
        reportQualityGate -> appDb "persistQualityResults"
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
            include findingsAggregator
            include recommendationBuilder
            include metadataStore
            include appDb
            include eventBus
            include dgMove
            autoLayout lr
        }

        component reporting "ReportingComponents" {
            include reportingController
            include reportingOrchestrator
            include guidedWorkflowEngine
            include kpiMappingEngine
            include templateProvider
            include reportGenerator
            include reportQualityGate
            include exportManager
            include appDb
            include docsStore
            include dgMove
            autoLayout lr
        }

        theme default
    }
}
