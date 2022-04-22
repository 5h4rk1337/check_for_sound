# check_for_sound.sh
 This script turns a RaspberryPis GPIO on and off if sound is playing or not.


## check_for_sound.service
This file is for systemd so you can run the script by boot.
- Copy to `/etc/systemd/system`
- Enable with `sudo systemctl enable check_for_sound.service`
