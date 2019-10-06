#!/bin/bash

echo "Configuring git"
git config --global url."https://${INPUT_GITUSERNAME}:${INPUT_GITACCESSTOKEN}@github.com".insteadOf "https://github.com"

echo "Installing docker"
apk add --update docker
service docker start

echo "Installing gcloud and kubectl"
curl -sSL https://sdk.cloud.google.com | bash
PATH=$PATH:/root/google-cloud-sdk/bin
source /github/home/google-cloud-sdk/path.bash.inc
gcloud components install kubectl
kubectl version

echo "Cloning ${GITHUB_REPOSITORY}"
git clone "https://github.com/${GITHUB_REPOSITORY}.git"
IFS='/'
read -ra ADDR <<< "${GITHUB_REPOSITORY}"
IDX=${#ADDR[@]}-1
REPONAME="${ADDR[${IDX}]}"
cd $REPONAME

echo "Getting kubeconfig file from GKE"
echo "${INPUT_GKEAPPLICATIONCREDENTIALS}" | base64 -d > /tmp/account.json
gcloud auth configure-docker
gcloud auth activate-service-account --key-file=/tmp/account.json
gcloud config set project $INPUT_GKEPROJECTID
gcloud container clusters get-credentials $INPUT_GKECLUSTERNAME --zone $INPUT_GKELOCATIONZONE --project $INPUT_GKEPROJECTID
export KUBECONFIG="$HOME/.kube/config"

echo "Getting the status of ${INPUT_PODNAME}"
kubectl get pods -n platform
RESPONSE=$(echo kubectl get pods -n $INPUT_GKENAMESPACE)
echo "Response: ${RESPONSE}"
IFS='/n'
read -ra LINES <<< "${RESPONSE}"
IFS=' '

RUNNING="false"
for i in "${LINES[@]}"; do
    # Check to see if this is the pod we want to check
    if [[ $1 == *"${INPUT_PODNAME}"* ]]; then
        # Check to make sure the pod is running
        if [[ $1 == *"Running"* ]]; then
            RUNNING="true"
        fi
    fi
done

if [[ "${RUNNING}" == "true" ]]; then
    echo "${INPUT_PODNAME} is running."
    exit 0
else
    echo "${INPUT_PODNAME} is not running!"
    exit 1
fi