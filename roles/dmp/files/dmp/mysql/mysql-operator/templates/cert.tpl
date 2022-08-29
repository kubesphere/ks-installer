{{- define "webhook.caBundleCertPEM" -}}
  {{- if .Values.webhook.caBundlePEM -}}
    {{- trim .Values.webhook.caBundlePEM -}}
  {{- else -}}
    {{- /* Generate ca with CN "radondb-ca" and 5 years validity duration if not exists in the current scope.*/ -}}
    {{- $caKeypair := .selfSignedCAKeypair | default (genCA "radondb-ca" 1825) -}}
    {{- $_ := set . "selfSignedCAKeypair" $caKeypair -}}
    {{- $caKeypair.Cert -}}
  {{- end -}}
{{- end -}}

{{- define "webhook.certPEM" -}}
  {{- if .Values.webhook.crtPEM -}}
    {{- trim .Values.webhook.crtPEM -}}
  {{- else -}}
    {{- $webhookDomain := printf "%s.%s.svc" (include "webhook.name" .) .Release.Namespace -}}
    {{- $webhookDomainLocal := printf "%s.%s.svc.cluster.local" (include "webhook.name" .) .Release.Namespace -}}
    {{- $webhookCA := required "self-signed CA keypair is requried" .selfSignedCAKeypair -}}
    {{- /* genSignedCert <CN> <IP> <DNS> <Validity duration> <CA> */ -}}
    {{- $webhookServerTLSKeypair := .webhookTLSKeypair | default (genSignedCert "radondb-mysql" nil (list $webhookDomain $webhookDomainLocal) 1825 $webhookCA) -}}
    {{- $_ := set . "webhookTLSKeypair" $webhookServerTLSKeypair -}}
    {{- $webhookServerTLSKeypair.Cert -}}
  {{- end -}}
{{- end -}}

{{- define "webhook.keyPEM" -}}
  {{- if .Values.webhook.keyPEM -}}
    {{ trim .Values.webhook.keyPEM }}
  {{- else -}}
    {{- $webhookDomain := printf "%s.%s.svc" (include "webhook.name" .) .Release.Namespace -}}
    {{- $webhookDomainLocal := printf "%s.%s.svc.cluster.local" (include "webhook.name" .) .Release.Namespace -}}
    {{- $webhookCA := required "self-signed CA keypair is requried" .selfSignedCAKeypair -}}
    {{- /* genSignedCert <CN> <IP> <DNS> <Validity duration> <CA> */ -}}
    {{- $webhookServerTLSKeypair := .webhookTLSKeypair | default (genSignedCert "radondb-mysql" nil (list $webhookDomain $webhookDomainLocal) 1825 $webhookCA) -}}
    {{- $_ := set . "webhookTLSKeypair" $webhookServerTLSKeypair -}}
    {{- $webhookServerTLSKeypair.Key -}}
  {{- end -}}
{{- end -}}
