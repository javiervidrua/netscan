#!/bin/bash

# 2019 Javier Vidal

# Functions
usage-f(){
	echo 'USAGE: ./netscan.sh <IP>/<range>'
}

ping-f(){
	ping -c 1 $1 >/dev/null 2>&1
	[ $? -eq 0 ] && echo IP: $1
}

check-f(){
	if [ -z $(echo "$1" | grep -E '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b/[8\|16\|24]') ]; then
		echo '[-] Error: Invalid IP format'
		echo ''
		usage-f
		exit
	fi
}

# Main
check-f $1

IP=$(echo $1 | cut -d '/' -f 1)
RANGE=$(echo $1 | cut -d '/' -f 2)
I=1

case $RANGE in
	8)
		echo "[*] IP: $IP - RANGE: $RANGE"
		echo '[*] Starting scan...'
		START=$SECONDS
		echo '[*] This will take a really long time...'
		HALFIP=$(echo $IP | cut -d '.' -f 1)
		for ADDRESS in $HALFIP.{1..255}{1..255}.{1..255}; do
			ping-f $ADDRESS &
			PIDS[${I}]=$!
			I=$(($I+1))
		done
                ;;
	16)
		echo "[*] IP: $IP - RANGE: $RANGE"
		echo '[*] Starting scan...'
		START=$SECONDS
		echo '[*] This will take a few minutes...'
		HALFIP=$(echo $IP | cut -d '.' -f 1,2)
		for ADDRESS in $HALFIP.{1..255}.{1..255}; do
			ping-f $ADDRESS &
			PIDS[${I}]=$!
			I=$(($I+1))
		done
		;;
	24)
		echo "[*] IP: $IP - RANGE: $RANGE"
		echo '[*] Starting scan...'
		START=$SECONDS
		echo '[*] This will be fast'
		HALFIP=$(echo $IP | cut -d '.' -f 1,2,3)
		for ADDRESS in $HALFIP.{1..255}; do
			ping-f $ADDRESS &
			PIDS[${I}]=$!
			I=$(($I+1))
		done
		;;
	*)
		echo '[-] Error: Invalid option'
		usage-f
		exit
esac

for PID in ${PIDS[*]}; do
	wait $PID
done

echo "[*] Scan finished in $(($SECONDS-$START)) seconds"
