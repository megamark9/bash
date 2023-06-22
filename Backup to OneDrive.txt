#!/bin/bash

USER=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
ONE_DRIVE_DIRECTORY="/Users/$USER/OneDrive"

echo $USER
echo $ONE_DRIVE_DIRECTORY

echo "Checking to see if any action is needed"
if [ -L "/Users/$USER/Desktop" ] && [ -L "/Users/$USER/Documents" ]; then
    echo "Desktop and Documents Symlinks exist. No action required."
    exit
fi

killall -9 OneDrive

echo "Checking if Desktop exists in OneDrive directory"
if [[ -d ${ONE_DRIVE_DIRECTORY}/Desktop ]]; then
   echo "Desktop directory exists in OneDrive directory. Renaming Desktop directory."
   DESKTOP_EXISTS=true
   mv "$ONE_DRIVE_DIRECTORY/Desktop" "$ONE_DRIVE_DIRECTORY/Desktop.bak"
fi

echo "Checking if Documents exists in OneDrive directory"
if [[ -d ${ONE_DRIVE_DIRECTORY}/Documents ]]; then
   echo "Documents directory exists in OneDrive directory. Renaming Documents directory."
   DOCUMENTS_EXISTS=true
   mv "$ONE_DRIVE_DIRECTORY/Documents" "$ONE_DRIVE_DIRECTORY/Documents.bak"
fi

echo "Checking to see if Desktop is already a symlink"
if [ -L "/Users/$USER/Desktop" ]; then
    echo "SUCCESS"
else
    echo "Desktop is not a SymLink"
    echo "Checking for existance of OneDrive folder in default location"
    if [ -d "$ONE_DRIVE_DIRECTORY" ]; then
        echo "OneDrive Directory Exists"
        echo "Moving Desktop to OneDrive"
        mv /Users/$USER/Desktop "$ONE_DRIVE_DIRECTORY"
        echo "Done"
        echo "Creating Desktop symlink"
        ln -s "$ONE_DRIVE_DIRECTORY/Desktop" /Users/$USER/
        chown -h $USER "/Users/$USER/Desktop"
        chflags -h uchg "/Users/$USER/Desktop"
        echo "Done"
        echo "Restarting Finder"
    else
        echo "OneDrive directory missing or not in default location"
    fi
fi

echo "Checking to see if Documents is already a symlink"
if [ -L "/Users/$USER/Documents" ]; then
    echo "SUCCESS"
else
    echo "Documents is not a SymLink"
    echo "Checking for existance of OneDrive folder in default location"
    if [ -d "$ONE_DRIVE_DIRECTORY" ]; then
        echo "OneDrive Directory Exists"
        echo "Moving Documents to OneDrive"
        mv /Users/$USER/Documents "$ONE_DRIVE_DIRECTORY"
        echo "Done"
        echo "Creating Documents symlink"
        ln -s "$ONE_DRIVE_DIRECTORY/Documents" /Users/$USER/
        chown -h $USER "/Users/$USER/Documents"
        chflags -h uchg "/Users/$USER/Documents"
        echo "Done"
        echo "Restarting Finder"
    else
        echo "OneDrive directory missing or not in default location"
    fi
fi

if [[ $DESKTOP_EXISTS == "true" ]]; then
    mv -f "$ONE_DRIVE_DIRECTORY/Desktop.bak"/* "$ONE_DRIVE_DIRECTORY/Desktop/"
    if [ -f "$ONE_DRIVE_DIRECTORY/Desktop.bak/.DS_Store" ]; then
        rm -rf "$ONE_DRIVE_DIRECTORY/Desktop.bak/.DS_Store"
    fi
    rmdir "$ONE_DRIVE_DIRECTORY/Desktop.bak"
fi

if [[ $DOCUMENTS_EXISTS == "true" ]]; then
    mv -f "$ONE_DRIVE_DIRECTORY/Documents.bak"/* "$ONE_DRIVE_DIRECTORY/Documents/"
        if [ -f "$ONE_DRIVE_DIRECTORY/Documents.bak/.DS_Store" ]; then
        rm -rf "$ONE_DRIVE_DIRECTORY/Documents.bak/.DS_Store"
    fi
    rmdir "$ONE_DRIVE_DIRECTORY/Documents.bak"
fi

open -a OneDrive

echo "Final Check"
if [ -L "/Users/$USER/Desktop" ] && [ -L "/Users/$USER/Documents" ]; then
    killall Finder /System/Library/CoreServices/Finder.app
    echo "SUCCESS"
else
    echo "FAILURE"
    echo "Home is /Users/$USER"
fi