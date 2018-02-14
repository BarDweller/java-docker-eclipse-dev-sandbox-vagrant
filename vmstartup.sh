#!/bin/bash
cd ~/reactive-code-workshop
git checkout master >> ~/.workshop-log.txt
git fetch --all >> ~/.workshop-log.txt
git reset --hard origin/master >> ~/.workshop-log.txt
chmod +x ~/reactive-code-workshop/scripts/vmstartup.sh >> ~/.workshop-log.txt
/bin/bash ~/reactive-code-workshop/scripts/vmstartup.sh
