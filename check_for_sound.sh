#!/bin/bash

if [ ! -d "/sys/class/gpio/gpio18" ]; then
	echo "18" > /sys/class/gpio/export
	echo "out" > /sys/class/gpio/gpio18/direction
fi




DIR='/proc/asound/card1/pcm0p/sub0/status'
GPIO_ON='echo "1" > /sys/class/gpio/gpio18/value'
GPIO_OFF='echo "0" > /sys/class/gpio/gpio18/value'

status="closed"
check_gpio=""
i=0
i_target=57

while true
do
    current_status=`head -n 1 $DIR`
    check_gpio=`cat /sys/class/gpio/gpio18/value`

    if [ "$status" == "$current_status" ]; then
#	echo ">>> No sound is playing"			#debug
	if [ "$i" == "$i_target" ]; then
		if [ "$check_gpio" !=  "0" ]; then
#			echo ">>> turn Speaker off"	#debug
			eval "$GPIO_OFF"
		fi
	else
		i=$[$i+1]
	fi
#    echo i is $i					#debug
    sleep 1

    else
#    echo ">>> Sound is playing"			#debug
	if [ "$check_gpio" !=  "1" ]; then
#	echo ">>> turn Speaker on"			#debug
	eval "$GPIO_ON"
	fi
    i=0
    sleep 5
    fi

done
