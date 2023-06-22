#!/bin/bash

USER=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
URL="https://download.virtualbox.org/virtualbox/6.0.4/VirtualBox-6.0.4-128413-OSX.dmg"
URLCHECKSUM="b757e1df9fc73ccc1e98776c0ec45f48d2950bb1f5f91e25f9d5c43fd8774b05"

curl -o /Users/$USER/Downloads/virtualbox.dmg $URL

CKSUM=`shasum -a 256 /Users/$USER/Downloads/virtualbox.dmg | awk '{print $1}'`

if [ $CKSUM != "$URLCHECKSUM" ]; then
   echo $CKSUM
   echo "Download Failed"
   exit 1
else
   echo $CKSUM
   echo "Download Succeeded"
fi

echo "Mounting image"
sudo su - $USER -c "hdiutil attach /Users/$USER/Downloads/virtualbox.dmg -noverify -noautofsck" 

echo "Installing package"
#sudo su - $USER -c "/usr/sbin/installer -package /Volumes/VirtualBox/VirtualBox.pkg -target /"
/usr/sbin/installer -package /Volumes/VirtualBox/VirtualBox.pkg -target / > /dev/null 2>&1

echo "Unmounting image"
sudo su - $USER -c "hdiutil detach /Volumes/VirtualBox"

echo "Removing DMG"
sudo rm -rf /Users/$USER/Downloads/virtualbox.dmg

exit