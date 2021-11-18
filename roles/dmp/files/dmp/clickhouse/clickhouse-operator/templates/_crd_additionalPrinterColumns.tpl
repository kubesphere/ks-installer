{{- define "clickhouseinstallations.additionalPrinterColumnsV1Beta1" }}
additionalPrinterColumns:
  - name: version
    type: string
    description: Operator version
    priority: 1 # show in wide view
    JSONPath: .status.version
  - name: clusters
    type: integer
    description: Clusters count
    priority: 0 # show in standard view
    JSONPath: .status.clusters
  - name: shards
    type: integer
    description: Shards count
    priority: 1 # show in wide view
    JSONPath: .status.shards
  - name: hosts
    type: integer
    description: Hosts count
    priority: 0 # show in standard view
    JSONPath: .status.hosts
  - name: state
    type: string
    description: CHI status
    priority: 0 # show in standard view
    JSONPath: .status.state
  - name: updated
    type: integer
    description: Updated hosts count
    priority: 1 # show in wide view
    JSONPath: .status.updated
  - name: added
    type: integer
    description: Added hosts count
    priority: 1 # show in wide view
    JSONPath: .status.added
  - name: deleted
    type: integer
    description: Hosts deleted count
    priority: 1 # show in wide view
    JSONPath: .status.deleted
  - name: delete
    type: integer
    description: Hosts to be deleted count
    priority: 1 # show in wide view
    JSONPath: .status.delete
  - name: endpoint
    type: string
    description: Client access endpoint
    priority: 1 # show in wide view
    JSONPath: .status.endpoint
{{- end }}

{{- define "clickhouseinstallations.additionalPrinterColumnsV1" }}
additionalPrinterColumns:
  - name: version
    type: string
    description: Operator version
    priority: 1 # show in wide view
    jsonPath: .status.version
  - name: clusters
    type: integer
    description: Clusters count
    priority: 0 # show in standard view
    jsonPath: .status.clusters
  - name: shards
    type: integer
    description: Shards count
    priority: 1 # show in wide view
    jsonPath: .status.shards
  - name: hosts
    type: integer
    description: Hosts count
    priority: 0 # show in standard view
    jsonPath: .status.hosts
  - name: state
    type: string
    description: CHI status
    priority: 0 # show in standard view
    jsonPath: .status.state
  - name: updated
    type: integer
    description: Updated hosts count
    priority: 1 # show in wide view
    jsonPath: .status.updated
  - name: added
    type: integer
    description: Added hosts count
    priority: 1 # show in wide view
    jsonPath: .status.added
  - name: deleted
    type: integer
    description: Hosts deleted count
    priority: 1 # show in wide view
    jsonPath: .status.deleted
  - name: delete
    type: integer
    description: Hosts to be deleted count
    priority: 1 # show in wide view
    jsonPath: .status.delete
  - name: endpoint
    type: string
    description: Client access endpoint
    priority: 1 # show in wide view
    jsonPath: .status.endpoint
{{- end }}

{{- define "clickhouseinstallationtemplates.additionalPrinterColumnsV1Beta1" }}
additionalPrinterColumns:
  - name: version
    type: string
    description: Operator version
    priority: 1 # show in wide view
    JSONPath: .status.version
  - name: clusters
    type: integer
    description: Clusters count
    priority: 0 # show in standard view
    JSONPath: .status.clusters
  - name: shards
    type: integer
    description: Shards count
    priority: 1 # show in wide view
    JSONPath: .status.shards
  - name: hosts
    type: integer
    description: Hosts count
    priority: 0 # show in standard view
    JSONPath: .status.hosts
  - name: state
    type: string
    description: CHI status
    priority: 0 # show in standard view
    JSONPath: .status.state
  - name: updated
    type: integer
    description: Updated hosts count
    priority: 1 # show in wide view
    JSONPath: .status.updated
  - name: added
    type: integer
    description: Added hosts count
    priority: 1 # show in wide view
    JSONPath: .status.added
  - name: deleted
    type: integer
    description: Hosts deleted count
    priority: 1 # show in wide view
    JSONPath: .status.deleted
  - name: delete
    type: integer
    description: Hosts to be deleted count
    priority: 1 # show in wide view
    JSONPath: .status.delete
  - name: endpoint
    type: string
    description: Client access endpoint
    priority: 1 # show in wide view
    JSONPath: .status.endpoint
{{- end }}

{{- define "clickhouseinstallationtemplates.additionalPrinterColumnsV1" }}
additionalPrinterColumns:
  - name: version
    type: string
    description: Operator version
    priority: 1 # show in wide view
    jsonPath: .status.version
  - name: clusters
    type: integer
    description: Clusters count
    priority: 0 # show in standard view
    jsonPath: .status.clusters
  - name: shards
    type: integer
    description: Shards count
    priority: 1 # show in wide view
    jsonPath: .status.shards
  - name: hosts
    type: integer
    description: Hosts count
    priority: 0 # show in standard view
    jsonPath: .status.hosts
  - name: state
    type: string
    description: CHI status
    priority: 0 # show in standard view
    jsonPath: .status.state
  - name: updated
    type: integer
    description: Updated hosts count
    priority: 1 # show in wide view
    jsonPath: .status.updated
  - name: added
    type: integer
    description: Added hosts count
    priority: 1 # show in wide view
    jsonPath: .status.added
  - name: deleted
    type: integer
    description: Hosts deleted count
    priority: 1 # show in wide view
    jsonPath: .status.deleted
  - name: delete
    type: integer
    description: Hosts to be deleted count
    priority: 1 # show in wide view
    jsonPath: .status.delete
  - name: endpoint
    type: string
    description: Client access endpoint
    priority: 1 # show in wide view
    jsonPath: .status.endpoint
{{- end }}


{{- define "clickhouseoperatorconfigurations.additionalPrinterColumnsV1Beta1" }}
additionalPrinterColumns:
  - name: namespaces
    type: string
    description: Watch namespaces
    priority: 0 # show in standard view
    JSONPath: .status
{{- end }}

{{- define "clickhouseoperatorconfigurations.additionalPrinterColumnsV1" }}
additionalPrinterColumns:
  - name: namespaces
    type: string
    description: Watch namespaces
    priority: 0 # show in standard view
    jsonPath: .status
{{- end }}