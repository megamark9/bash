#!/bin/bash

# Make sure the script is being executed with superuser privileges.

if [[ ${UID} -ne 0 ]]
then
  echo "Please run with root priveledges" >&2
  exit 1
fi

# If the user doesn't supply at least one argument, then give them help.

if [[ ${#} -lt 1 ]]
then 
  echo "Usage: ${0} USER_NAME [COMMENT]..." >&2
  exit 1
fi

# The first parameter is the user name.

USERNAME=${1}
shift

# The rest of the parameters are for the account comments.

COMMENTS=""
if [[ ${#} -gt 0 ]]
then
  COMMENTS="${@}"
fi


# Generate a password.
PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c48)
# Append a special character to the password.
SPECIAL_CHARACTER=$(echo '!@#$%^&*()_+' | fold -w1 | shuf | head -c1)
PASSWORD="${PASSWORD}${SPECIAL_CHARACTER}"

# Create the user with the password.

useradd -c "${COMMENTS}" -m ${USERNAME} &> /dev/null

# Check to see if the useradd command succeeded.

if [[ ${?} -ne 0 ]]
then
  echo "The user was not created succesfully" >&2 
  exit 1
fi

# Set the password.

echo ${PASSWORD} | passwd --stdin ${USERNAME} >& /dev/null

# Check to see if the passwd command succeeded.

if [[ ${?} -ne 0 ]]
then
  echo "passwd was not ran successfully" >&2
  exit 1
fi

# Force password change on first login.
echo "Expiring password for user ${USERNAME}" >& /dev/null
passwd -e ${USERNAME} >& /dev/null 

# Display the username, password, and the host where the user was created.

echo "Username:"
echo " ${USERNAME}"
echo "Password:"
echo " ${PASSWORD}"
echo "Hostname:"
echo " ${HOSTNAME}"

exit 0
