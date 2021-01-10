#!/bin/bash

echo "****** Getting latest for" ${repo} "******"
cd /home/ubuntu/inspircd-2.0.29/run
git pull --rebase
echo "******************************************"
