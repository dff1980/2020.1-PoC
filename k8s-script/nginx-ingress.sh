kubectl create namespace nginx-ingress

helm install --name nginx-ingress suse/nginx-ingress \
--namespace nginx-ingress \
--values nginx-ingress-config-values.yaml

kubectl -n nginx-ingress get pod
