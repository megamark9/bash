#!/bin/bash

USER=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
APPROVEMDM=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "COMPANY, Inc. Network Operations" -description "Please take the time to approve the management profile on your MacBook. 

**Note** Select \"MDM Profile\" in the pane on the left and click \"Approve\" in the window on the right.

Network Operations" -icon "/Library/Application Support/JAMF/bin/LOGO.png" -iconSize 40 -button1 "Approve" -button2 "Later" -defaultButton 1 -cancelButton 2`

if [ "$APPROVEMDM" == "0" ]; then
    echo "Opening Profile preferences"
    sudo -u $USER /usr/bin/open -b com.apple.systempreferences /System/Library/PreferencePanes/Profiles.prefPane
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "COMPANY, Inc. Network Operations" -description "1) Select the \"MDM Profile\" item in the pane on the left

2) Click \"Approve\" in the pane on the right" -icon "/Library/Application Support/JAMF/bin/LOGO.png" -iconSize 40 -button1 "Ok" -defaultButton 1
else
    echo "Setting up later"
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "AudioEye, Inc. Network Operations" -description "We'll remind you again tomorrow :)" -button1 "Ok" -defaultButton 1
    echo "User Deferred"
    exit
fi

exit