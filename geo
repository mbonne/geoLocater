#!/bin/bash

###
##
##            Name:  geoLocation
##         Purpose:  Commandline tool to Find Country location from devices WAN IP using API call and check against a list of Country names.
##                   If script just run, will use your current WAN IP. If ip address specified will process that.
##         Created:  2019-12-01
##   Last Modified:
##         Version:  1
##          Source: https://stackoverflow.com/questions/12030316/nesting-if-in-a-for-loop
##                  https://www.programiz.com/python-programming/nested-dictionary
##                  https://stackoverflow.com/questions/50843960/curl-json-to-output-only-one-object
##                  https://stedolan.github.io/jq/tutorial/
###

##===========================VARIABLES============================##
## Finds WAN IP via dig command using opendns. Captures IP address only.

if test -z "$1"; then
  ##Variable is empty, will set your current WAN IP
  wanIP=$(/usr/bin/dig @resolver1.opendns.com ANY myip.opendns.com +short)
else
  ##Variable is NOT empty, will use the IP address specified as first argument when running command
  wanIP=$1
fi

## I have no affiliate to cli.fyi and this script will break if website is down.
ipJson=$(curl -s -X GET https://cli.fyi/"$wanIP")

## Pipe output to python allows for manupulation of GET results json data. The print obj part is printing the nested object by using two square bracketed values.
echo -e "\n"
echo -e "IP Address: \t$wanIP"
echo -e "Country: \t$(echo "$ipJson" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["country"]')"
echo -e "continent: \t$(echo "$ipJson" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["continent"]')"
echo -e "Organisation: \t$(echo "$ipJson" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["organisation"]')"
latitude=$(echo -e "$(echo "$ipJson" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["latitude"]')")
longitude=$(echo -e "$(echo "$ipJson" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["longitude"]')")
echo -e "PTR: \t\t$(dig -x "$wanIP" +short)"
echo -e "\n"
googleMap="https://maps.google.com/?ie=UTF8&hq=&ll=$longitude,$latitude&z=13"
virusTotal="https://www.virustotal.com/gui/ip-address/$wanIP"

##https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script
PS3='Type Number to open Website: '
options=("$googleMap" "$virusTotal" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "$googleMap")
      echo "Opening Google Maps" && open "$googleMap"
      break
      ;;
    "$virusTotal")
      echo "Opening Virus Total" && open "$virusTotal"
      break
      ;;
    "Quit")
      break
      ;;
    *) echo "$REPLY is not a valid option";;
  esac
done


exit $?
