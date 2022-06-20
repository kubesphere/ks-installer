#!/bin/bash
URL="http://172.20.100.7"
IP="172.20.100.7"
USER="admin"
PASSWD="Harbor12345"
#Directory where the backup images
BACKUP_DIR="/mnt"
#The path of images_pull.lists file
IMAGES_LIST_FILE_PATH="$(eval echo ~$user)"
#The script will automatically check whether the target harbor contains the project in images_pull.lists. If it doesn't exists, it will automatically create the project and default type is public.
PROJECT_PUBLIC="true"
#Load images to local system.
for image in `ls -l $BACKUP_DIR|awk '{print $9}'`;do docker load < $BACKUP_DIR/$image;done

#Clear docker_pull.lists contents every time it is executed
if [ -f "$IMAGES_LIST_FILE_PATH/images_push.lists" ]; then
  rm -f "$IMAGES_LIST_FILE_PATH/images_push.lists"
fi

#Search current project with images.
REPOS=$(cat $IMAGES_LIST_FILE_PATH/images_pull.lists | awk -F '/' '{ print $2}'|sort|uniq)
#Search target all project.
PROJECTS=$(curl -u "${USER}:${PASSWD}" -X GET -H 'accept: application/json' "${URL}/api/v2.0/projects?&page_size=0"|sed 's/,/\n/g'|grep -w name|awk -F '"' '{print $4}')
for repo in ${REPOS}
do
	#Search current project in target harbor projects, create project when current project doesn't exist in target harbor
	repo_search=$(echo ${PROJECTS}|grep -wo "${repo}")
   if [ "${repo_search}" != "${repo}" ]; then
	   echo "creating ${repo}" && curl -u "${USER}:${PASSWD}" -X POST -H "Content-Type: application/json" "${URL}/api/v2.0/projects" -d "{ \"project_name\": \"${repo}\", \"public\": $PROJECT_PUBLIC }"
   fi
   done
#login harbor, if login failed, exit shell.
LOGIN_INFO=$(echo "${PASSWD}" | docker login ${IP} -u${USER} --password-stdin | grep -wo "Succeeded")
if [ "${LOGIN_INFO}" != "Succeeded" ]; then exit; fi
#list images from the file of docker_pull.lists, Re-tag and push to target harbor.
for image_list in $(cat $IMAGES_LIST_FILE_PATH/images_pull.lists|sed 's/ /\n/g')
do
	IMAGES_REPO=$(echo $image_list | awk -F '/' '{ print $2}'|sort|uniq)
	TAG=$(echo $image_list | awk -F '/' '{ print $3}' |sort|uniq)
        docker tag $image_list ${IP}"/"${IMAGES_REPO}"/"${TAG}
        docker push ${IP}"/"${IMAGES_REPO}"/"${TAG} |tee -a $IMAGES_LIST_FILE_PATH/images_push.lists
done
