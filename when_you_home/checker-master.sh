#!/bin/bash

MAIL_TO=YOUR_EMAIL 
MAC_LIST=/root/when_you_home/mac_list

sendmail()
{
	nick=$1
	op=$2
	date=$(date "+%Y-%m-%d %H:%M:%S")
	contents="Date: $date"
	echo $contents | mutt $MAIL_TO -s "$nick is $op"
	
	#LOG
	echo "[ $date ]: $nick is $op"
}

while read line
do
	mac=$(echo $line | awk '{print $1}')
	nick=$(echo $line | awk '{print $2}')
	#echo $mac $nick
	res=$(cat /tmp/dhcp.leases | grep $mac | wc -l)
	if [ "$res" = "0" ]; then
		continue
	fi
	
	res1=$(iwinfo ra0 assoclist | grep -i $mac | wc -l)
	res2=$(iwinfo rai0 assoclist | grep -i $mac | wc -l)
	lock_online="/root/.$mac.online"
	if [ "$res1" = "1" -o "$res2" = "1" ]; then
		if [ -f $lock_online ]; then
			continue
		else
			sendmail $nick "online"
			touch $lock_online
		fi
	else
		if [ -f $lock_online ]; then
			sendmail $nick "offline"
			rm -f $lock_online
		fi
	fi
done < $MAC_LIST
