#!/bin/bash

sudo certbot renew -n -q --webroot
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/fullchain.pem /home/ubuntu/inspircd-2.0.29/run/conf/cert.pem
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/fullchain.pem /etc/ssl/certs/irc.assimilate.dev.crt

sudo chown ubuntu:ubuntu /home/ubuntu/inspircd-2.0.29/run/conf/*
sudo chown ubuntu:ubuntu /etc/ssl/certs/*

/home/ubuntu/inspircd-2.0.29/run/inspircd rehash
sudo service apache2 reload
