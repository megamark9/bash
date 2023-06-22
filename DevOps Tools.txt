#!/bin/bash

USER=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
GIT="ENTER_GIT_URL"
GITIP=`dig +short $GIT`
GITHOST=`grep $GIT /Users/$USER/.ssh/known_hosts`
GITIPHOST=`grep $GITIP /Users/$USER/.ssh/known_hosts`
TN="/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
ICON="/Library/Application\ Support/JAMF/bin/LOGO.png"
TITLE="COMPANY,\ Inc.\ Network\ Operations"

function notify()
{
    su -l "$USER" -c "${TN} -windowType hud -icon $ICON -title $TITLE -description "'"'"$1"'"'" -button1 ""Ok"" -defaultButton 1"
}

echo "Checking that SSH has been initialized"
if [ ! -d /Users/$USER/.ssh ]; then
    notify "SSH hasn't been initialized"
    echo "SSH not yet initialized"
    exit 1
fi

if [[ $GITHOST != *$GIT* ]]; then
    echo "Adding $GIT to known_hosts"
    su -l "$USER" -c "ssh-keyscan -t ecdsa $GIT >> /Users/$USER/.ssh/known_hosts"
else
    echo "$GIT already in known_hosts"
fi

if [[ $GITIPHOST != *$GITIP* ]]; then
    echo "Adding $GITIP to known_hosts"
    su -l "$USER" -c "ssh-keyscan -t ecdsa "$GITIP" >> /Users/$USER/.ssh/known_hosts"
else
    echo "$GITIP already in known_hosts"
fi

echo "Checking for access to repository"
GIT=`su -l "$USER" -c "git ls-remote ENTER_GIT_URL"`
if [[ $GIT != *HEAD* ]]; then
    notify "No access to repository"
    echo "aedocker requires access to git repository"
    echo $GIT
    exit 1
fi

if [ -d /Users/$USER/devops/.git ]; then
    echo "DevOps Tools repository already exists"
  else
    echo "Cloning DevOps Tools repository"
    rm -rf /Users/$USER/devops
    sudo -u $USER git clone ENTER_GIT_URL /Users/$USER/devops/
fi

if [ ! -f /usr/local/bin/config ]; then
  echo "Creating DevOps configuration link"
  ln -s /Users/$USER/devops/scripts/setup /usr/local/bin/aeconfig
else
  echo "DevOps configuration link already exists"
fi

if [ ! -f /usr/local/bin/goto ]; then
  echo "Creating goto link"
  ln -s /Users/$USER/devops/scripts/goto /usr/local/bin/goto
else
  echo "Goto link already exists"
fi

if [ ! -f /usr/local/bin/usergen ]; then
  echo "Creating usergen link"
  ln -s /Users/$USER/devops/scripts/usergen /usr/local/bin/usergen
else
  echo "Usergen link already exists"
fi

if [ ! -f /usr/local/bin/groupgen ]; then
  echo "Creating groupgen link"
ln -s /Users/$USER/devops/scripts/groupgen /usr/local/bin/groupgen
else
  echo "Groupgen link already exists"
fi

if [ ! -f /usr/local/bin/govto ]; then
  echo "Creating govto link"
ln -s /Users/$USER/devops/scripts/govto /usr/local/bin/govto
else
  echo "Govto link already exists"
fi

osascript <<'EOF'
tell application "Terminal"
	if not (exists window 1) then reopen
    activate
    do script ("aeconfig") in window 1
end tell
EOF

notify "Complete DevOps Tools configuration in terminal window"

exit