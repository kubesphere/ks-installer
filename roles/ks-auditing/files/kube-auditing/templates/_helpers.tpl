{{/*
Common labels
*/}}
{{- define "operator.labels" -}}
app.kubernetes.io/name: {{ "kube-auditing-operator" }}
helm.sh/chart: {{ .Chart.Version }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

