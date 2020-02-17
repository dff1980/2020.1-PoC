# Demo Script
## 0. Prepare

1. Get kubectl config
2. Put config to .kube directory
3. Install kubernetes-client, cf-cli

## 1. Demonstrate Kubernetes CLI
Demostrate cluster status:
```
kubectl get nodes
kubectl get pods --all-namespaces
```
## 2. Demonstrate Kubernates Dashboard
Start kubectl proxy
```
kubectl proxy --port 8001
```
Go to (Local host proxy dashboard link)[http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login]
Get Token
```
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```
Demonstrate:
1. Cluster status
2. Name space Overview
3. Pod status
4. Pod log
5. Container shell
6. Start pod interface and etc.

## 3. Demonstarte SES

1. Demostrate name spaces rook-ceph pods
2. (SES Dashboard)[https://172.17.149.48:32178/#/login] Password:
'''
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
'''
3. Cluster,Pools,Block,Filesystems

## 4. Demostarte CF Dashboard
1. (Web GUI)[https://stratos.cap.suse.ru:8443/]
2. App, CloudFoundry, Kubernetes, Endpoint
3. Push github application (dff1980/dizzylizard

## 5. Demostrate kube, cf cli
1. Helm's commands interface
```bash
cd microservices-demo
kubectl create namespace shop
helm install suse-shop --namespace shop
```
Demonstrate Web from kubectl proxy.
```bash
kubectl apply -f ingress.yaml -n shop
```
Demonstrate 2, and more Shop in different namespaces.
```bash
kubectl delete namespaces shop
```
