#!/bin/bash

echo "Installing docker"
apk add --update docker
service docker start

echo "Installing gcloud and kubectl"
curl -sSL https://sdk.cloud.google.com | bash
PATH=$PATH:/root/google-cloud-sdk/bin
source /github/home/google-cloud-sdk/path.bash.inc
gcloud components install kubectl
kubectl version

echo "Getting kubeconfig file from GKE"
echo "${INPUT_GKEAPPLICATIONCREDENTIALS}" | base64 -d > /tmp/account.json
gcloud auth configure-docker
gcloud auth activate-service-account --key-file=/tmp/account.json
gcloud config set project $INPUT_GKEPROJECTID
gcloud container clusters get-credentials $INPUT_GKECLUSTERNAME --zone $INPUT_GKELOCATIONZONE --project $INPUT_GKEPROJECTID
export KUBECONFIG="$HOME/.kube/config"

echo "Getting the status of ${INPUT_PODNAMES}"
RESPONSE=$(echo kubectl get pods -n $INPUT_GKENAMESPACE)
echo $RESPONSE
IFS='/n'
read -ra LINES <<< "${RESPONSE}"
IFS=' '

for j in "${INPUT_PODNAMES[@]}"; do
    RUNNING="false"
    for i in "${LINES[@]}"; do
        # Check to see if this is the pod we want to check
        if [[ $1 == *"${j}"* ]]; then
            # Check to make sure the pod is running
            if [[ $1 == *"Running"* ]]; then
                RUNNING="true"
            fi
        fi
    done

    if [[ "${RUNNING}" == "true" ]]; then
        echo "${j} is running."
    else
        echo "${j} is not running!"
        exit 1
    fi
done

exit 0