#! /bin/bash


## hostname
## dynamically config ap channel
## rename ssid on the fly



###################################
#         set hostname           #
###################################

echo
echo setting hostname
echo

echo 'robot1' | sudo tee /etc/hostname

sed -i 's/127.0.0.1	localhost/127.0.0.1	robot1/' /etc/hosts


###################################
#         add repositories        #
###################################

echo
echo adding repositories
echo
#sudo add-apt-repository -y "deb http://dl.google.com/linux/chrome/deb/ stable main"
#sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

###################################
#         Basic Update            #
###################################
sudo sed -i 's/127.0.0.1	localhost/127.0.0.1	robot1/' /etc/hosts
echo updating system
sudo dpkg --configure -a > /dev/null
sudo apt-get -qq update  > /dev/null
sudo apt-get -qq dist-upgrade > /dev/null
#sudo apt-get -qq upgrade > /dev/null

###################################
#      install and unistall apps  #
###################################

echo removing pre-installed apps

sudo apt-get purge dns-root-data

echo installing new apps
sudo apt-get -qq install \
    ssh git gitk gitg curl gparted \
    dkms python3-pip python3-bottle nmap \
    dnsmasq hostapd bridge-utils	

sudo apt-get -y -qq remove \

# stopping dsnmasq and hostapd
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd


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

echo
echo downloading the github files
echo
## remember to use ssh
git -C ~/projects clone git@github.com:marcwagner/install_scripts.git



###################################
#      Setting Up Accespoint      #
###################################

echo
echo Setting up Access point
echo stopping Access point # allready done
echo 
#sudo systemctl stop dnsmasq
#sudo systemctl stop hostapd
sudo systemctl disable hostapd
sudo systemctl disable dnsmasq



echo
echo replacing configuration files
echo 
#sudo cp projects/install_scripts/ap_config/dhcpcd.conf /etc/dhcpcd.conf    
sudo cp projects/install_scripts/ap_config/dnsmasq.conf /etc/dnsmasq.conf           # 
sudo cp projects/install_scripts/ap_config/hostapd.conf /etc/hostapd/hostapd.conf   # access point config files
sudo cp projects/install_scripts/ap_config/hostapd /etc/default/hostapd
sudo cp projects/install_scripts/ap_config/sysctl.conf /etc/sysctl.conf
#sudo cp projects/install_scripts/ap_config/iptables.ipv4.nat /etc/iptables.ipv4.nat
#sudo cp projects/install_scripts/ap_config/interfaces /etc/network/interfaces


###################################################
#      Setting Up Station as systemd service      #
###################################################


echo configuring hotspot switching service

sudo cp projects/install_scripts/ap_config/autohotspotN  /usr/bin/autohotspotN
sudo cp projects/install_scripts/ap_config/autohotspot.service /etc/systemd/system/autohotspot.service
sudo systemctl enable autohotspot.service

sudo chmod +x /usr/bin/autohotspotN

crontab -l | grep -q 'sudo /usr/bin/autohotspotN'  && echo 'crontab entry allready present' || (crontab -l 2>/dev/null; echo "*/5 * * * * sudo /usr/bin/autohotspotN") | crontab -


###################################################
#      Setting Up pi_robot                        #
###################################################


sudo chmod a+r /usr/local/lib/netscape/mime.types

    
###################################
#      cleaning up home dir       #
###################################


rm -rf python_games/




