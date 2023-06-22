#!/bin/bash

#set -x

GROUP_NAME=`echo $@`

LOWER_GROUP=`echo $GROUP_NAME | tr '[:upper:]' '[:lower:]'`
SHORT_GROUP=`echo $LOWER_GROUP | tr -d '[:space:]'`

if [ ! -d ~/Desktop/LDIF ]; then
  mkdir ~/Desktop/LDIF
fi

FILENAME=$SHORT_GROUP.ldif

echo "Writing LDIF file to ~/Desktop/LDIF/$FILENAME"

cat >~/Desktop/LDIF/"$FILENAME" <<EOL
dn: CN=${GROUP_NAME},CN=Users,DC=corp,DC=NAME,DC=com
changetype: add
cn: ${GROUP_NAME}
displayName: ${GROUP_NAME}
name: ${GROUP_NAME}
sAMAccountName: ${GROUP_NAME}
mail: ${SHORT_GROUP}@URL.com
proxyAddresses: SMTP:${SHORT_GROUP}@URL.com
description: ${GROUP_NAME}
groupType: 8
instanceType: 4
objectClass: top
objectClass: group
EOL

echo "You must manually remove any lines that do not specify a value before importing"

exit
