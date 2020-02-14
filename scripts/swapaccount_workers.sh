for node in 01 02 03 04
 do
   scp swapaccount.sh sles@worker-$node:/tmp/
   ssh sles@worker-$node 'sudo bash /tmp/swapaccount.sh'
   echo "sleep 10"
   sleep 10
   echo "wait while node boted"
   while ! ping worker-$node -c 1; do sleep 2; done
   echo "sleep 10"
   sleep 10
 done
