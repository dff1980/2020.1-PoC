#!/bin/bash
date
ssh sles@master.caasp.suse.ru date
for i in 1 2 3 4
do
ssh sles@worker-0$i date
done
chronyc sources | tail -1
ssh sles@master.caasp.suse.ru chronyc sources | tail -1
for i in 1 2 3 4
do
ssh sles@worker-0$i chronyc sources | tail -1
done
