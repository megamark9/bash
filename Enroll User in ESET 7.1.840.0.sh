#!/bin/sh -e
# ESET Security Management Center
# Copyright (c) 1992-2019 ESET, spol. s r.o. All Rights Reserved

files2del="$(mktemp -q /tmp/XXXXXXXX.files)"
dirs2del="$(mktemp -q /tmp/XXXXXXXX.dirs)"
echo "$dirs2del" >> "$files2del"
dirs2umount="$(mktemp -q /tmp/XXXXXXXX.mounts)"
echo "$dirs2umount" >> "$files2del"

finalize()
{
  set +e

  echo "Cleaning up:"

  if test -f "$dirs2umount"
  then
    while read f
    do
      sudo -S hdiutil detach "$f"
    done < "$dirs2umount"
  fi

  if test -f "$dirs2del"
  then
    while read f
    do
      test -d "$f" && rmdir "$f"
    done < "$dirs2del"
  fi

  if test -f "$files2del"
  then
    while read f
    do
      unlink "$f"
    done < "$files2del"
    unlink "$files2del"
  fi
}

trap 'finalize' HUP INT QUIT TERM EXIT

eraa_server_hostname="ENTER_URL"
eraa_server_port="2222"
eraa_server_company_name=""
eraa_peer_cert_b64="CERT_HERE"
eraa_peer_cert_pwd=""
eraa_ca_cert_b64="CERT_HERE"
eraa_product_uuid=""
eraa_initial_sg_token="TOKEN_HERE"
eraa_enable_telemetry="1"
eraa_policy_data=""

eraa_http_proxy_use="0"
eraa_http_proxy_hostname=""
eraa_http_proxy_port=""
eraa_http_proxy_user=""
eraa_http_proxy_password=""

arch=$(uname -m)
eraa_installer_url="http://repository.eset.com/v1/com/eset/apps/business/era/agent/v7/7.1.840.0/agent_macosx_x86_64.dmg"
eraa_installer_checksum="3469fd34403143587c1b835beb2214ee4d03d07d"
if $(echo "$arch" | grep -E "^(x86_64|amd64)$" 2>&1 > /dev/null)
then
    eraa_installer_url="http://repository.eset.com/v1/com/eset/apps/business/era/agent/v7/7.1.840.0/agent_macosx_x86_64.dmg"
    eraa_installer_checksum="3469fd34403143587c1b835beb2214ee4d03d07d"
fi

echo "ESET Management Agent live installer script. Copyright © 1992-2019 ESET, spol. s r.o. - All rights reserved."

if test ! -z $eraa_server_company_name
then
  echo " * CompanyName: $eraa_server_company_name"
fi
echo " * Hostname: $eraa_server_hostname"
echo " * Port: $eraa_server_port"
echo " * Installer: $eraa_installer_url"
echo

if test -z $eraa_installer_url
then
  echo "No installer available for '$arch' arhitecture."
  exit 1
fi

local_params_file="/tmp/postflight.plist"
echo "$local_params_file" >> "$files2del"

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$local_params_file"
echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" >> "$local_params_file"
echo "<plist version=\"1.0\">" >> "$local_params_file"
echo "<dict>" >> "$local_params_file"

echo "  <key>Hostname</key><string>$eraa_server_hostname</string>" >> "$local_params_file"
echo "  <key>SendTelemetry</key><string>$eraa_enable_telemetry</string>" >> "$local_params_file"

echo "  <key>Port</key><string>$eraa_server_port</string>" >> "$local_params_file"

if test -n "$eraa_peer_cert_pwd"
then
  echo "  <key>PeerCertPassword</key><string>$eraa_peer_cert_pwd</string>" >> "$local_params_file"
  echo "  <key>PeerCertPasswordIsBase64</key><string>yes</string>" >> "$local_params_file"
fi

echo "  <key>PeerCertContent</key><string>$eraa_peer_cert_b64</string>" >> "$local_params_file"


if test -n "$eraa_ca_cert_b64"
then
  echo "  <key>CertAuthContent</key><string>$eraa_ca_cert_b64</string>" >> "$local_params_file"
