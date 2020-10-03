#!/bin/bash

#MIT License

#Copyright (c) 2020 Javier Vidal Ruano

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

# Functions
printUsage(){
	echo 'USAGE: ./netscan.sh <IP>/<range>'
}

pingIP(){
	ping -c 1 $1 >/dev/null 2>&1
	[ $? -eq 0 ] && echo IP: $1
}

checkIP(){
	if [ -z $(echo "$1" | grep -E '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b/[8\|16\|24]') ]; then
		echo '[-] Error: Invalid IP format'
		echo ''
		usage-f
		exit
	fi
}

# Main
checkIP $1

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
			pingIP $ADDRESS &
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
			pingIP $ADDRESS &
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
			pingIP $ADDRESS &
			PIDS[${I}]=$!
			I=$(($I+1))
		done
		;;
	*)
		echo '[-] Error: Invalid range'
		printUsage
		exit
esac

for PID in ${PIDS[*]}; do
	wait $PID
done

echo "[*] Scan finished in $(($SECONDS-$START)) seconds"
