#!/bin/bash
# This script is used to check if sound is playing and control the speaker on/off by GPIO pin 18

# Check if gpiod package is installed
if [ ! -f "/usr/bin/gpioset" ]; then
	echo "ERROR: Please install gpiod package first"
fi

# Verbose/debug flag
VERBOSE=0
while getopts "v" opt; do
	case "$opt" in
		v) VERBOSE=1 ;;
	esac
done

dbg() {
	if [ "$VERBOSE" -eq 1 ]; then
		echo "$@"
	fi
}

# MARK: Functions
# Check if sound is playing. Return 1 if sound is on, otherwise return 0
check_sound() {
	status=`head -n 1 /proc/asound/card2/pcm0p/sub0/status`
	if [ "$status" == "closed" ]; then
		echo "0"
	elif [ "$status" == "state: RUNNING" ]; then
		echo "1"
	fi
}

# Set GPIO pin 18 to high
gpio_on() {
		gpioset -c gpiochip0 18=1 &
		GPIO_PID=$!
		echo "Turn on speaker, GPIO PID: $GPIO_PID"
}

# Set GPIO pin 18 to low
gpio_off() {
		gpioset -c gpiochip0 18=0 &
		GPIO_PID=$!
		echo "Turn off speaker, GPIO PID: $GPIO_PID"
}

# Get GPIO pin 18 status
gpio_status() {
	gpioget --numeric -c gpiochip0 18
}

# Mark: Wait for sound card to be ready
ready=0
while [ $ready -eq 0 ]; do
	if [ -f "/proc/asound/card2/pcm0p/sub0/status" ]; then
		ready=1
	else
		echo "Waiting for sound card to be ready..."
		sleep 3
	fi
done

# MARK: Main loop
delay=60
timer=0
step=2
GPIO_PID=""
dbg "GPIO status:$(gpio_status)"
while true
do
	current_status=$(check_sound) # save the current status of sound

	if [[ "$current_status" == "1" && "$GPIO_PID" == "" ]]; then # if sound is on, turn on the speaker and reset the timer
		#$gpio_status=$()
		gpio_on
		timer=$delay
	fi

	if [[ "$current_status" == "0" && "$timer" -le 0 && "$GPIO_PID" != "" ]]; then # if sound is off and timer is expired, turn off the speaker
		kill $GPIO_PID 2>/dev/null || true
		gpio_off
		kill $GPIO_PID 2>/dev/null || true
		sleep 0.1 # wait for the GPIO command to take effect
		GPIO_PID=""
		dbg "GPIO status:$(gpio_status)"
	fi
	
	sleep $step
	if [[ "$current_status" == "0" && "$timer" -gt 0 ]]; then
		timer=$[$timer-$step] # decrease the timer by step
	fi
	dbg "Sound status: $current_status, Timer: $timer, GPIO PID: $GPIO_PID"
done
