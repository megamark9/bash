#!/bin/bash -v

USER=$( ls -l /dev/console | awk '{print $3}' )

su - $USER -c "/bin/launchctl unload /Users/$USER/Library/LaunchAgents/user.launchkeep.skype.plist"

su - $USER -c "rm -rf /Users/$USER/Library/LaunchAgents/user.launchkeep.skype.plist"

open -a Skype.app