fi
if test -n "$eraa_product_uuid"
then
  echo "  <key>ProductGuid</key><string>$eraa_product_uuid</string>" >> "$local_params_file"
fi
if test -n "$eraa_initial_sg_token"
then
  echo "  <key>InitialStaticGroup</key><string>$eraa_initial_sg_token</string>" >> "$local_params_file"
fi
if test -n "$eraa_policy_data"
then
  echo "  <key>CustomPolicy</key><string>$eraa_policy_data</string>" >> "$local_params_file"
fi

if test "$eraa_http_proxy_use" = "1"
then
  echo "  <key>UseProxy</key><string>$eraa_http_proxy_use</string>" >> "$local_params_file"
  echo "  <key>ProxyHostname</key><string>$eraa_http_proxy_hostname</string>" >> "$local_params_file"
  echo "  <key>ProxyPort</key><string>$eraa_http_proxy_port</string>" >> "$local_params_file"
  echo "  <key>ProxyUsername</key><string>$eraa_http_proxy_user</string>" >> "$local_params_file"
  echo "  <key>ProxyPassword</key><string>$eraa_http_proxy_password</string>" >> "$local_params_file"
fi

echo "</dict>" >> "$local_params_file"
echo "</plist>" >> "$local_params_file"

# optional list of G1 migration parameters (MAC, UUID, LSID)
local_migration_list="$(mktemp -q /tmp/XXXXXXXX.migration)"
tee "$local_migration_list" 2>&1 > /dev/null << __LOCAL_MIGRATION_LIST__

__LOCAL_MIGRATION_LIST__
test $? = 0 && echo "$local_migration_list" >> "$files2del"

# get all local MAC addresses (normalized)
for mac in $(ifconfig -a | grep ether | sed -e "s/^[[:space:]]ether[[:space:]]//g")
do
    macs="$macs $(echo $mac | sed 's/\://g' | awk '{print toupper($0)}')"
done

while read line
do
  if test -n "$macs" -a -n "$line"
  then
    mac=$(echo $line | awk '{print $1}')
    uuid=$(echo $line | awk '{print $2}')
    lsid=$(echo $line | awk '{print $3}')
    if $(echo "$macs" | grep "$mac" > /dev/null)
    then
      if test -n "$mac" -a -n "$uuid" -a -n "$lsid"
      then
        /usr/libexec/PlistBuddy -c "Add :ProductGuid string $uuid" "$local_params_file"
        /usr/libexec/PlistBuddy -c "Add :LogSequenceID integer $lsid" "$local_params_file"
         break
      fi
    fi
  fi
done < "$local_migration_list"

local_dmg="$(mktemp -q -u /tmp/EraAgentOnlineInstaller.dmg.XXXXXXXX)"
echo "Downloading installer image '$eraa_installer_url':"

eraa_http_proxy_value=""
if test -n "$eraa_http_proxy_value"
then
  export use_proxy=yes
  export http_proxy="$eraa_http_proxy_value"
  (curl --fail --connect-timeout 300 --insecure -o "$local_dmg" "$eraa_installer_url" || curl --fail --connect-timeout 300 --noproxy "*" --insecure -o "$local_dmg" "$eraa_installer_url") && echo "$local_dmg" >> "$files2del"
else
  curl --fail --connect-timeout 300 --insecure -o "$local_dmg" "$eraa_installer_url" && echo "$local_dmg" >> "$files2del"
fi

if test ! -s "$local_dmg"
then
   echo "Failed to download installer file"
   exit 2
fi

/bin/echo -n "Checking integrity of of downloaded package " && echo "$eraa_installer_checksum  $local_dmg" | shasum -c

local_mount="$(mktemp -q -d /tmp/EraAgentOnlineInstaller.mount.XXXXXXXX)" && echo "$local_mount" | tee "$dirs2del" >> "$dirs2umount"
echo "Mounting image '$local_dmg':" && sudo -S hdiutil attach "$local_dmg" -mountpoint "$local_mount" -nobrowse

local_pkg="$(ls "$local_mount" | grep "\.pkg$" | head -n 1)"

echo "Installing package '$local_mount/$local_pkg':" && sudo -S installer -pkg "$local_mount/$local_pkg" -target /
