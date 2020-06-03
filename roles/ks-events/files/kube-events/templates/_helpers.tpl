{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kube-events.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kube-events.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kube-events.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "kube-events.labels" -}}
helm.sh/chart: {{ include "kube-events.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "kube-events.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Fullname suffixed with operator */}}
{{- define "kube-events.operator.fullname" -}}
{{- printf "%s-operator" (include "kube-events.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with exporter */}}
{{- define "kube-events.exporter.fullname" -}}
{{- printf "%s-exporter" (include "kube-events.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with ruler */}}
{{- define "kube-events.ruler.fullname" -}}
{{- printf "%s-ruler" (include "kube-events.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with admission */}}
{{- define "kube-events.admission.fullname" -}}
{{- printf "%s-admission" (include "kube-events.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with cluster-rules-default */}}
{{- define "kube-events.cluster-rules-default.fullname" -}}
{{- printf "%s-cluster-rules-default" (include "kube-events.fullname" .) -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kube-events.operator.serviceAccountName" -}}
{{- if .Values.operator.serviceAccount.create -}}
    {{ default (include "kube-events.operator.fullname" .) .Values.operator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.operator.serviceAccount.name }}
{{- end -}}
{{- end -}}