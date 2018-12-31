#! /bin/bash

###################################
#         add repositories        #
###################################

echo adding repositories
# sudo add-apt-repository -y "deb http://dl.google.com/linux/chrome/deb/ stable main"
#sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

###################################
#         Basic Update            #
###################################

echo updating system
sudo dpkg --configure -a > /dev/null
sudo apt-get -qq update  > /dev/null
sudo apt-get -qq upgrade > /dev/null

###################################
#      install and unistall apps  #
###################################

echo installing new apps
sudo apt-get -qq install \
    ssh git gitk gitg curl gparted \
    dkms python3-pip nmap \
    xscreensaver x11-xserver-utils x11vnc

sudo apt-get -y -qq remove \
    libreoffice minecraft-pi
    

###################################
#      install python libraries   #
###################################

echo installing python libraries
sudo pip3 install \


###################################
#      Updating dotfiles          #
###################################
echo installing configuration files
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' ~/.bashrc


###################################
#      Setting up Github          #
###################################
    
mkdir ~/projects 

echo setting up github
git config --global user.email "wagner.marc@gmail.com"
git config --global user.name "Marc Wagner"


echo downloading the github files
git -C ~/projects clone git@github.com:marcwagner/install_scripts.git



###################################
#      configuring the host       #
###################################
echo configuring the host
echo '... setting hostname'
echo -e 'hall_mirror' | sudo tee -a /etc/hostname

echo '... setting screen orientation'
echo -e '# configuration for magic mirror\n\ndisplay_rotate=1\navoid_warnings=1' | sudo tee -a /boot/config.txt

# expected output
#  # configuration for magic mirror
#  display_rotate=1
#  avoid_warnings=1


echo '...disabling screensaver and screen_blanking'

echo -e 'consoleblank=0' | sudo tee -a /boot/cmdline.txt
rm ~/.xscreensaver
ln -s ~/projects/install_scripts/magicmirror/.xscreensaver ~/.xscreensaver
# xscreensaver does not need a restart because it automatically reloads if the config file has changed

echo '...disabling power manager for wifi'
cat << EOF | sudo tee /etc/network/if-up.d/off-power-manager
#!/bin/sh
# off-power-manager - Disable the internal power manager of the (built-in) wlan0 device
# Added by MagicMirrorSetup
iw dev wlan0 set power_save off
EOF

sudo chmod 755 /etc/network/if-up.d/off-power-manager
sudo /etc/init.d/networking restart


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

###################################
#       setting up magic mirror   #
###################################
echo setting up magic mirror

echo '... downloading and installing software'
bash -c "$(curl -sL https://raw.githubusercontent.com/MichMich/MagicMirror/master/installers/raspberry.sh)"

sudo npm install -g pm2
ln -s ~/projects/install_scripts/magicmirror/mm.sh ~/mm.sh


echo '... downloading and installing modules'
git -C ~/MagicMirror/modules clone git@github.com:jclarke0000/MMM-MyWeather.git
git -C ~/MagicMirror/modules clone git@github.com:Blastitt/DailyXKCD.git



echo '... configuring modules'
rm ~/MagicMirror/config/config.js
ln -s ~/projects/install_scripts/magicmirror/config.js ~/MagicMirror/config/config.js

echo '... starting up server'
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u pi --hp /home/pi
pm2 start mm.sh
pm2 save




###################################
#       setting up screen_pir     #
###################################
echo screen-off tools

echo '... setting up script'
ln -s ~/projects/install_scripts/magicmirror/magic_mirror_pir_switch.py .
ln -s ~/projects/install_scripts/magicmirror/start_pir .

echo '... auto-starting script at startup'
(crontab -l 2>/dev/null; echo "@reboot /bin/bash /home/marc/start_pir") | crontab - 

