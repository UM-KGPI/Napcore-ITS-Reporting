workspace "mobilityDCAT-AP Pilot" "C4 model for the pilot web application" {

    model {
        pilotAnalyst = person "Pilotni uporabnik (NAP analitik)" "Pregleduje skladnost in pripravlja porocila."
        administrator = person "Administrator" "Upravlja pravila, konfiguracijo in dostop."

        nap = softwareSystem "NAP endpoints" "Nacionalni katalogi in API koncne tocke za metapodatke."
        dgMove = softwareSystem "DG MOVE templates" "Porocevalske predloge in KPI zahteve."
        idp = softwareSystem "Identity Provider" "Zunanji OIDC/SAML ponudnik identitete."

        pilotApp = softwareSystem "Pilotna aplikacija mobilityDCAT-AP" "Spletna aplikacija za avtomatizirano zbiranje, validacijo in porocanje metapodatkov." {
            webUi = container "Web UI" "SPA za vodene tokove porocanja in nadzorno plosco skladnosti." "TypeScript"
            bff = container "API Gateway/BFF" "Enotna API vstopna tocka in orkestracija zahtev iz UI." "Node.js"

            ingestion = container "Metadata Ingestion Service" "Odkrivanje, zajem in normalizacija metapodatkov iz NAP." "Node.js"
            validation = container "Compliance Validation Service" "Preverjanje skladnosti mobilityDCAT-AP in DG MOVE pravil." "Java"
            kpi = container "KPI Mapping and Analytics Service" "Preslikave med metapodatki, KPI in predlogami porocanja." "Python"
            reporting = container "Reporting Service" "Delno/polno avtomatizirano ustvarjanje porocil." "Node.js"
            recommendation = container "Recommendation Service" "Predlogi izboljsav na podlagi findings." "Python"
            workflow = container "Workflow Orchestrator" "Vodenje korakov guided workflow." "Node.js"
            iam = container "AuthN/AuthZ Service" "RBAC/ABAC, auditing, policy enforcement." "Node.js"

            metadataStore = container "Metadata Store" "RDF triplestore za semantiko metapodatkov." "RDF store"
            appDb = container "Application DB" "Konfiguracija, opravila, statusi, revizijske sledi." "PostgreSQL"
            docsStore = container "Document Store" "Generirana porocila in izvozi." "Object storage"
            eventBus = container "Event Bus" "Asinhrona integracija med storitvami." "Kafka/RabbitMQ"

            validationController = component "Validation Controller" "REST vhod za validacijska opravila." "HTTP API"
            validationOrchestrator = component "Validation Orchestrator" "Vodi SHACL, SPARQL in quality kontrole." "Application service"
            ruleSetProvider = component "Rule Set Provider" "Nalaganje verzioniranih pravil." "Domain service"
            shaclEngine = component "SHACL Engine" "SHACL validacija RDF grafov." "Validation engine"
            sparqlEngine = component "SPARQL Rule Engine" "Semanticna pravila in cross-record kontrole." "Validation engine"
            qualityEngine = component "Quality Checks Engine" "Popolnost, natančnost, konsistentnost." "Validation engine"
            findingsAggregator = component "Findings Aggregator" "Normalizacija findings in izracun score." "Domain service"
            recommendationBuilder = component "Recommendation Builder" "Priprava predlogov izboljsav." "Domain service"

            reportingController = component "Reporting Controller" "REST vhod za porocevalska opravila." "HTTP API"
            reportingOrchestrator = component "Reporting Orchestrator" "Vodi mapiranje, generiranje in quality gate." "Application service"
            guidedWorkflowEngine = component "Guided Workflow Engine" "Stanje korakov in navodila uporabniku." "Domain service"
            kpiMappingEngine = component "KPI Mapping Engine" "Preslikava elementov v KPI in predloge." "Domain service"
            templateProvider = component "Template Provider" "Upravljanje verzij DG MOVE predlog." "Integration component"
            reportGenerator = component "Report Generator" "Sestava izhodnega porocila." "Generation engine"
            reportQualityGate = component "Report Quality Gate" "Kontrole popolnosti in skladnosti porocila." "Policy component"
            exportManager = component "Export Manager" "Izvoz PDF/HTML/JSON." "Output component"
        }

        pilotAnalyst -> pilotApp "Uporablja za validacijo in porocanje"
        administrator -> pilotApp "Upravlja konfiguracijo in dostop"

        pilotApp -> nap "Odkriva in zajema metapodatke"
        pilotApp -> dgMove "Uporablja predloge porocanja"
        pilotApp -> idp "Delegira avtentikacijo"

        webUi -> bff "HTTPS/JSON"
        bff -> workflow "Klice tokov"
        bff -> iam "Autorizacija zahtev"

        workflow -> ingestion "Zagon zajema"
        workflow -> validation "Zagon validacije"
        workflow -> kpi "Izracun KPI"
        workflow -> reporting "Zagon porocanja"
        workflow -> recommendation "Priprava predlogov"

        ingestion -> nap "HTTP API"
        ingestion -> metadataStore "Shrani RDF"

        validation -> metadataStore "Beri RDF"
        validation -> appDb "Shrani findings"
        validation -> eventBus "Objavi ValidationCompleted"

        kpi -> metadataStore "Beri RDF"
        kpi -> appDb "Shrani KPI rezultate"
        kpi -> eventBus "Objavi KpiCalculated"

        reporting -> dgMove "Preberi predloge"
        reporting -> appDb "Beri KPI/Workflow podatke"
        reporting -> docsStore "Shrani porocila"
        reporting -> eventBus "Objavi ReportGenerated"

        recommendation -> appDb "Beri findings/KPI"
        recommendation -> appDb "Shrani predloge"

        iam -> idp "OIDC/SAML"
        iam -> appDb "Shrani politike in revizijo"

        validationController -> validationOrchestrator "startValidation"
        validationOrchestrator -> ruleSetProvider "loadRules"
        validationOrchestrator -> shaclEngine "execute"
        validationOrchestrator -> sparqlEngine "execute"
        validationOrchestrator -> qualityEngine "execute"
        shaclEngine -> findingsAggregator "findings"
        sparqlEngine -> findingsAggregator "findings"
        qualityEngine -> findingsAggregator "findings"
        findingsAggregator -> recommendationBuilder "derive recommendations"
        findingsAggregator -> appDb "persist summary"
        recommendationBuilder -> appDb "persist recommendations"

        reportingController -> reportingOrchestrator "startReport"
        reportingOrchestrator -> guidedWorkflowEngine "resolve step state"
        reportingOrchestrator -> kpiMappingEngine "resolve mappings"
        reportingOrchestrator -> templateProvider "load template"
        reportingOrchestrator -> reportGenerator "generate"
        reportingOrchestrator -> reportQualityGate "validate"
        reportingOrchestrator -> exportManager "export"
        templateProvider -> dgMove "retrieve versions"
        reportGenerator -> docsStore "write draft/final"
        exportManager -> docsStore "write exports"
        reportQualityGate -> appDb "persist quality results"
    }

    views {
        systemContext pilotApp "SystemContext" {
            include *
            autoLayout lr
        }

        container pilotApp "Container" {
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
