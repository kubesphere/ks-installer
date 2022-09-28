{{/*
Expand the name of the chart.
*/}}
{{- define "whizard.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "whizard.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "whizard.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "whizard.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/* Common labels */}}
{{- define "whizard.labels" -}}
helm.sh/chart: {{ include "whizard.chart" . }}
{{ include "whizard.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "whizard.selectorLabels" -}}
app.kubernetes.io/name: {{ include "whizard.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Fullname suffixed with manager */}}
{{- define "whizard.manager.fullname" -}}
{{- printf "%s-controller-manager" (include "whizard.fullname" .) -}}
{{- end }}

{{/* Create the name of the service account to use for manager */}}
{{- define "whizard.manager.serviceAccountName" -}}
{{- if .Values.controllerManager.serviceAccount.create }}
{{- default (include "whizard.manager.fullname" .) .Values.controllerManager.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.controllerManager.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Storage custom resource instance name */}}
{{- define "whizard.storage.crname" -}}
{{- print (include "whizard.fullname" .) "-default" }}
{{- end }}

{{/* Service custom resource instance name */}}
{{- define "whizard.service.crname" -}}
{{- print (include "whizard.fullname" .) }}
{{- end }}

{{/* Gateway custom resource instance name */}}
{{- define "whizard.gateway.crname" -}}
{{- print (include "whizard.fullname" .) }}
{{- end }}

{{/* Query custom resource instance name */}}
{{- define "whizard.query.crname" -}}
{{- print (include "whizard.fullname" .) }}
{{- end }}

{{/* Compactor custom resource instance name */}}
{{- define "whizard.queryFrontend.crname" -}}
{{- print (include "whizard.fullname" .) }}
{{- end }}

{{/* Router custom resource instance name */}}
{{- define "whizard.router.crname" -}}
{{- print (include "whizard.fullname" .) }}
{{- end }}

{{/* Ingester custom resource instance name */}}
{{- define "whizard.ingester.crname" -}}
{{- print (include "whizard.fullname" .) }}
{{- end }}

{{/* Store custom resource instance name */}}
{{- define "whizard.store.crname" -}}
{{- print (include "whizard.fullname" .) }}
{{- end }}

{{/* Compactor custom resource instance name */}}
{{- define "whizard.compactor.crname" -}}
{{- print (include "whizard.fullname" .) }}
{{- end }}

{{/* Ruler custom resource instance name */}}
{{- define "whizard.ruler.crname" -}}
{{- print (include "whizard.fullname" .) }}
{{- end }}