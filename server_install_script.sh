#! /bin/bash

# add repositories
echo adding repositiries
sudo add-apt-repository -y "deb http://dl.google.com/linux/chrome/deb/ stable main"



# basic update
echo updating system
sudo apt-get -yq --force-yes update
sudo apt-get -yq --force-yes upgrade



#install apps
echo installing new apps
sudo apt-get -yq install \
    git gitk gitg curl gparted \
    dkms python3-pip


# uninstall apps
sudo apt-get -yq remove \


#install python libraries
echo installing python libraries
sudo pip3 install


#update dotfiles
echo installing configuration files
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' ~/.bashrc


# update system files and set up backup
echo installing foto backup system
echo - creating user fotosync
sudo useradd --home /home/fotosync fotosync
echo - adding mounts to fstab 
echo '//192.168.1.130/fotos /media/fotos                    cifs    username=foto_sync,password=Foto_1234,rw,noexec   0       0' | sudo tee -a /etc/fstab
echo '//192.168.1.130/Documents /media/documents            cifs    username=foto_sync,password=Foto_1234,rw,noexec   0       0' | sudo tee -a /etc/fstab
echo - creating mount points
sudo mkdir /media/fotos && sudo chown fotosync:fotosync /media/fotos
sudo mkdir /media/documents && sudo chown fotosync:fotosync /media/documents
sudo su - fotosync -c 'mkdir scripts'
sudo su - fotosync -c 'mkdir documuments/monthly; mkdir documents/daily'
sudo su - fotosync -c 'mkdir fotos/monthly; mkdir fotos/daily'


sudo mount -a



    
# folders
mkdir ~/projects
