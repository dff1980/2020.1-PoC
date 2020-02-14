for node in 01 02 03 04
 do
   scp wipe_disk.sh sles@worker-$node:/tmp/
   ssh sles@worker-$node 'sudo bash /tmp/wipe_disk.sh sdb sdc sdd'
   ssh sles@worker-$node 'rm /tmp/wipe_disk.sh'
   ssh sles@worker-$node 'sudo reboot'
   echo "sleep 10"
   sleep 10
   echo "wait while node boted"
   while ! ping worker-$node -c 1; do sleep 2; done
   echo "sleep 10"
   sleep 10
 done
