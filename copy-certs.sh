#!/bin/bash

echo "Stopping apache webserver..."
sudo service apache2 stop
echo "Apache webserver stopped..."

echo "Renewing certificates..."
sudo certbot renew -n -q
echo "Certificates renewed..."

echo "Configuring certificates..."
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/fullchain.pem /home/ubuntu/inspircd-2.0.29/run/conf/cert.pem
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/privkey.pem /home/ubuntu/inspircd-2.0.29/run/conf/key.pem
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/chain.pem /home/ubuntu/inspircd-2.0.29/run/conf/ca.pem

sudo cp /etc/letsencrypt/live/irc.assimilate.dev/fullchain.pem /etc/ssl/certs/irc.assimilate.dev.crt
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/privkey.pem /etc/ssl/private/irc.assimilate.dev.key
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/chain.pem /etc/ssl/certs/ca-certificates.crt
echo "Certificates configured..."

echo "Restarting services..."
sudo service apache2 start
/home/ubuntu/inspircd-2.0.29/run/inspircd rehash
echo "Renewal complete..."
