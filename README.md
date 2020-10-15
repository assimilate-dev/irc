# irc.assimilate.dev
The IRC server is setup and running. Big thanks to the guide at [JamieWeb](https://www.jamieweb.net/blog/inspircd-linux-guide/). As usual, there were slight differences which made things difficult. I'll do my best to call those out below.



## Amazon Lightsail

### Instance Type

For this project, I chose the $3.50 price-per-month instance: Linux/Unix - OS Only - Ubuntu 18.04. So far it has performed well with absolutely no issues.

When I was creating the instance, I created a new keypair named *irc* and downloaded the file which will be super important later.



### Networking

Right now this is setup to allow any IP for SSH which is admittedly bad but until I have a VPN available I don't have a static IP. For now I just toggle the rule on/off as needed when I need to connect and make changes.

| Application | Protocol | Port      | Restricted To |
| ----------- | -------- | --------- | ------------- |
| SSH         | TCP      | 22        | Any IP        |
| HTTP        | TCP      | 80        | Any IP        |
| Custom      | TCP      | 6660-6669 | Any IP        |
| Custom      | TCP      | 6697      | Any IP        |



### Static IP and DNS

Lightsail allows you to attach a static IP to your instance. Do that.

![Static IP Example](https://mrt-public.s3-us-west-2.amazonaws.com/static_ip.PNG)

I purchased my domain via Google Domains because they had the *.dev* top-level domain and that seemed pretty cool. Once I purchased *assimilate.dev* at Google Domains, switch back to the Lightsail web interface and click "Create DNS Zone." The options are simple and self-explanatory. After it is created, you are provided a list of name servers.



![Google Name Servers](https://mrt-public.s3-us-west-2.amazonaws.com/google_name_servers.PNG)



Switch back over to the Google Domain web interface where I purchased my domain, under the DNS section, I removed the existing name servers and added the ones that Lightsail provided.



![Amazon Name Servers](https://mrt-public.s3-us-west-2.amazonaws.com/amazon_name_servers.PNG)



Once you've removed the old name servers and added the Lightsail name servers, I was done with the Google Domain interface. Back in Lightsail, I added an A record for irc.assimilate.dev resolving to the static IP that I obtained from Lightsail.



### SSH

Now that your server is setup you can install and configure IRC. To access your server you can use SSH in one of two ways. Lightsail makes it easy with a big orange button that says "Connect using SSH." This will allow you to connect via a web browser.



![Amazon Name Servers](https://mrt-public.s3-us-west-2.amazonaws.com/ssh.PNG)



This method is convenient but it does make it kind of a pain to copy/paste text so I still like to connect with SHH in a terminal. From the Windows command line:

```ssh 
ssh -i irc.pem ubuntu@irc.assimilate.dev
```

You'll need to provide the correct path to your *.pem* file if you aren't, like me, running the command from the directory where the file is saved.



## Initial Setup

For the most part I followed the instructions on JamieWeb with a few minor additions from this guide and various StackOverflow posts that I found as I ran in to issues. I'll elaborate on those as they are relevant but a non-insignificant amount of this guide is based on the JamieWeb page.

I am installing InspIRCd version 2.0.29. I was originally going to go with a 3+ version but I immediately ran into issues installing a MariaDB package on both Ubuntu 20 and 18 and became to frustrated to continue troubleshooting.

I didn't create a new, unprivileged user for installation. I just used the root user *ubuntu*. Maybe someone who is more security-minded can tell me why this is bad but it seems to me that this server is only running one thing and not in a network with anything else so how bad could it be?

The first group of dependencies were recommended in [this guide](https://ubuntu.com/tutorials/irc-server#2-dependencies). I honestly don't know if they are essential but I installed them anyway.

The second group of dependencies is from JamieWeb but `libgnutl-dev` didn't work so I [changed it](https://askubuntu.com/questions/1058694/libgnutls-dev-has-no-installation-candidate-error-while-installing-ubuntu-as-a) to `libgnutls28-dev` instead which did the trick.

```
sudo apt-get update
sudo apt-get install perl g++ make
sudo apt-get install libgnutls28-dev gnutls-bin pkg-config
```

I also installed irssi as a client for testing my server:

```
sudo apt-get install irssi
```

Then download the package, extract it, and configure by following the wizard. During the interactive wizard, I chose `y` for SSL with `gnutls` and `n` for SSL with `openssl`.

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

Some configuration files ask you to specify passwords. It's never a good idea to store a password in pain text. It is recommended to hash them using `mkpasswd`. However hashing won't work on your server until you enable certain a few modules:

- m_md5.so

- m_sha256.so

- m_password_hash.so

Most of the time enabling modules is easy.

```
nano run/conf/modules.conf
```

Once you're inside the modules file find the lines for the appropriate modules and uncomment them. Occasionally, sometimes, maybe you will need to change other configurations for modules to work. This is one of the easy ones, though. Just uncomment and restart your server and password hashing will work.

```
./inspircd restart
irssi
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

You can arrange your configuration files any which way you like by placing an an include block in *inspircd.conf*.

```
<include file="conf/secrets.conf">
```

I put all of my blocks containing secrets into one file, *secrets.conf*, which I left out of source control. I [checked-in an example](https://github.com/assimilate-dev/irc/blob/main/conf/secrets.example.conf) of that file for you to see.

You can (and should) use this password hashing business to set a password for the `DIE` and `RESTART` commands in the power block of your configuration.



### Permanent Channels



### IP Cloaking

