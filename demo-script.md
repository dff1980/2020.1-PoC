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
```
kubectl -n rook-ceph exec $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath="{.items[0].metadata.name}") -- ceph osd status
```
2. (SES Dashboard)[https://172.17.149.48:32178/#/login] Password: Standart Test Password
3. Cluster,Pools,Block,Filesystems

## 4. Demostarte CF Dashboard
1. (Web GUI)[https://stratos.cap.suse.ru:8443/]
2. App, CloudFoundry, Kubernetes, Endpoint
3. Push github application (dff1980/dizzylizard

## 5. Demostrate kube, cf cli
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
### CF-cli
```
cf login --skip-ssl-validation -a https://api.cap.suse.ru -u admin
```
#### 1. 30 sec demo.
```
mkdir my-php-app
cd my-php-app
cat << EOF > index.php
<?php
  phpinfo();
?> 
EOF
cf push my-php-app-pzhukov -m 128M
``` 
Open app in web-browser.
#### 2. Explain what happened (buildpack, routes)
```
cf buildpacks
cf apps
cf routes
```
#### 3. Simple Python Web app
```
cd 2020.1-PoC/demo-scripts/cf/02-web-app
cf push
cf app web-app
```
Review manifest
Go to Web-browser open app
Review the App in Startos
#### 4. Debug Worker App (Ruby)
```
cd 2020.1-PoC/demo-scripts/cf/03-worker-app-rb
cf push
cf logs work-app-rb
cf logs work-app-rb --recent

```
```
cf events work-app-rb
```
```
cf ssh work-app-rb
cd /app
ls
cat periodic_logger.rb
```
Review the App in Startos
Show ssh and log screen
Show firehouse (in local Startos)
--ping router, talk about gate and router.
#### 5. Scale App
```
cd 2020.1-PoC/demo-scripts/cf/04-imperfect-app/
cf push
```
horizontal scale
```
cf scale imperfect-app -i 4
cf app imperfect-app
```
vertical scale
```
cf scale imperfect-app -k 350M -m 35M -f
cf app imperfect-app
```
Scale the App With Stratos.
Show autorecovery when app fail. (push to button "Crash me" some time and show result on Stratos and recovered app).
Show Autoscale.
#### 6. Blue - Green deployment
```
cd 2020.1-PoC/demo-scripts/cf/05-web-app-blue-green
cf push -f mod-manifest.yml
```
Edite version and scale count in web-app.py
Edite version in mod-manifest.yml
```
cf push -f mod-manifest.yml
```
Refresh some time web-app and show 2 version worked at the same time.
Scale out version 1 scale in version 2.

#### 7. Statefull App
```
cd 2020.1-PoC/demo-scripts/cf/07-cf-redis-example-app
cf push --no-start
cf marketplace
cf create-service redis 5-0-7 redis
cf service redis
watch cf service redis
cf bind-service redis-example-app redis
cf start redis-example-app
```
Show app in web-browser
Start some instace, and show web app change.

#### 8. Debug App
```
cd 2020.1-PoC/demo-scripts/cf/06-debug-app/
cf push
cf logs debug-app --recent
cf events debug-app
cf set-env debug-app FIXED True
cf restart debug-app
cf logs debug-app --recent
cf ssh debug-app
env
exit
cf apps
cf delete debug-app
```
#### 9. Debug Worker App (Ruby ENV)
```
cd 2020.1-PoC/demo-scripts/cf/03-worker-app-rb
cf push
cf logs work-app-rb
cf logs work-app-rb --recent

```
```
cf events work-app-rb
```
```
cf ssh work-app-rb
cd /app
ls
cat periodic_logger.rb
```
```
cf set-env work-app-rb OUTPUT_TEXT stable
```
Or set enviroment in Stratos
```
cf restart work-app-rb
```
Or
```
cf restage work-app-rb
```

Review the App in Startos
Show ssh and log screen
Show firehouse (in local Startos)
