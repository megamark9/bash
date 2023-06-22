#!/bin/bash

echo "Uninstalling ESET"
sh /Applications/ESET\ Endpoint\ Security.app/Contents/Helpers/Uninstaller.app/Contents/Scripts/uninstall.sh
sh /Applications/ESET\ Remote\ Administrator\ Agent.app/Contents/Scripts/Uninstall.command

echo "Installing Sophos"



if [[ ! -d "/Applications/Sophos/Sophos Endpoint.app/" ]]; then
   

cp /Library/Application\ Support/JAMF/Waiting\ Room/Sophosinstall.zip /private/tmp/

cd /private/tmp/

chmod 775 Sophosinstall.zip

tar -xvf Sophosinstall.zip

chmod a+x ./Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
chmod a+x ./Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper

./Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --install
exit 0

else
    echo "Sophos already Installed, quitting script. "
fi

#rm -rf sophos_install_files