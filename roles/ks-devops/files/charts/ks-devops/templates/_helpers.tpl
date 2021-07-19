{{/*
Expand the name of the chart.
*/}}
{{- define "ks-devops.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ks-devops.fullname" -}}
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
{{- define "ks-devops.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels for apiserver
*/}}
{{- define "ks-devops-apiserver.labels" -}}
helm.sh/chart: {{ include "ks-devops.chart" . }}
{{ include "ks-devops-apiserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for apiserver
*/}}
{{- define "ks-devops-apiserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ks-devops.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
devops.kubesphere.io/component: apiserver
{{- end }}

{{/*
Common labels for controller
*/}}
{{- define "ks-devops-controller.labels" -}}
helm.sh/chart: {{ include "ks-devops.chart" . }}
{{ include "ks-devops-controller.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for controller
*/}}
{{- define "ks-devops-controller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ks-devops.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
devops.kubesphere.io/component: controller
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ks-devops.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ks-devops.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
