#!/bin/bash

URL="http://172.20.100.8"
IP="172.20.100.8"
USER="admin"
PASSWD="Zcx123Zcx123"
#The directory where the backup image resides must be created in advance, default directory is /mnt.
BACKUP_DIR="/mnt"
#The list file path for pulling the image. Default is the current user path,eg: ~/images_pull.lists
IMAGES_LIST_FILE_PATH="$(eval echo ~$user)"
#Enter your harbor project name that you want to backup. if it's default(null),we will backup all projects with images. eg: a,b,c
PULL_PROJECTS="jvm,ianzeng"

#list all projects
#PROJECTS=$(curl -u "${USER}:${PASSWD}" -X GET -H 'accept: application/json' "${URL}/api/v2.0/projects?&page_size=0"|sed 's/,/\n/g'|grep -w name|awk -F '"' '{print $4}')

#list all images
#IMAGES=$(curl -u "${USER}:${PASSWD}" -s -X GET -H 'accept: application/json' "${URL}/api/v2.0/repositories?&page_size=0"|sed 's/,/\n/g'|grep "name"|awk -F '"' '{print $4}')

#Clear docker_pull.lists contents every time it is executed
if [ -f "$IMAGES_LIST_FILE_PATH/images_pull.lists" ]; then
  rm -f "$IMAGES_LIST_FILE_PATH/images_pull.lists"
fi
#list the project with images
PROJECTS=$(curl -u "${USER}:${PASSWD}" -X GET -H 'accept: application/json' "${URL}/api/v2.0/repositories?&page_size=0"|sed 's/,/\n/g'|grep -w name|awk -F '"' '{print $4}'|sort -r | awk -F "/" '{print $1}'|uniq)

#login harbor, if login failed, exit shell.
LOGIN_INFO=$(echo "${PASSWD}" | docker login ${IP} -u${USER} --password-stdin | grep -wo "Succeeded")
if [ "${LOGIN_INFO}" != "Succeeded" ]; then exit; fi
#If the PULL_PROJECTS env is not null, update it to PROJECTS env.
if [ "${PULL_PROJECTS}" != "" ]; then
	PROJECTS=$(echo $PULL_PROJECTS|sed 's/,/\n/g')
  fi
#Match each project with images and backup to local.
for repo in ${PROJECTS}
do
  #list images in project
  IMAGES=$(curl -u "${USER}:${PASSWD}" -X GET -H 'accept: application/json' "${URL}/api/v2.0/projects/${repo}/repositories?&page_size=0"|sed 's/,/\n/g'|grep -w name|awk -F '"' '{print $4}'|awk -F "/" '{print $2}')
  #get current image all tag
  for image in ${IMAGES}
  do
	  TAGS=$(curl -u "${USER}:${PASSWD}" -s -X GET -H 'accept: application/json' "${URL}/api/v2.0/projects/${repo}/repositories/${image}/artifacts" |sed 's/,/\n/g'|grep \"name\"|awk -F '"' '{print $4=$(/ /)}'|awk -F '"' '{print $4}')
    for tag in ${TAGS}
    do
        docker pull ${IP}"/"${repo}"/"${image}":"${tag}
        echo ${IP}"/"${repo}"/"${image}":"${tag} >> $IMAGES_LIST_FILE_PATH/images_pull.lists
        docker save ${IP}"/"${repo}"/"${image}":"${tag} > ${BACKUP_DIR}/${IP}-${repo}-${image}-${tag}.tar.gz
    done
  done
done
echo "==============Images backup is completed!!==============="

