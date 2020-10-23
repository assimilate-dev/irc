#!/bin/bash
sudo cp /home/ubuntu/inspircd-2.0.29/run/apache-conf/index.html /var/www/html/index.html
sudo cp /home/ubuntu/inspircd-2.0.29/run/apache-conf/000-default.conf /etc/apache2/sites-available/000-default.conf
sudo cp /home/ubuntu/inspircd-2.0.29/run/apache-conf/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
sudo service apache2 reload
