## CA
{{- define "tls.ca" -}}
  {{- /* Generate ca with CN "radondb-ca" and 5 years validity duration if not exists in the current scope.*/ -}}
  {{- $caKeypair := genCA "radondb-ca" 1825 -}}
  {{- $_ := set . "selfSignedCAKeypair" $caKeypair -}}
  {{- $caKeypair.Cert -}}
{{- end -}}
## Server
{{- define "server.certPEM" -}}
  {{- $CA := required "self-signed CA keypair is requried" .selfSignedCAKeypair -}}
  {{- /* genSignedCert <CN> <IP> <DNS> <Validity duration> <CA> */ -}}
  {{- $ServerTLSKeypair := genSignedCert "radondb-mysql-server" nil nil 1825 $CA -}}
  {{- $_ := set . "serverTLSKeypair" $ServerTLSKeypair -}}
  {{- $ServerTLSKeypair.Cert -}}
{{- end -}}
{{- define "server.keyPEM" -}}
    {{- .serverTLSKeypair.Key -}}
{{- end -}}
## Client
{{- define "client.certPEM" -}}
  {{- $CA := required "self-signed CA keypair is requried" .selfSignedCAKeypair -}}
  {{- /* genSignedCert <CN> <IP> <DNS> <Validity duration> <CA> */ -}}
  {{- $ClientTLSKeypair := genSignedCert "radondb-mysql-client" nil nil 1825 $CA -}}
  {{- $_ := set . "clientTLSKeypair" $ClientTLSKeypair -}}
  {{- $ClientTLSKeypair.Cert -}}
{{- end -}}
{{- define "client.keyPEM" -}}
    {{- .clientTLSKeypair.Key -}}
{{- end -}}

