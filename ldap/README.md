### Install 389 DS
```bash
zypper in docker
zypper in openldap2-client
mkdir /srv/389_ds_data

docker run -d \
-p 389:3389 \
-p 636:636 \
-e DS_DM_PASSWORD=suse1234 \
-e DS_SUFFIX="dc=example,dc=org" \
-v /srv/389_ds_data:/data \
--name 389-ds registry.suse.com/caasp/v4/389-ds:1.4.0
```

### Test in container environment (optional)
```bash
docker exec -it 389-ds bash
zypper in -y openldap2-client
zypper in vi
ldapsearch -x -H ldap://localhost:3389 -D "cn=Directory Manager" -w suse1234 -b dc="example,dc=org" -s sub "(objectclass=*)"
```
### Add user & group
```bash
ldapsearch -x -H ldap://localhost:389 -D "cn=Directory Manager" -w suse1234 -b dc="example,dc=org" -s sub "(objectclass=*)"
ldapadd -v -H ldap://localhost:389 -D "cn=Directory Manager" -w suse1234 -f geeko.ldif
ldapadd -v -H ldap://localhost:389 -D "cn=Directory Manager" -w suse1234 -f k8s-admins.ldif
```
??test.ldif??

### Edit config map
Example in ldap/oidc-dex-config
```bash
kubectl --namespace=kube-system edit configmap oidc-dex-config
```
or
```
kubectl apply -f dex-389-ds.yaml
```
```
kubectl --namespace=kube-system delete pod -l app=oidc-gangway
kubectl --namespace=kube-system delete pod -l app=oidc-dex
```

### Create Role Binding
```bash
kubectl create namespace ldapusers
kubectl create rolebinding admin --clusterrole=admin  --group=k8s-admins --namespace=ldapusers
```
### Get config
```bash
skuba auth login -k -s https://api.caasp.suse.ru:32000
```




### Remove 398 DS
```bash
docker stop 389-ds
docker rm 389-ds
rm -r /srv/389_ds_data/
```
### Appendix
https://directory.fedoraproject.org/docs/389ds/howto/howto-resetdirmgrpassword.html	

