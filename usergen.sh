#!/bin/bash

USAGE="Usage: usergen [options]
  Options: -e employee
           -c contractor
	   -h help (this)
	   -z Add Zoom Pro license (Employees only)
      "

while getopts ":echz" opt; do
  case $opt in
    e)
      EMP=true
      ;;
    c)
      CON=true
      ;;
    h)
      HELP=true
      ;;    
    z)
      ZOOM_PRO=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "$USAGE"
      exit 1
      ;;
  esac
done

if [ "$HELP" = "true" ]; then
  echo "$USAGE"
  exit 0
elif [[ ($@ == *'e'*) && ($@ == *'c'*) ]]; then
  echo "User cannot be an employee and a contractor"
  echo
  echo "$USAGE"
  exit 1
elif [[ ($@ == *'z'*) && ($@ == *'c'*) ]]; then
  echo "Zoom Pro licenses may not be added to contractors"
  echo
  echo "$USAGE"
  exit 1
elif [[ ! $@ ]]; then
  echo "usergen requires at least one argument"
  echo
  echo "$USAGE"
  exit 1
fi

read -p 'First Name: ' FIRST_NAME
read -p 'Last Name: ' LAST_NAME

LOWER_FIRST=`echo $FIRST_NAME | tr '[:upper:]' '[:lower:]'`
LOWER_LAST=`echo $LAST_NAME | tr '[:upper:]' '[:lower:]'`
INITIAL="$(echo $LOWER_FIRST | head -c 1)"
USER_NAME=$INITIAL$LOWER_LAST

read -p 'Department: ' DEPARTMENT
read -p 'Manager: ' MANAGER

if [ "$EMP" = "true" ]; then
    read -p 'Title: ' TITLE
    read -p 'Cell Number: ' MOBILE_PHONE
    read -p 'Office Number: ' PHONE_NUMBER
    read -p 'Location: ' LOCATION
    COMPANY=COMPANY
    EMAIL=$USER_NAME@URL.com
elif [ "$CON" = "true" ]; then
    read -p 'Email Address: ' CON_EMAIL
    read -p 'Company: ' COMPANY
    TITLE=Contractor
    EMAIL=$CON_EMAIL
    COMPANY=Contractor
fi

echo
echo

if [ "$EMP" = "true" ]; then
column -ts $';' <<< '
First Name:;'$FIRST_NAME'
Last Name:;'$LAST_NAME'
Username:;'$USER_NAME'
Department:;'$DEPARTMENT'
Manager:;'$MANAGER'
Title:;'$TITLE'
Cell #:;'$MOBILE_PHONE'
Phone Number:;'$PHONE_NUMBER'
Location:;'$LOCATION'
'
elif [ "$CON" = "true" ]; then
column -ts $';' <<< '
First Name:;'$FIRST_NAME'
Last Name:;'$LAST_NAME'
Username:;'$USER_NAME'
Department:;'$DEPARTMENT'
Manager:;'$MANAGER'
Title:;'$TITLE'
Email Address:;'$CON_EMAIL'
'
fi
echo

while true; do
  read -p "Is this information correct? (y/n) " yn
  echo
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
  esac
done

if [ ! -d ~/Desktop/LDIF ]; then
  mkdir ~/Desktop/LDIF
fi

# Write LDIF file

FILENAME=$USER_NAME.ldif

if [ -f ~/Desktop/LDIF/$FILENAME ]; then
    rm -rf ~/Desktop/LDIF/$FILENAME
fi

echo "Writing LDIF file to ~/Desktop/LDIF/$FILENAME"

function ldif_write ()
{
    echo "$1" >> ~/Desktop/LDIF/$FILENAME
}

ldif_write "dn: CN=${FIRST_NAME} ${LAST_NAME},CN=Users,DC=corp,DC=NAME,DC=com"
ldif_write "changetype: add"
ldif_write "sn: ${LAST_NAME}"
ldif_write "givenName: ${FIRST_NAME}"
ldif_write "displayName: ${FIRST_NAME} ${LAST_NAME}"
ldif_write "name: ${FIRST_NAME} ${LAST_NAME}"
ldif_write "sAMAccountName: ${USER_NAME}"
ldif_write "company: ${COMPANY}"
ldif_write "userPrincipalName: ${USER_NAME}@COMPANY.com"
ldif_write "proxyAddresses: SMTP:${EMAIL}"
ldif_write "personalTitle: ${TITLE}"
ldif_write "title: ${TITLE}"
ldif_write "department: ${DEPARTMENT}"
ldif_write "manager: CN=${MANAGER},CN=Users,DC=corp,DC=NAME,DC=com"

if [ "$EMP" = "true" ]; then
    ldif_write "telephoneNumber: ${PHONE_NUMBER}"
    ldif_write "mobile: ${MOBILE_PHONE}"
    ldif_write "l: ${LOCATION}"
    ldif_write "mail:${EMAIL}"
    ldif_write "physicalDeliveryOfficeName: ${LOCATION}"
elif [ "$CON" = "true" ]; then
    ldif_write "mail: ${CON_EMAIL}"
fi

ldif_write "userAccountControl: 514"
ldif_write "instanceType: 4"
ldif_write "objectClass: top"
ldif_write "objectClass: person"
ldif_write "objectClass: organizationalPerson"
ldif_write "objectClass: user"
ldif_write "objectClass: ldapPublicKey"

if [ "$EMP" = "true" ]; then
    ldif_write ""
    if [ "$ZOOM_PRO" = "true" ]; then
	ldif_write "dn: CN=Zoom Users Pro,CN=Users,DC=corp,DC=NAME,DC=com"
    else
        ldif_write "dn: CN=Zoom Users Basic,CN=Users,DC=corp,DC=NAME,DC=com"
    fi
    ldif_write "changeType: Modify"
    ldif_write "add: member"
    ldif_write "member: CN=${FIRST_NAME} ${LAST_NAME},CN=Users,DC=corp,DC=NAME,DC=com"
    ldif_write "-"
fi
echo "You must manually remove any lines that do not specify a value before importing"

exit
