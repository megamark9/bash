#!/bin/bash

USER=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
GIT="github.com"
GITIPS=(`dig +short $GIT`)
#KNOWN_HOSTS=`su -l "$USER" -c "ssh-keygen -H -F $GIT"`

GITIPS+=($GIT)

for IP in "${GITIPS[@]}"; do
    if [[ `su -l "$USER" -c "ssh-keygen -H -F $IP"` ]]; then
        echo "$IP already exists in known_hosts."
#        su -l "$USER" -c "ssh-keygen -R $IP -f /Users/$USER/.ssh/known_hosts"
    else
        echo "$IP doesn't exists in known_hosts"
        echo "Adding $IP to known_hosts"
        su -l "$USER" -c "ssh-keyscan -H -t rsa,dsa,ecdsa,ed25519 $IP >> /Users/$USER/.ssh/known_hosts"
    fi
done

exit