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

export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"


os_info=`cat /etc/os-release`

if [[ $os_info =~ "Red Hat" ]]; then
	sudo rpm -ivh os/epel-release-7-12.noarch.rpm
else
	sudo yum install epel-release -y
fi

python -V
if [[ $? -eq 0 ]]; then
	echo "python is exits"
else
	sudo yum install python -y
	if [[ $? -eq 0 ]]; then
		echo "python is exits"
	else
		sudo yum install python2 -y
		if [[ $? -eq 0 ]]; then
			echo "python2 is exits"
			ln -s /usr/bin/python2 /usr/bin/python
	    else 
	    	echo "Yum source unavailable ,please check yum source"
	    fi
	fi

fi

sudo yum install sshpass -y



