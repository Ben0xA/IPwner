#!/bin/bash
# IPwner - IP Owner Lookup
# Written by: Ben0xA
# v. 0.0.1

echo "_______________                              "
echo "____  _/__  __ \__      _____________________"
echo " __  / __  /_/ /_ | /| / /_  __ \  _ \_  ___/ "
echo "__/ /  _  ____/__ |/ |/ /_  / / /  __/  /    "
echo "/___/  /_/     ____/|__/ /_/ /_/\___//_/     "
echo ""
echo "IP Owner Lookup"
echo "Written by: Ben0xA - v. 0.0.1"
echo ""

function lookup_ip()
{
	resp=$(whois -h whois.arin.net "$1")
	referral=$(echo "$resp" | grep "Found a referral to")	
	orgname=""
	netname=""
	country=""
	cidr=""				
	if [ -n "$referral" ]
	then
		orgname=$(echo "$resp" | grep -m 1  "org-name" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
		netname=$(echo "$resp" | grep -m 1  "netname" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
		country=$(echo "$resp" | grep -m 1 "country" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
		cidr=$(echo "$resp" | grep -m 1  "inetnum" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
	else
		reassigned=$(echo "$resp" | grep "Reassigned")
		if [ -n "$reassigned" ]
		then
			orgname=$(echo "$resp" | grep -A999 "Reassigned" | grep "Customer" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
			if [ "$orgname" == "" ]
			then
				orgname=$(echo "$resp" | grep -A999 "Reassigned" | grep "OrgName" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
			fi
			netname=$(echo "$resp" | grep -A999 -B6 "Reassigned" | grep "NetName" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
			country=$(echo "$resp" | grep -A999 "Reassigned" | grep "Country" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
			cidr=$(echo "$resp" | grep -A999 -B6 "Reassigned" | grep "CIDR" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')		
		else	
			orgname=$(echo "$resp" | grep -m 1 "Organization" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
			netname=$(echo "$resp" | grep -m 1  "NetName" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
			country=$(echo "$resp" | grep -m 1 "Country" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
			cidr=$(echo "$resp" | grep -m 1  "CIDR" | cut -d":" -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')		
		fi
	fi
	printf "%-15.15s | %-30.30s | %-15.15s | %-10.10s | %-25s\n" "$1" "$orgname" "$netname" "$country" "$cidr"
}

if [ -z "$1" ] || [ $1 == '-h' ]
then
	echo "Usage: ipwner.sh <ip>"
	echo "       ipwner.sh <filename>"
else
	printf "%-15.15s | %-30.30s | %-15.15s | %-10.10s | %-25.25s\n" "IP" "Organization" "Network Name" "Country" "CIDR"
	printf "%-15.15s | %-30.30s | %-15.15s | %-10.10s | %-25.25s\n" "--" "------------" "------------" "-------" "----"
	if [[ -f $1 ]]
	then
		for entry in $(cat $1 | sort -u); do
			ips=$(dig +short $entry)
			for ip in $ips; do
				lookup_ip $ip
			done
		done
	else
		lookup_ip "$1"
	fi
fi