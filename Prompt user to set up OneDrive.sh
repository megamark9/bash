#!/bin/bash

SETUPOD=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "COMPANY, Inc. Network Operations" -description "Please take the time to set up your OneDrive sync. 

**Note** Accept all defaults and check the checkbox to start at login.

Network Operations" -icon "/Library/Application Support/JAMF/bin/AudioEyeLogo.png" -iconSize 40 -button1 "Set Up" -button2 "Later" -defaultButton 1 -cancelButton 2`

if [ "$SETUPOD" == "0" ]; then
    echo "Opening OneDrive"
    open -a /Applications/OneDrive.app
else
    echo "Setting up later"
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "COMPANY, Inc. Network Operations" -description "We'll remind you again tomorrow :)" -button1 "Ok" -defaultButton 1
    echo "User Deferred"
    exit
fi

exit