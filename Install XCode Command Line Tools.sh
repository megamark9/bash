#!/bin/bash

# This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
clt=$(softwareupdate -l | grep -B 1 -E "Command Line (Developer|Tools)" | awk -F"*" '/^ +\\*/ {print $2}' | sed 's/^ *//' | tail -n1)
softwareupdate -i "$clt"
rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
/usr/bin/xcode-select --switch /Library/Developer/CommandLineTools

exit