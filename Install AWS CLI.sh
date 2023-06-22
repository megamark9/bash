#!/bin/bash

USER=$( ls -l /dev/console | awk '{print $3}' )
TN="/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
ICON="/Library/Application\ Support/JAMF/bin/LOGO.png"
TITLE="COMPANY,\ Inc.\ Network\ Operations"

function notify()
{
    su -l "$USER" -c "${TN} -windowType hud -icon $ICON -title $TITLE -description "'"'"$1"'"'" -button1 ""Ok"" -defaultButton 1"
}

su -l "$USER" -c "/usr/bin/curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/Users/$USER/awscli-bundle.zip""
su -l "$USER" -c "/usr/bin/unzip awscli-bundle.zip -d /Users/$USER/"

#su -l "$USER" -c "/usr/bin/curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip""
#su -l "$USER" -c "/usr/bin/unzip awscli-bundle.zip"

#sudo -u $USER /bin/bash /Users/$USER/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

osascript <<'EOF'
tell application "Terminal"
	if not (exists window 1) then reopen
    activate
    do script ("sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws") in window 1
    delay 1
    set W_ to windows of application "Terminal"
    repeat until busy of (item 1 of W_) is false
    end repeat
end tell
EOF

rm -rf /Users/$USER/awscli-bundle.zip
rm -rf /Users/$USER/awscli-bundle/

osascript <<'EOF'
	tell application "Terminal"
    	if not (exists window 1) then reopen
        activate
    	do script ("aws configure") in window 1
	end tell
EOF

notify "Complete AWS CLI configuration in terminal window"