#! /bin/bash

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


os_info=`cat /etc/os-release`


if [[ $os_info =~ "Ubuntu" || $os_info =~ "Debian" ]]; then

    source ./os/ubuntu.sh
      
elif [[ $os_info =~ "CentOS" || $os_info =~ "Red Hat" ]]; then

    source ./os/centos7.sh

else
    echo "It doesn't support the current operating system!"
fi

python -V 2> /dev/null
if [[ $? -eq 0 ]]; then

    sudo python os/get-pip.py

    if [[ $os_info =~ "Ubuntu" || $os_info =~ "Debian" ]]; then

       pip install pyopenssl

    fi

    pip install -U --ignore-installed PyYAML
    pip install -r os/requirements.txt
else
    echo "please install python"
fi