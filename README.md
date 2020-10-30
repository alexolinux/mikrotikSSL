[![MikrotikBanner](https://banner2.cleanpng.com/20180624/lij/kisspng-mikrotik-routeros-hewlett-packard-ubiquiti-network-hack-5b303904dece18.4006146215298869809126.jpg "MikrotikBanner")](https://banner2.cleanpng.com/20180624/lij/kisspng-mikrotik-routeros-hewlett-packard-ubiquiti-network-hack-5b303904dece18.4006146215298869809126.jpg "MikrotikBanner")

# mickrotikSSL
## How to install SSL certificate in multiple routers

Due to the need to install ssl certificates on multiple <b>mikrotik routeros</b>, I had to find out a way to use <b>letsencrypt</b> and based on the articles at <b>blog.effenberger.org</b> <i>(Creating SSL certificates on RouterOS with Let's Encrypt)</i> and <b>albertsola.pro</b> <i>(HOWTO: Letsencrypt SSL certificate in Mikrotik)</i> I have created a model script for installing SSL certificates on multiple Mikrotik routers.

### Project Recommendation
- Linux Server with letsencrypt installed
- Project folder (script files content): /opt/letsencrypt-routeros
- Certname used: cert.pem(crt), privkey.pem(key)
- Default SSH keypairs name used:  id_dsa, id_dsa.pub

Author: Alex Mendes


References:
https://www.albertsola.pro/howto-use-letsencrypt-ssl-certificate-in-mikrotik/
https://blog.effenberger.org/2018/04/22/creating-ssl-certificates-on-routeros-with-lets-encrypt/
https://wiki.mikrotik.com/wiki/Manual:Hotspot_HTTPS_example

