#!/bin/bash

# Copyright 2018 The KubeSphere Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

BASE_FOLDER=$(dirname $(readlink -f "$0"))

registryurl="$1"
reposUrl=("quay.azk8s.cn" "gcr.azk8s.cn" "docker.elastic.co" "quay.io" "k8s.gcr.io")

#imagesinfo=$(sudo docker images | awk '{if (NR>1){print $1":"$2}}')

imagesinfo=$(cat ${BASE_FOLDER}/images-list-v3.0.0.txt)

if [[ "$1" != "" ]]
then

    for image in $(ls ${BASE_FOLDER}/*.tar); do
        sudo docker load  < $image
    done
    
    for image in $imagesinfo; do
        ## retag images
        url=${image%%/*}
        ImageName=${image#*/}
        echo $image
        
        if echo "${reposUrl[@]}" | grep -w "$url" &>/dev/null; then
              imageurl=$registryurl"/"${image#*/}
        elif [ $url == $registryurl ]; then
            if [[ $ImageName != */* ]]; then
                imageurl=$registryurl"/library/"$ImageName
            else
                imageurl=$image
            fi
        elif [ "$(echo $url | grep ':')" != "" ]; then
              imageurl=$registryurl"/library/"$image                  
        else
              imageurl=$registryurl"/"$image 
        fi  
    
        ## push image
        echo $imageurl
        docker tag $image $imageurl
        docker push $imageurl
     
    done
else
   echo "Please specify a images repo address."
fi

