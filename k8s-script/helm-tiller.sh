#!/bin/sh
sudo zypper install -y helm

kubectl create serviceaccount --namespace kube-system tiller

kubectl create clusterrolebinding tiller \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:tiller

helm init \
    --tiller-image registry.suse.com/caasp/v4/helm-tiller:2.16.1 \
    --service-account tiller

helm repo add suse https://kubernetes-charts.suse.com
