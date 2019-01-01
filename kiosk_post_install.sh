#kiosk script

#get the latest version of this file:
# wget https://github.com/marcwagner/install_scripts/raw/master/kiosk_post_install.sh

###################################
#         setting up users        #
###################################

echo setting up user accounts
# nothing - use user pi to auto-login


###################################
#         Basic cleanup          #
###################################

echo purging unneeded apps

sudo apt-get purge wolfram-engine scratch scratch2 nuscratch sonic-pi idle3 -y
sudo apt-get purge smartsim java-common minecraft-pi libreoffice* -y

rm -rf ~/Documents ~/magPi ~/Music ~/Pictures ~/Public ~/Templates ~/Videos


###################################
#      install and unistall apps  #
###################################

echo installing new apps
sudo apt-get install \
    ssh git gitk gitg curl \
    dkms python3-pip nmap \
    nfs-kernel-server \
    xdotool unclutter sed

sudo apt-get clean
sudo apt-get autoremove -y

echo updating system
sudo dpkg --configure -a > /dev/null
sudo apt-get -qq update  > /dev/null
sudo apt-get -qq upgrade > /dev/null



###################################
#      install python libraries   #
###################################

echo installing python libraries
sudo pip3 install \
     paho-mqtt

###################################
#      configuring the host       #
###################################
echo configuring the host
echo '... setting hostname'
echo -e 'magic-mirror' | sudo tee /etc/hostname
echo -e '127.0.0.1     magic-mirror' | sudo tee -a /etc/hosts


#####################################
#   some screensaver stuff          #
#####################################

echo '... setting screen orientation'
echo -e '# configuration for magic mirror\ndisplay_rotate=1\navoid_warnings=1' | sudo tee -a /boot/config.txt

# expected output
#  # configuration for magic mirror
#  display_rotate=1
#  avoid_warnings=1

echo '...disabling screensaver and screen_blanking'

mkdir -p /home/pi/.config/lxsession/LXDE-pi/
touch /home/pi/.config/lxsession/LXDE-pi/autostart

echo -e '@lxpanel --profile LXDE-pi\n@pcmanfm --desktop --profile LXDE-pi\n#@xscreensaver -no-splash\n@point-rpi\n@bash /home/pi/scripts/kiosk.sh' |  tee -a /home/pi/.config/lxsession/LXDE-pi/autostart

sudo iwconfig wlan0 power off

###################################
#       setting up VNC server     #
###################################
echo setting up vnc server

mkdir ~/.config/autostart
ln -s ~/projects/install_scripts/magicmirror/x11vnc.desktop ~/.config/autostart/x11vnc.desktop

echo setting up password
mkdir ~/.vnc
ln -s ~/projects/install_scripts/magicmirror/passwd ~/.vnc/passwd

x11vnc --usepw


#####################################
# Unclutter - removes mouse pointer #
#####################################

unclutter -idle 0.5 -root &



#####################################
# installing snips voice platform   #
#####################################

sudo apt-get update
sudo apt-get install -y dirmngr
sudo bash -c  'echo "deb https://raspbian.snips.ai/$(lsb_release -cs) stable main" > /etc/apt/sources.list.d/snips.list'
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys D4F50CDCA10A2849
sudo apt-get update
sudo apt-get install -y snips-platform-voice


#####################################
#     installing services           #
#####################################

mkdir ~/scripts
cd ~/scripts

wget https://github.com/marcwagner/install_scripts/raw/master/magicmirror/pi@mm_switch.service
wget https://github.com/marcwagner/install_scripts/raw/master/magicmirror/mm_switch.py

wget https://github.com/marcwagner/p1_python/raw/master/pi@p1_reader.service
wget https://github.com/marcwagner/p1_python/raw/master/p1_reader.py
wget https://github.com/marcwagner/p1_python/raw/master/serial_reader.py
wget https://github.com/marcwagner/p1_python/raw/master/converter.py

echo activating all the service files
chmod +x p1_reader.py mm_switch.py
sudo chown root:root pi@*
sudo mv pi@* /etc/systemd/system/

echo enabling services at boot
sudo systemctl enable pi@mm_switch.service pi@p1_reader.service
sudo systemctl daemon-reload # Run if .service file has changed
sudo systemctl start pi@mm_switch.service pi@p1_reader.service
