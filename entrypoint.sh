#!/bin/bash

echo "Getting kubeconfig file from GKE"
echo "${INPUT_GKEAPPLICATIONCREDENTIALS}" | base64 -d > /tmp/account.json
gcloud components install kubectl
kubectl version
gcloud auth configure-docker
gcloud auth activate-service-account --key-file=/tmp/account.json
gcloud config set project $INPUT_GKEPROJECTID
gcloud container clusters get-credentials $INPUT_GKECLUSTERNAME --zone $INPUT_GKELOCATIONZONE --project production
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