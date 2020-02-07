# SUSE CaaS Platform 4 and SUSE Enterprise Storage 6 2020 PoC #1

This project is PoC hyper convergent installation SUSE CaaS Platform 4 and SUSE Enterprise Storage 6.

Using version:
- CaaS 4.1
- SES 6
- SLES 15 SP1

This document currently in development state. Any comments and additions are welcome.
If you need some additional information about it please contact with Pavel Zhukov (pavel.zhukov@suse.com).

###### Disclaimer
###### _At the moment, no one is responsible if you try to use the information below for productive installations or commercial purposes._

## PoC Landscape
PoC can be deployed in any virtualization environment or on hardware servers.
Currently, PoC hosted on VMware VSphere.

## Requarments

### Tech Specs
- 1 dedicated infrastructure server ( DNS, DHCP, PXE, NTP, NAT, SMT, TFTP, CaaS admin)
    
    4GB RAM
    
    1 x HDD - 200GB
    
    1 LAN adapter
    
    1 WAN adapter

- 5 x CaaSP Nodes
  
  - 1 x Master Node (Up to 5 worker nodes)
  
     4 GB RAM
  
     1 x HDD 100 GB (50 GB+)
  
     1 LAN (Minimum 1Gb/s)
  
  - 4 x Worker Node
    
     32 GB RAM
     
     4 x HDD 100 GB
     
     1 LAN

### Network Architecture
All server connect to LAN network (isolate from another world). In current state - 192.168.15.0/24.
Infrastructure server also connects to WAN.

## Install Router
You can use AutoYaST file to setup router and pre-configure Chrone, TFTP
Boot from SLES15 SP1 DVD.

On GRUB boot screen select install and press "e".

Add to kernel parameters (in line started linuxefi, after splash=silent):
```
netsetup=1 autoyast=https://raw.githubusercontent.com/dff1980/2020.1-PoC/master/autoyast/router.xml
```
press "F10"

## Configure Router
```
zypper in git-core
git clone https://github.com/dff1980/2020.1-PoC/
```
#### 1. Configure RMT.
```bash
sudo zypper in rmt-server
```
Execute RMT configuration wizard. During the server certificate setup, all possible DNS for this server has been added (RMT FQDN, etc).
```
yast rmt
```
Add repositories to replication.
```bash
./rmt-mirror.sh
rmt-cli mirror
```
#### 2. Get autoyast
```
autoyast.sh
```
#### 3. PXE boot loader (bios/EFI)
```
./tftp.sh
```
#### 4. Configure DHCPD
```
./dhcpd.sh
```
#### 5. Configure DNS
```
./named.sh
```
#### 6. Configure Firewall
```
./firewall.sh
```

### Deploy SUSE CaaS Platform
#### 1.
```
sudo SUSEConnect -p sle-module-containers/15.1/x86_64
sudo SUSEConnect -p caasp/4.0/x86_64 -r {Registarion Key}
sudo zypper in -t pattern SUSE-CaaSP-Management
```
#### 2.
Use PXE boot to install all nodes
Clear all unused HDD on worker Nodes

