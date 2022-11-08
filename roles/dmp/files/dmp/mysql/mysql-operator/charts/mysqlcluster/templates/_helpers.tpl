{{- define "cluster.name" -}}
{{- default .Release.Name .Values.name }}
{{- end }}

{{- define "images.sidecar" -}}
{{ ternary (printf "radondb/mysql80-sidecar:%s" .Values.version ) (printf "radondb/mysql57-sidecar:%s" .Values.version ) (eq .Values.mysqlVersion "8.0") }}
{{- end }}

{{- define "user.secret.name" -}}
{{ "sample-user-password" }}
{{- end }}

{{- define "user.cr.name" -}}
{{ printf "%s-%s-%s" ( include "cluster.name" . ) .Release.Namespace (.Values.superUser.name | replace "_" "-") }}
{{- end }}

{{- define "schedule.disable" }}
{{- and (not .Values.schedule.podAntiaffinity) (not .Values.schedule.nodeSelector) }}
{{- end }}

{{- define "tls.server.secret" -}}
{{ printf "%s-%s-%s" ( include "cluster.name" . ) .Release.Namespace "tls-server" }}
{{- end }}

{{- define "tls.client.secret" -}}
{{ printf "%s-%s-%s" ( include "cluster.name" . ) .Release.Namespace "tls-client" }}
{{- end }}

{{- define "cluster.tls.secret.name" -}}
{{- if (and .Values.tls.enable (empty .Values.tls.secretName)) -}}
    {{ include "tls.server.secret" . }}
{{- else -}}
    {{ .Values.tls.secretName }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mysql-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mysql-cluster.labels" }}
app.kubernetes.io/name: {{ include "cluster.name" . }}
helm.sh/chart: {{ include "mysql-cluster.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
