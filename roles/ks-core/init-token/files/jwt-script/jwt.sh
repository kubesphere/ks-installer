#!/bin/bash

secret=$1

# Static header fields.
header='{
	"alg": "HS256",
	"typ": "JWT"
}'

# Use jq to set the dynamic `iat` and `exp`
# fields on the header using the current time.
# `iat` is set to now, and `exp` is now + 1 second.
# header=$(
# 	echo "${header}" | jq --arg time_str "$(date +%s)" \
# 	'
# 	($time_str | tonumber) as $time_num
# 	| .iat=$time_num
# 	| .exp=($time_num + 1)
# 	'
# )
# openpitrix {"sub": "system","role": "global_admin","iat": 1516239022,"exp": 1816239022}
# ks-account {"email": "admin@kubesphere.io","exp": 1816239022,"username": "admin"}
payload=$2

base64_encode()
{
	declare input=${1:-$(</dev/stdin)}
	# Use `tr` to URL encode the output from base64.
	printf '%s' "${input}" | base64 | tr -d '\n' | tr -d '=' | tr '/+' '_-'
}

json() {
	declare input=${1:-$(</dev/stdin)}
	printf '%s' "${input}" | jq -c .
}

hmacsha256_sign()
{
	declare input=${1:-$(</dev/stdin)}
	printf '%s' "${input}" | openssl sha256 -hmac "${secret}" -binary |  base64 | tr -d '\n' | tr -d '=' | tr '/+' '_-'
}

header_base64=$(echo "${header}" | json | base64_encode)
payload_base64=$(echo "${payload}" | json | base64_encode)

header_payload=$(echo "${header_base64}.${payload_base64}")
signature=$(echo "${header_payload}" | hmacsha256_sign)

echo "${header_payload}.${signature}"