#### 3.
```
eval "$(ssh-agent)"
ssh-add ~/.ssh/id_rsa
skuba cluster init --control-plane caasp.local caasp-cluster
cd caasp-cluster
skuba node bootstrap --user sles --sudo --target master.caasp.local master
skuba node join --role worker --user sles --sudo --target worker-01.caasp.local worker-01
skuba node join --role worker --user sles --sudo --target worker-02.caasp.local worker-02
skuba node join --role worker --user sles --sudo --target worker-03.caasp.local worker-03
skuba node join --role worker --user sles --sudo --target worker-04.caasp.local worker-04
skuba cluster status
```
```
sudo zypper in kubernetes-client
mkdir -p ~/.kube
cp admin.conf ~/.kube/config
```
### Deploy SES
Wipe data on all non-system disk at all Worker Nodes
```
./wipe_OSD.sh
```
```
SUSEConnect --product ses/6/x86_64 -r {Registration Key}
zypper install rook-k8s-yaml
cp -r /usr/share/k8s-yaml /root/
cd /root/k8s-yaml/rook/ceph
kubectl apply -f common.yaml -f operator.yaml
kubectl get pods -n rook-ceph
kubectl apply -f cluster.yaml
kubectl get pods --namespace rook-ceph
```
Object Storage
```
kubectl create -f object.yaml
kubectl -n rook-ceph get pod -l app=rook-ceph-rgw
kubectl create -f object-user.yaml
```
Get credential
```
kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-my-user -o yaml | grep AccessKey | awk '{print $2}' | base64 --decode
kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-my-user -o yaml | grep SecretKey | awk '{print $2}' | base64 --decode
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
```
Set NodePort
```
kubectl -n rook-ceph edit service rook-ceph-mgr-dashboard
```
### Remove SES
```
kubectl delete -f object-user.yaml
kubectl delete -f object.yaml
kubectl delete -f cluster.yaml
kubectl delete -f operator.yaml
kubectl delete -f common.yaml
rm -rf /var/lib/rook
```

#### Appendix K8S Stuff
Unsecured Tiller Deployment
This will install Tiller without additional certificate security.
```
kubectl create serviceaccount --namespace kube-system tiller

kubectl create clusterrolebinding tiller \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:tiller

helm init \
    --tiller-image registry.suse.com/caasp/v4/helm-tiller:2.16.1 \
    --service-account tiller

helm repo add suse https://kubernetes-charts.suse.com
```

To uninstall tiller from a kubernetes cluster:
```
helm reset
```
To delete failed tiller from a kubernetes cluster:
```
helm reset --force
```

##### NGINX Ingress Controller
Configure and deploy NGINX ingress controller

NodePort: The services will be publicly exposed on each node of the cluster, including master nodes, at port 30443 for HTTPS.
```
# Enable the creation of pod security policy
podSecurityPolicy:
  enabled: false

# Create a specific service account
serviceAccount:
  create: true
  name: nginx-ingress

# Publish services on port HTTPS/30443
# These services are exposed on each node
controller:
  service:
    enableHttp: false
    type: NodePort
    nodePorts:
      https: 30443
```
Deploy the helm chart from the $suse charts repository and pass along our configuration values file.
```
kubectl create namespace nginx-ingress

helm install --name nginx-ingress suse/nginx-ingress \
--namespace nginx-ingress \
--values nginx-ingress-config-values.yaml
```
The result should be two running pods:
```
kubectl -n nginx-ingress get pod
```
##### Dashboard
```
helm install stable/kubernetes-dashboard --namespace=kube-system --name=kubernetes-dashboard
```
Create Service Account
```
kubectl apply -f admin-user.yaml
```
Get token
```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```
kubectl proxy
Go Dashboard. If "Not Found (404)" at login fast select some menu items.

Delete Dashboard
```
helm delete --purge kubernetes-dashboard
```
#### Appendix Node port
Set NodePort
```
kubectl -n rook-ceph edit service rook-ceph-mgr-dashboard
```
### Appendix firewalld Node port
```
firewall-cmd --list-all --zone=external
firewall-cmd --permanent --zone=external --add-masquerade
firewall-cmd --permanent --zone=external --add-forward-port=port=30000-40000:proto=tcp:toaddr=192.168.17.10
firewall-cmd --reload
firewall-cmd --list-all --zone=external
```

#######
delete nginx-ingress
```
helm delete nginx-ingress --purge
```

kubectl describe SomeThing


NOTES:
The nginx-ingress controller has been installed.
Get the application URL by running these commands:
  export HTTP_NODE_PORT=30080
  export HTTPS_NODE_PORT=30443
  export NODE_IP=$(kubectl --namespace nginx-ingress get nodes -o jsonpath="{.items[0].status.addresses[1].address}")

  echo "Visit http://$NODE_IP:$HTTP_NODE_PORT to access your application via HTTP."
  echo "Visit https://$NODE_IP:$HTTPS_NODE_PORT to access your application via HTTPS."

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls


kubectl get ingress --all-namespaces

