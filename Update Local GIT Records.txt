#!/bin/bash

USER=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
GIT="GITHUB_URL"
GITIP=`dig +short $GIT`
OLDGIT="OLD_GITHUB_URL"
OLDGITIP=`dig +short $OLDGIT`

echo "$GIT is at $GITIP"
echo "$OLDGIT is at $OLDGITIP"

if [ $GITIP = $OLDGITIP ]; then
    echo "Migration hasn't occurred yet"
    exit 1
fi

if [[ `su -l "$USER" -c "ssh-keygen -F $GIT"` ]]; then
    echo "$GIT exists in known_hosts. Removing."
    su -l "$USER" -c "ssh-keygen -R $GIT"
else
    echo "$GIT doesn't exists in known_hosts"
fi

if [[ `su -l "$USER" -c "ssh-keygen -H -F $GIT"` ]]; then
    echo "Hashed $GIT exists in known_hosts. Removing."
    su -l "$USER" -c "ssh-keygen -R $GIT"
else
    echo "Hashed $GIT doesn't exists in known_hosts"
fi

if [[ `su -l "$USER" -c "ssh-keygen -F $GITIP"` ]]; then
    echo "$GITIP exists in known_hosts. Removing."
    su -l "$USER" -c "ssh-keygen -R $GITIP"
else
    echo "$GITIP doesn't exists in known_hosts"
fi

if [[ `su -l "$USER" -c "ssh-keygen -H -F $GITIP"` ]]; then
    echo "Hashed $GITIP exists in known_hosts. Removing."
    su -l "$USER" -c "ssh-keygen -R $GITIP"
else
    echo "Hashed $GITIP doesn't exists in known_hosts"
fi

echo "Adding $GIT to known_hosts"
su -l "$USER" -c "ssh-keyscan -H -t ecdsa $GIT >> /Users/$USER/.ssh/known_hosts"
echo "Adding $GITIP to known hosts"
su -l "$USER" -c "ssh-keyscan -H -t ecdsa $GITIP >> /Users/$USER/.ssh/known_hosts"

if [[ `su -l "$USER" -c "ssh-keygen -F $GIT"` ]]; then
    echo "$GIT exists in known_hosts."
else
    echo "$GIT doesn't exists in known_hosts"
fi

if [[ `su -l "$USER" -c "ssh-keygen -H -F $GIT"` ]]; then
    echo "Hashed $GIT exists in known_hosts."
else
    echo "Hashed $GIT doesn't exists in known_hosts"
fi

if [[ `su -l "$USER" -c "ssh-keygen -F $GITIP"` ]]; then
    echo "$GITIP exists in known_hosts."
else
    echo "$GITIP doesn't exists in known_hosts"
fi

if [[ `su -l "$USER" -c "ssh-keygen -H -F $GITIP"` ]]; then
    echo "Hashed $GITIP exists in known_hosts."
else
    echo "Hashed $GITIP doesn't exists in known_hosts"
fi

exit