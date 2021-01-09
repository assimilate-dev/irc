#!/bin/bash

sudo service apache2 stop
sudo certbot renew -n -q

sudo cp /etc/letsencrypt/live/irc.assimilate.dev/fullchain.pem /home/ubuntu/inspircd-2.0.29/run/conf/cert.pem
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/privkey.pem /home/ubuntu/inspircd-2.0.29/run/conf/key.pem
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/chain.pem /home/ubuntu/inspircd-2.0.29/run/conf/ca.pem

sudo cp /etc/letsencrypt/live/irc.assimilate.dev/fullchain.pem /etc/ssl/certs/irc.assimilate.dev.crt
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/privkey.pem /etc/ssl/private/irc.assimilate.dev.key
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/chain.pem /etc/ssl/certs/ca-certificates.crt

sudo service apache2 start
/home/ubuntu/inspircd-2.0.29/run/inspircd start
/home/ubuntu/inspircd-2.0.29/run/services/bin/anoperc start
