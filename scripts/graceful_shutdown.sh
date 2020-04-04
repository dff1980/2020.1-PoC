#!/bin/bash
kubectl get nodes -o name | xargs -I{} kubectl cordon {}

for node in 01 02 03 04
 do
   systemctl stop kubelet crio
   scp unmount_rbd.sh sles@worker-$node:/tmp/
   ssh sles@worker-$node 'sudo bash /tmp/unmount_rbd.sh'
   ssh sles@worker-$node 'rm /tmp/unmount_rbd.sh'
 done


for node in 01 02 03 04
 do
   ssh sles@worker-$node 'sudo systemctl poweroff'
 done

ssh sles@master 'sudo systemctl poweroff'

