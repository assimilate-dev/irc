# [irc.assimilate.dev](https://irc.assimilate.dev/)
The IRC server is setup and running. I'm currently using Hexchat to connect on my Windows workstation. If you logon and register a nickname you can use SASL to assume your nick on login.

![Hexchat Config](https://mrt-public.s3-us-west-2.amazonaws.com/hexchat.PNG)

Big thanks to the guide at [JamieWeb](https://www.jamieweb.net/blog/inspircd-linux-guide/). As usual, there were slight differences in OS and versions which made things difficult. I'll do my best to call those out below.

If you see any differences or updates that I need to make please feel free to submit a pull request on the README at [assimilate-dev/irc](https://github.com/assimilate-dev/irc).



## Amazon Lightsail

### Instance Type

I know that serverless is the way but for this project we need an always-on server. I chose AWS Lightsail which seems to be a user-friendly interface on top of already-existing EC2 functionality. I went with the $3.50 price-per-month instance: Linux/Unix - OS Only - Ubuntu 18.04. So far it has performed well with absolutely zero issues.

When you are creating the instance it is easy to miss the keypair option. I created a new keypair named *irc* and downloaded the file which will be super important later.



### Networking

Your Lightsail instance will begin with a set of defaults for port forwarding. You shouldn't leave SSH access open to any IP but I don't have a static IP so I toggle this option on and off as needed. I also have a static website setup at [irc.assimilate.dev](https://irc.assimilate.dev) so I have opened 80 and 443. IRC will run on 6660-6669 and 6697; the later for SSL.

| Application | Protocol | Port      | Restricted To |
| ----------- | -------- | --------- | ------------- |
| SSH         | TCP      | 22        | Any IP        |
| HTTP        | TCP      | 80        | Any IP        |
| HTTPS       | TCP      | 443       | Any IP        |
| Custom      | TCP      | 6660-6669 | Any IP        |
| Custom      | TCP      | 6697      | Any IP        |



### Static IP and DNS

Lightsail makes it easy to attach a static IP to your instance. Do that.



![Static IP Example](https://mrt-public.s3-us-west-2.amazonaws.com/static_ip.PNG)



I purchased my domain via Google Domains because they had the *.dev* top-level domain and that seemed pretty cool. Once I purchased *assimilate.dev* at Google Domains, I switched back to the Lightsail web interface and clicked "Create DNS Zone." The options are simple and self-explanatory. After it is created, you are provided a list of name servers.



![Google Name Servers](https://mrt-public.s3-us-west-2.amazonaws.com/google_name_servers.PNG)



Switch back over to the Google Domain web interface where the domain was purchased. Under the DNS section, remove the existing name servers and add the ones that Lightsail provided.



![Amazon Name Servers](https://mrt-public.s3-us-west-2.amazonaws.com/amazon_name_servers.PNG)



Once you've removed the old name servers and added the Lightsail name servers, you're done with the Google Domain interface. Back in Lightsail, I added an A record for irc.assimilate.dev resolving to the static IP that I obtained from Lightsail.



### SSH

Now that your server is setup you can install and configure IRC. To access your server you can use SSH in one of two ways. Lightsail makes it easy with a big orange button that says "Connect using SSH." This will allow you to connect via a web browser.



![Amazon Name Servers](https://mrt-public.s3-us-west-2.amazonaws.com/ssh.PNG)



This method is convenient but it does make it kind of a pain to copy/paste text so I still like to connect with SSH in a terminal. From the Windows command line:

```ssh 
ssh -i irc.pem ubuntu@irc.assimilate.dev
```

You'll need to provide the correct path to your *.pem* file. If you aren't running the command above from the directory where the file is saved then provide the proper path to your _.pem_ file.



## Initial Setup

For the most part I followed the instructions on JamieWeb with a few minor additions. I'll elaborate on those as they are relevant but a significant amount of this guide is based on the JamieWeb page.

I am installing InspIRCd version 2.0.29. I was originally going to go with a 3+ version but I immediately ran into issues installing a MariaDB package on both Ubuntu 20 and 18 and became too frustrated to continue troubleshooting.

I didn't create a new, unprivileged user for installation. I just used the _ubuntu_ user that is provided with the Lightsail instance. Maybe someone who is more security-minded can tell me why this is bad.

The first group of dependencies were recommended in [this guide](https://ubuntu.com/tutorials/irc-server#2-dependencies). I honestly don't know if they are essential but I installed them anyway.

The second group of dependencies is from JamieWeb but `libgnutl-dev` didn't work so I [changed it](https://askubuntu.com/questions/1058694/libgnutls-dev-has-no-installation-candidate-error-while-installing-ubuntu-as-a) to `libgnutls28-dev` instead which did the trick.

```
sudo apt-get update
sudo apt-get install perl g++ make
sudo apt-get install libgnutls28-dev gnutls-bin pkg-config
```

I also installed [irssi](https://irssi.org/) as a client for testing my server:

```
sudo apt-get install irssi
```

Download the package, extract it, and configure by following the wizard. During the interactive wizard, I chose `y` for SSL with `gnutls` and `n` for SSL with `openssl`.

```
https://github.com/inspircd/inspircd/archive/v2.0.29.tar.gz
tar xvf v2.0.29.tar.gz
cd inspircd-2.0.29
./configure
```

The wizard will tell you if there is a problem with your SSL packages. I chose `y` to check for updates to third-party modules.

I chose `y` when asked if I wanted to generate SSL certificates though my SSL connections never worked until I went through the Let's Encrypt section.

If you make it through the wizard without any cryptic error messages congratulations! Run `make` and then after that finishes run `make install`. If you ever need to redo the configuration wizard it seems safe to do that. I did it several times before I got everything working.

Once this is complete you can start your server and check that it is actually running.

```
./inspircd start
./inspircd status
```

Try to log in to your server.

```
irssi
/connect irc.assimilate.dev 6660 uselesspassword mike
```

If this works, take a breather. I won't say the hard part is over but you've accomplished something!



## Configuration Files

I'm not going to go super in-depth on the configuration files because the example files located in the `docs/conf` and/or `run/conf/examples` folder have a lot of great comments to guide you. Plus, I have my configuration files checked in to the repository so you can check those for reference.

Move the standard configuration files from the examples directory and into the run directory.

```
cp docs/conf/inspircd.conf.example run/conf/inspircd.conf
cp docs/conf/modules.conf.example run/conf/modules.conf
cp docs/conf/opers.conf.example run/conf/opers.conf

cp docs/conf/motd.txt.example run/conf/motd.txt
```

You'll have to go through each of these files yourself and read the commented sections because the InspIRCd team left some config in there that will keep your server from starting and/or send embarrassing messages.

Read through, follow the instructions, uncomment/change the bare minimum for now, and reference my configuration files as an example. You got this. I believe in you.



### Secrets

Some configuration files ask you to specify passwords. It's never a good idea to store a password in plain text. It is recommended to hash them using `mkpasswd`. However hashing won't work on your server until you enable certain a few modules:

- m_md5.so

- m_sha256.so

- m_password_hash.so

Most of the time enabling modules is easy. Just uncomment them in the modules file and they will load when you reload InspIRCd.

```
nano run/conf/modules.conf
```

Once you're inside the modules file, find the lines for the appropriate modules and uncomment them. Restart your server and password hashing will work. Run the commands below to restart your server, connect, and use IRC to generate a hashed password.

```
./inspircd restart
irssi
/connect irc.assimilate.dev 6660
/quote mkpassword hmac-sha256 apasswordyouwanthashed
```

Once you have the hash, you can replace your plaintext passwords with the hashed password in the configuration.

```
<oper
       name="operloginname"
       hash="hmac-sha256"
       password="iaH8n2$thelonghashyougotfrommkpasswd"
       host="*"
       type="NetAdmin">
```

Once this is done you should be able to login from a client like irssi.

```
/oper operloginname apasswordyouwanthashed
```

Even though my passwords are hashed, I still store them in a separate file that is not checked in to source control. You can arrange your configuration files any which way you like and include configuration in other files by placing an an include block in *inspircd.conf*.

```
<include file="conf/secrets.conf">
```

I put all of my blocks containing secrets into one file, *secrets.conf*, which I left out of source control. I [checked-in an example](https://github.com/assimilate-dev/irc/blob/main/conf/secrets.example.conf) of that file for you to see.

You can (and should) use this password hashing business to set a password for the `DIE` and `RESTART` commands in the power block of your configuration.



### Modules

I am not going to go in-depth on configuring specific modules because otherwise this document would be considerably longer. If you have questions about specific modules, feel free to ask. On my very small server I enabled the following during the initial setup:

- m_md5.so
- m_sha256.so
- m_blockcaps.so
- m_cloaking.so
- m_conn_join.so
- m_conn_umodes.so
- m_lockserv.so
- m_messageflood.so
- m_operprefix.so
- m_password_hash.so
- m_permchannels.so



## SSL Certificates

I was dreading SSL certificates. I thought I was going to have to pay money either through AWS or some other certificate authority. Turns out you can do it all for free through [Let's Encrypt using certbot](https://certbot.eff.org/lets-encrypt/ubuntubionic-other). I followed the instructions for my setup and OS exactly, choosing the standalone option since (at the time) I didn't have a webserver running on the machine.

```
sudo certbot certonly --standalone
```

Certbot places your certificate files in the `/etc/letsencrypt/live/<your_server>/` directory. These can be copied into various locations as needed for InspIRCd as well as Apache (later on in this document).

Check my [*inspircd.conf*](https://github.com/assimilate-dev/irc/blob/main/conf/inspircd.conf) file for ssl-specific setup paying close attention to the  gnutls and bind blocks.

```
<gnutls cafile="conf/ca.pem"
        certfile="conf/cert.pem"
        keyfile="conf/key.pem">

...

<bind
      address=""
      port="6697"
      type="clients"
      ssl="gnutls">
```

There are also modules that you will need to enable by uncommenting them in [*modules.conf*](https://github.com/assimilate-dev/irc/blob/main/conf/modules.conf). I honestly can't remember which ones I enabled for SSL. Spend some time reading through the helpful comments in `docs/conf/modules.conf.example` and taking a look at the modules I have uncommented in my module file.

At the very least, I enabled the following:

- m_ssl_gnutls.so
- m_cap.so

You should know that the file naming is a little weird so here is the mapping:

- fullchain.pem -> certfile
- privkey.pem -> keyfile
- chain.pem -> cafile



## Anope Services

If you want to be able to register nicknames and channels with Nickserv and Chanserv, you need a services provider. I chose the latest release of [Anope](https://www.anope.org/) because it was there and I found what looked like a decent guide. Just like before, the vast majority of this guide comes copy/pasted from [another source](https://www.howtoforge.com/tutorial/how-to-build-your-own-irc-server-with-inspircd-and-anope/#step-install-and-configure-anope-services) and I will provide my commentary where relevant.



### Initial Setup

I installed these services on the same server that is running IRC. I dropped all the downloads in my home folder alongside the initial files I downloaded for InspIRCd.

```
wget https://github.com/anope/anope/archive/2.0.8.tar.gz
tar -xzvf 2.0.8.tar.gz
```

Once that is complete you can run the configuration. The one thing I changed in the configuration was the directory where Anope is installed. When I setup InspIRCd I set the run folder as the root for my git repository. Since I was looking to keep the configuration files for Anope sourced in the same repo I changed the installed directory to `~/inspircd-2.0.29/run/services/`.

```
cd anope-2.0.8/
./Config
```

Once the configuration is complete you need to go to the build directory to install. The build directory will be in the directory where you ran the configuration, not the installed directory you indicated during the configuration.

```
cd build/
make
make install
```



### Configuration

You can do some cleanup and make your way to the services directory which is the install directory you indicated during the configuration.

```
cd ~
rm -rf anope-2.0.8/

# this could differ for you depending on the install directory you chose
cd ~/inspircd-2.0.29/run/services
```

Overall the configuration was surprisingly easy. I think I spent more time cleaning up the files and getting everything ready to go into source control than I did actually configuring.

You can pretty much follow along exactly with the guide (though some of the line numbers may be different) as well as my [*services.example.conf*](https://github.com/assimilate-dev/irc/blob/main/services/conf/services.example.conf) file. The one major thing I will note is that in order for Anope services to connect to your IRC server, you will need to make sure you have the following in your configuration file for InspIRCd:

```
<bind
      address=""
      port="7000"
      type="servers">
```

There are also modules that you will need to enable by uncommenting them in [*modules.conf*](https://github.com/assimilate-dev/irc/blob/main/conf/modules.conf). I honestly can't remember which ones I enabled specifically for this but spend some time reading through the helpful comments in `docs/conf/modules.conf.example` and taking a look at the modules I have uncommented in my module file.

At the very least, I enabled the following:

- m_spanningtree.so
- m_sasl.so

If you're all done start it up and see what happens.

```
cd ~/inspircd-2.0.29/run/services
./anoperc start
```

Now you should be able to register nicknames.

```
/msg NickServ REGISTER password [email]
```





## Static Site @ irc.assimilate.dev

I really wanted a static site to show when visiting [irc.assimilate.dev](https://irc.assimilate.dev/) from a web browser. The first thing I should have done (but didn't) was revisit my Lightsail instance networking configuration to make sure that port 443 was open.

| Application | Protocol | Port      | Restricted To |
| ----------- | -------- | --------- | ------------- |
| SSH         | TCP      | 22        | Any IP        |
| HTTP        | TCP      | 80        | Any IP        |
| HTTPS       | TCP      | 443       | Any IP        |
| Custom      | TCP      | 6660-6669 | Any IP        |
| Custom      | TCP      | 6697      | Any IP        |



### Initial Setup

This part was shockingly simple and I pretty much followed the instructions from the [Ubuntu Tutorial](https://ubuntu.com/tutorials/install-and-configure-apache) without too many changes.

```
sudo apt update
sudo apt install apache2
```

That was enough to get me up and running at my public IP http://44.242.29.15/

Because that IP is already pointed to [irc.assimilate.dev](https://irc.assimilate.dev/), I ignored the portion of the tutorial where they create the gci site. I only updated three files:

- [/var/www/html/index.html](https://github.com/assimilate-dev/irc/blob/main/apache-conf/index.html)
- [/etc/apache2/sites-available/000-default.conf](https://github.com/assimilate-dev/irc/blob/main/apache-conf/000-default.conf)
- [/etc/apache2/sites-available/default-ssl.conf](https://github.com/assimilate-dev/irc/blob/main/apache-conf/default-ssl.conf)

I also had to copy my SSL certificate files into the location defined in the configuration.

```
sudo cp /etc/letsencrypt/live/irc.assimilate.dev/fullchain.pem /etc/ssl/certs/irc.assimilate.dev.crt

sudo cp /etc/letsencrypt/live/irc.assimilate.dev/privkey.pem /etc/ssl/private/irc.assimilate.dev.key

sudo cp /etc/letsencrypt/live/irc.assimilate.dev/privkey.pem /etc/ssl/certs/ca-certificates.crt
```

Once the files were in place I [enabled ssl](https://www.linode.com/docs/guides/ssl-apache2-debian-ubuntu/) and reloaded Apache.

```
sudo a2enmod ssl
sudo service apache2 restart
```

That's pretty much it.

I used [Typora](https://typora.io/) plus the Xydark theme to create my single page with markdown and export it to index.html.



## Certificate Renewal

The certificates issued by certbot are valid for 90 days before they expire. To make sure these renew, I [scheduled a daily run](https://suchsecurity.com/using-letsencrypt-for-your-ircd.html) of [copy-certs.sh](https://github.com/assimilate-dev/irc/blob/main/copy-certs.sh).

