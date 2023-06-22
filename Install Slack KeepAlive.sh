#!/bin/bash -v

USER=$( ls -l /dev/console | awk '{print $3}' )

su - $USER -c "/bin/launchctl load /Users/$USER/Library/LaunchAgents/user.launchkeep.slack.plist"