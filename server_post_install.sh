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
    ssh git git-secret gitk gitg curl gparted \
    dkms python3-pip rygel nmap \
    nfs-kernel-server \
    isc-dhcp-server

sudo apt-get -y -qq remove \


###################################
#      install python libraries   #
###################################

echo installing python libraries
sudo pip3 install \
	homeassistant

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
git -C ~/projects clone git@github.com:pi-hole/pi-hole.git


###################################
#       setting up nfs shares     #
###################################
echo setting up nfs shares to laptop_marc

echo - editing /etc/exports
echo '/home/marc/ 192.168.1.183(rw,sync,no_root_squash,no_subtree_check) ' | sudo tee -a /etc/exports

echo - starting nfs-server
sudo systemctl start nfs-kernel-server.service

###################################
#      Setting up backup script   #
###################################


echo installing foto backup system

echo - creating user fotosync
sudo useradd -m -d /home/fotosync fotosync

echo - adding mounts to fstab 
echo '//192.168.1.180/fotos /media/fotos         cifs    vers=2.0,username=foto_sync,password=Foto_1234,uid=1001,x-systemd.automount,noauto,noexec,user   0       0' | sudo tee -a /etc/fstab
echo '//192.168.1.180/Documents /media/documents  cifs vers=2.0,username=foto_sync,password=Foto_1234,uid=1001,x-systemd.automount,noauto,noexec,user   0       0' | sudo tee -a /etc/fstab 
echo - creating mount points
sudo mkdir /media/fotos && sudo chown fotosync:fotosync /media/fotos
sudo mkdir /media/documents && sudo chown fotosync:fotosync /media/documents

echo - creating home dir folder structure
sudo mkdir /home/fotosync/scripts
sudo mkdir /home/fotosync/documents
sudo mkdir /home/fotosync/fotos
sudo mkdir /home/fotosync/documents/monthly
sudo mkdir /home/fotosync/documents/daily
sudo mkdir /home/fotosync/fotos/monthly
sudo mkdir /home/fotosync/fotos/daily

echo - linking scripts

sudo ln -s ~/projects/install_scripts/backups/* \
                 /home/fotosync/scripts/

echo - setting the correct file ownerships
sudo chown -R fotosync:fotosync /home/fotosync/*

echo - mounting laptop fotos
sudo mount -a

echo - setting crontab
sudo su -c '(crontab -l 2>/dev/null; echo " /30 *  *   *   *     /home/fotosync/scripts/daily_laptop_backup_script.sh") | crontab -' fotosync


###################################
#   setting up rygel upnp server  #
###################################

echo setting up upnp sharing
echo creating user rygel
sudo useradd -m rygel
echo - setting up share folders
sudo mkdir /share
sudo mkdir /share/music/

sudo cp ~/projects/install_scripts/upnp/rygel.conf /etc/rygel.conf
sudo cp ~/projects/install_scripts/upnp/rygel@rygel.service /etc/systemd/system/rygel@rygel.service

sudo systemctl --system daemon-reload
sudo systemctl enable rygel@rygel.service
sudo systemctl start rygel@rygel.service



###################################
#  setting up pi-hole add-blocker #
###################################

echo installing pi-hole
echo - copying configuration files

sudo mkdir /etc/pihole/
sudo cp ~/projects/install_scripts/pihole/setupVars.conf /etc/pihole/setupVars.conf
echo - downloading and running the pihole setup script
curl -L https://install.pi-hole.net | sudo bash /dev/stdin --unattended




###################################
#         install dhcp server     #
###################################

echo setting up dhcp server
act_eth_device=$(ip link show | grep 'state UP' | awk '{print substr($2, 1, length($2)-1)}' | sed -n 1p)


echo setting dchp server to listen op port $act_eth_device
sudo sed -i 's/INTERFACESv4=""/INTERFACESv4="$act_eth_device"/' /etc/default/isc-dhcp-server
echo configuring dhcp server
sudo cp ~/projects/install_scripts/dhcp_server/dhcpd.conf /etc/dhcpd/dhcpd.conf
sudo cp ~/projects/install_scripts/dhcp_server/interfaces /etc/network/interfaces

echo restarting dhcp server
systemctl restart isc-dhcp-server



###################################
#   setting up homeassistant      #
###################################


echo setting up homeassistant
echo - creating user homeassistant
sudo useradd -m homeassistant
sudo mkdir /home/homeassistant/.homeassistant/
sudo mkdir /home/homeassistant/scripts/

echo - copying congiguration files
cd /home/homeassistant/.homeassistant/
sudo ln -s ~/projects/install_scripts/homeassistant/configuration.yaml \
                 /home/homeassistant/.homeassistant/configuration.yaml 
sudo ln -s ~/projects/install_scripts/homeassistant/automations.yaml \
                 /home/homeassistant/.homeassistant/automations.yaml 
sudo ln -s ~/projects/install_scripts/homeassistant/groups.yaml \
                 /home/homeassistant/.homeassistant/groups.yaml 
sudo ln -s ~/projects/install_scripts/homeassistant/known_devices.yaml \
                 /home/homeassistant/.homeassistant/known_devices.yaml
sudo ln -s ~/projects/install_scripts/homeassistant/sene.yaml \
                 /home/homeassistant/.homeassistant/scene.yaml 		 
sudo ln -s ~/projects/install_scripts/homeassistant/secrets.yaml \
                 /home/homeassistant/.homeassistant/secrets.yaml 

sudo chown -h homeassistant:homeassistant /home/homeassistant/.homeassistant/*.yaml

sudo cp ~/projects/install_scripts/homeassistant/homeassistant@homeassistant.service \
                             /etc/systemd/system/homeassistant@homeassistant.service
sudo cp ~/projects/install_scripts/homeassistant/check_hass_errors.sh \
                     /home/homeassistant/scripts/check_hass_errors.sh

echo - starting homeassistant service
sudo systemctl --system daemon-reload
sudo systemctl enable homeassistant@homeassistant.service
sudo systemctl start homeassistant@homeassistant.service

echo - setting up error_check script
sudo su -c '(crontab -l 2>/dev/null; echo "*/10 * * * * /home/homeassistant/scripts/check_hass_errors.sh") | crontab -' root
