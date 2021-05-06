#!/bin/bash
GREEN_COL="\\033[32;1m"
RED_COL="\\033[1;31m"
YELLOW_COL="\\033[33;1m"
NORMAL_COL="\\033[0;39m"

IMAGES_LIST=$1
SOURCE_REGISTRY=$2
TARGET_REGISTRY=$3
: ${IMAGES_LIST:="images-list.txt"}
: ${TARGET_REGISTRY:="localhost"}
: ${SOURCE_REGISTRY:="docker.io"}

set -eo pipefail

skopeo_copy() {
    if skopeo copy --insecure-policy --src-tls-verify=false --dest-tls-verify=false -q docker://$1 docker://$2; then
        echo -e "$GREEN_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 successful $NORMAL_COL"
    else
        echo -e "$RED_COL Sync $1 failed $NORMAL_CO"
    fi
}

CURRENT_NUM=0
TOTAL_NUMS=$(sed -n '/#/d;s/:/:/p' ${IMAGES_LIST} | wc -l)
for image in $(sed -n '/#/d;s/:/:/p' ${IMAGES_LIST}); do
    let CURRENT_NUM=${CURRENT_NUM}+1
    skopeo_copy ${SOURCE_REGISTRY}/${image} ${TARGET_REGISTRY}/${image}
done
