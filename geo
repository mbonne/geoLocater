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
##                  https://stackoverflow.com/questions/18709962/regex-matching-in-a-bash-if-statement
###

##===========================VARIABLES============================##
## Setup the colour codes.
RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

## Check if you have jq installed. Can do this via $ brew install jq
if [ ! -f "/usr/local/bin/jq" ]; then
  echo -e "${RED}you need to install /usr/local/bin/jq to run this script${NOCOLOR}"
  exit 1
fi

pat="[a-zA-Z]"
## Finds WAN IP via dig command using opendns. Captures IP address only.
if test -z "$1"; then
  ##Variable is empty, will set your current WAN IP
  wanIP=$(/usr/bin/dig @resolver1.opendns.com ANY myip.opendns.com +short)
elif [[ $1 =~ $pat ]]; then
  domainName=$(/usr/bin/dig "$1" +short)
  echo -e "hostname has the following IP:"
  echo -e "$domainName"
  wanIP=$(echo -e "$domainName" | head -1)
  if [[ -z $wanIP ]]; then
    echo -e "${RED}$1 could not be resolved${NOCOLOR}"
    exit 1
  fi
else
  wanIP=$1
fi


## I have no affiliate to cli.fyi and this script will break if website is down.
ipJson=$(curl -s -X GET https://cli.fyi/"$wanIP")

if echo -e "$ipJson" | grep "error" &> /dev/null; then
  echo -e "$ipJson" | jq .error
  echo -e "${RED}Make sure to enter a valid public IP address.\nRun command on its own to use your current WAN IP address.${NOCOLOR}"
  exit 1
elif [ "$(echo -e "$ipJson" | jq .data.isIpInPrivateRange)" = "true" ]; then
  echo -e "${RED}$wanIP Cannot geo locate a private IP address. Know your RFC1918!${NOCOLOR}"
  exit 1
#elif [ "$(echo -e "$ipJson" | jq .data.dns)" = "true" ]; then
#  echo -e "${RED}You targeted a domain name. Pick an IP address from below.${NOCOLOR}"
#  echo -e "$ipJson"
#  exit 1
else




  ## Pipe output to python allows for manupulation of GET results json data. The print obj part is printing the nested object by using two square bracketed values.
  echo -e "\n"
  echo -e "IP Address: \t$wanIP"
  echo -e "Country: \t$(echo "$ipJson" | jq -r .data.country)"
  #echo -e "Country: \t$(echo "$ipJson" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["country"]')"
  echo -e "Country: \t$(echo "$ipJson" | jq -r .data.continent)"
  #echo -e "continent: \t$(echo "$ipJson" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["continent"]')"
  echo -e "Country: \t$(echo "$ipJson" | jq -r .data.organisation)"
  #echo -e "Organisation: \t$(echo "$ipJson" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["organisation"]')"
  latitude=$(echo -e "$(echo "$ipJson" | jq -r .data.latitude)")
  longitude=$(echo -e "$(echo "$ipJson" | jq -r .data.longitude)")
  #latitude=$(echo -e "$(echo "$ipJson" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["latitude"]')")
  #longitude=$(echo -e "$(echo "$ipJson" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["longitude"]')")
  echo -e "PTR: \t\t$(dig -x "$wanIP" +short)"
  echo -e "\n"

fi


##Create a couple more variables:
googleMap="https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&z=13"
#googleMap="https://maps.google.com/?ie=UTF8&hq=&ll=$longitude,$latitude&z=13"
virusTotal="https://www.virustotal.com/gui/ip-address/$wanIP"

##Display the interactive menu:
##https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script
PS3="Type Number to open Website: "
options=("$googleMap" "$virusTotal" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "$googleMap")
      echo -e "${GREEN}Opening Google Maps${NOCOLOR}" && open "$googleMap"
      break
      ;;
    "$virusTotal")
      echo -e "${GREEN}Opening Virus Total${NOCOLOR}" && open "$virusTotal"
      break
      ;;
    "Quit")
      break
      ;;
    *) echo -e "${RED}$REPLY is not a valid option${NOCOLOR}";;
  esac
done


exit $?
