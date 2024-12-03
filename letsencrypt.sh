#!/bin/bash

## --------------------------------------------------------------------------- ##
## ----------| Script to apply SSL certificates in routeOS systems |---------- ##
## ----------| Author: Alex Mendes				                         |---------- ##
## ----------| E-Mail: alex.mendes@zooxsmart.com		               |---------- ##
## --------------------------------------------------------------------------- ##
# Requirements:
# - PROJECT FOLDER: 	/opt/letsencrypt-routeros
# - SSH KEYPAIRS: 	id_dsa, id_dsa.pub
# - letsencrypt installed
# - letsencrypt FOLDER:	/etc/letsencrypt/live/$DOMAIN
# - CERTS DOMAIN: 	cert.pem(crt), privkey.pem(key)

# Routers data
ROUTEROS_USER=admin
ROUTEROS_SSH_PORT=22
ROUTEROS_PRIVATE_KEY=/opt/letsencrypt-routeros/id_dsa
ROUTEROS_PUBLIC_KEY=/opt/letsencrypt-routeros/id_dsa.pub
#ROUTEROS_HOST=$(cat routers)

# Certification data
DOMAIN=sub.yourdomain.com
CERTIFICATE=/etc/letsencrypt/live/$DOMAIN/cert.pem
KEY=/etc/letsencrypt/live/$DOMAIN/privkey.pem
#CA=/etc/letsencrypt/live/$DOMAIN/letsencryptauthorityx3.pem
LOG=letsencrypt.log

# Cleaning LOG
clear
echo "" > $LOG

for ip in $(cat routers); do

ROUTEROS_HOST=$ip

#RouteOS Command
echo -e "Checking SSH connection to $ip\n"
routeros="ssh -i $ROUTEROS_PRIVATE_KEY $ROUTEROS_USER@$ROUTEROS_HOST -p $ROUTEROS_SSH_PORT"

$routeros /system resource print
RESULT=$?

if [ ! $RESULT == 0 ]; then
  echo -e "SSH available for RouterOS.\n"
  scp -P $ROUTEROS_SSH_PORT $ROUTEROS_PUBLIC_KEY "$ROUTEROS_USER"@"$ROUTEROS_HOST":"id_dsa.pub"
  if [echo $? == 0 ]; then
   echo -e "SSH configuration is concluded. Following the flow...\n"
  else
    echo -e "The SSH connection still failed. Please, check your $ROUTEOS_HOST settings and try again.\n"
  exit 1
  fi
else
  echo -e "\nConnection to RouterOS $ROUTEROS_HOST Successful!\n"
fi

if [ ! -f $CERTIFICATE ] && [ ! -f $KEY ]; then
  echo -e "\nFile(s) not found:\n$CERTIFICATE\n$KEY\n"
  echo -e "Please use CertBot Let'sEncrypt:"
  echo "============================"
  echo "certbot certonly --preferred-challenges=dns --manual -d $DOMAIN --manual-public-ip-logging-ok"
  echo "==========================="
  echo -e "and follow instructions from CertBot\n"
  exit 1
fi

# Remove previous certs
echo -e "Remove previous certificate...\n"
sleep 1
$routeros /certificate remove [find name=$DOMAIN.pem_0]
$routeros /file remove $DOMAIN.pem > /dev/null

# Upload a new certificate
echo -e "Uploading NEW certificate for $DOMAIN ...\n"
sleep 1
scp -q -P $ROUTEROS_SSH_PORT -i "$ROUTEROS_PRIVATE_KEY" "$CERTIFICATE" "$ROUTEROS_USER"@"$ROUTEROS_HOST":"$DOMAIN.pem"
sleep 2
# Import Certificate file -----------------------------------
$routeros /certificate import file-name=$DOMAIN.pem passphrase=\"\"
# Delete Certificate file after import
$routeros /file remove $DOMAIN.pem

# Create Key -----------------------------------
# Delete Certificate file if the file exist on RouterOS
$routeros /file remove $KEY.key > /dev/null
# Upload Key to RouterOS
scp -q -P $ROUTEROS_SSH_PORT -i "$ROUTEROS_PRIVATE_KEY" "$KEY" "$ROUTEROS_USER"@"$ROUTEROS_HOST":"$DOMAIN.key"
sleep 2

# Import Key file
$routeros /certificate import file-name=$DOMAIN.key passphrase=\"\"
# Delete Certificate file after import
$routeros /file remove $DOMAIN.key

# Setup Certificate to SSTP Server -----------------------------------
$routeros /interface sstp-server server set certificate=$DOMAIN.pem_0
#$routeros /ip service set www-ssl certificate=$DOMAIN.pem_0
$routeros /ip service set www-ssl certificate=$DOMAIN.pem_0 disabled=no
$routeros /ip service set api-ssl certificate=$DOMAIN.pem_0

# Allow External HTTPS traffic
#$routeros /ip firewall filter add chain=input protocol=tcp dst-port=443 action=accept

echo -e "$DOMAIN have installed in $ROUTEROS_HOST" | tee -a $LOG
done

exit 0
