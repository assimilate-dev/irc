## irc.assimilate.dev
The IRC server is setup and running. Big thanks to the guide at [JamieWeb](https://www.jamieweb.net/blog/inspircd-linux-guide/). As usual, there were slight differences which made things difficult. I'll do my best to call those out below.



### Amazon Lightsail

##### Instance Type

For this project, I chose the $3.50 price-per-month instance: Linux/Unix - OS Only - Ubuntu 18.04. So far it has performed well with absolutely no issues.

When I was creating the instance, I created a new keypair named *irc* and downloaded the file which will be super important later.

##### Networking

Right now this is setup to allow any IP for SSH which is admittedly bad but until I have a VPN available I don't have a static IP. For now I just toggle the rule on/off as needed when I need to connect and make changes.

| Application | Protocol | Port      | Restricted To |
| ----------- | -------- | --------- | ------------- |
| SSH         | TCP      | 22        | Any IP        |
| HTTP        | TCP      | 80        | Any IP        |
| Custom      | TCP      | 6660-6669 | Any IP        |
| Custom      | TCP      | 6697      | Any IP        |

##### Static IP and DNS

Lightsail allows you to attach a static IP to your instance. Do that.

![Static IP Example](https://mrt-public.s3-us-west-2.amazonaws.com/static_ip.PNG)

I purchased my domain via Google Domains because they had the *.dev* top-level domain and that seemed pretty cool. Once I purchased *assimilate.dev* at Google Domains, switch back to the Lightsail web interface and click "Create DNS Zone." The options are simple and self-explanatory. After it is created, you are provided a list of name servers.



![Google Name Servers](https://mrt-public.s3-us-west-2.amazonaws.com/google_name_servers.PNG)



Switch back over to the Google Domain web interface where I purchased my domain, under the DNS section, I removed the existing name servers and added the ones that Lightsail provided.



![Amazon Name Servers](https://mrt-public.s3-us-west-2.amazonaws.com/amazon_name_servers.PNG)



Once you've removed the old name servers and added the Lightsail name servers, I was done with the Google Domain interface. Back in Lightsail, I added an A record for irc.assimilate.dev resolving to the static IP that I obtained from Lightsail.

##### SSH

Now that your server is setup you can install and configure IRC. To access your server you can use SSH in one of two ways. Lightsail makes it easy with a big orange button that says "Connect using SSH." This will allow you to connect via a web browser.



![Amazon Name Servers](https://mrt-public.s3-us-west-2.amazonaws.com/ssh.PNG)



This method is convenient but it does make it kind of a pain to copy/paste text so I still like to connect with SHH in a terminal. From the Windows command line:

```ssh 
ssh -i irc.pem ubuntu@irc.assimilate.dev
```

You'll need to provide the correct path to your *.pem* file if you aren't, like me, running the command from the directory where the file is saved.