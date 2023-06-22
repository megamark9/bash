#!/bin/bash

SETUPOD=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "COMPANY, Inc. Network Operations" -description "Please take the time to upgrade to MacOS High Sierra. 

**Note** This installation will take about 45 minutes to complete, and may best be performed at the end of your work day.

Network Operations" -icon "/Library/Application Support/JAMF/bin/AudioEyeLogo.png" -iconSize 40 -button1 "Upgrade" -button2 "Later" -defaultButton 1 -cancelButton 2`

if [ "$SETUPOD" == "0" ]; then
    echo "Upgrading to High Sierra"
    open -a /Applications/Install\ macOS\ Sierra.app/Contents/Resources/startosinstall --applicationpath "/Applications/Install macOS Sierra.app" --volume $1 --rebootdelay 30 --nointeraction
    killall "Self Service"
else
    echo "Upgrading later"
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "COMPANY, Inc. Network Operations" -description "We'll remind you again tomorrow :)" -button1 "Ok" -defaultButton 1
    exit 1
fi

exit