#kiosk script

###################################
#         setting up users        #
###################################

echo purging unneeded apps


sudo adduser marc sudo
sudo adduser kiosk


###################################
#         Basic Update            #
###################################

echo purging unneeded apps

sudo apt-get purge wolfram-engine scratch scratch2 nuscratch sonic-pi idle3 -y
sudo apt-get purge smartsim java-common minecraft-pi libreoffice* -y



###################################
#      install and unistall apps  #
###################################

echo installing new apps
sudo apt-get -qq install \
    ssh git git-secret gitk gitg curl \
    dkms python3-pip nmap \
    nfs-kernel-server \
    xdotool unclutter sed

sudo apt-get clean
sudo apt-get autoremove -y

echo updating system
sudo dpkg --configure -a > /dev/null
sudo apt-get -qq update  > /dev/null
sudo apt-get -qq upgrade > /dev/null




unclutter -idle 0.5 -root &

#
#sed -i 's/"@xscreensaver -no-splash"/"#@xscreensaver -no-splash"/'
#@bash /home/kiosk/kiosk.sh

rotate screen:
# /boot/config.txt
# lcd_rotate=2


#sudo userdel -r pi
