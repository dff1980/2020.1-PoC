# Demo Script
## 0. Prepare

1. Get kubectl config
2. Put config to .kube directory
3. Install kubernetes-client
4. Create Rook Toolbox 
```
kubectl create -f toolbox.yaml
watch kubectl -n rook-ceph get pod -l "app=rook-ceph-tools"    
```    

## 1. Demonstrate Kubernetes CLI
Demostrate cluster status:
On admin node:
```
cd caasp-cluster
skuba cluster status
```
```
kubectl get nodes
kubectl top nodes
kubectl get namespaces
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
6. Start pod interface and etc. (Create/delete pod nginx)

## 3. Demonstarte SES

1. Demostrate name spaces rook-ceph pods
```
kubectl -n rook-ceph exec $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath="{.items[0].metadata.name}") -- ceph osd status
```
```
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') bash
```
* ceph status
* ceph osd status
* ceph df
* rados df
2. (SES Dashboard)[https://172.17.149.48:32178/#/login] Password: Standart Test Password
3. Cluster,Pools,Block,Filesystems

## 4. Demostarte Stratos
1. (Web GUI)[https://stratos.cap.suse.ru:8443/]
2. App, CloudFoundry, Kubernetes, Endpoint

## 5. Demostrate kube
### Kubectl
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
30 sec demo
```
cat ingress.yaml | sed s/\$\$NAME/apple/ | kubectl create -f -
```
