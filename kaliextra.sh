#!/bin/sh


### Functions ###

error() { clear; printf "ERROR:\\n%s\\n" "$1"; exit;}

# To ensure not dpkg errors pop up.
killall apt

welcomemsg() { \
	apt install dialog -y
        dialog --title "Welcome!" --msgbox "Welcome to The's Kali Extra  Script!\\n\\nThis script will automatically make your Kali Extra!" 10 60
        }

installdepedencies(){
dialog --infobox "Installing Updates and Depedencies..." 4 50
apt install dialog -y
apt update -y
apt upgrade -y
apt dist-upgrade -y
}


getuserandpass() { \
        # To-Do: Figure out how to automatically make this root.
        name=$(dialog --inputbox "First, set a root password, please type 'root'." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
        while ! echo "$name" | grep "root" >/dev/null 2>&1; do
                name=$(dialog --no-cancel --inputbox "Username not valid. Please type root." 10 60 3>&1 1>&2 2>&3 3>&1)
        done
        pass1=$(dialog --no-cancel --passwordbox "Enter a password for root." 10 60 3>&1 1>&2 2>&3 3>&1)
        pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
        while ! [ "$pass1" = "$pass2" ]; do
                unset pass2
                pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
                pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
done ;}

usercheck() { \
        ! (id -u "$name" >/dev/null) 2>&1 ||
        dialog --colors --title "WARNING!" --yes-label "CONTINUE" --no-label "No wait..." --yesno "The user \`$name\` already exists on this system. LARBS can install for a user already existing, but it will \\Zboverwrite\\Zn any conflicting settings/dotfiles on the user account.\\n\\nLARBS will \\Zbnot\\Zn overwrite your user files, documents, videos, etc., so don't worry about that, but only click <CONTINUE> if you don't mind your settings being overwritten.\\n\\nNote also that LARBS will change $name's password to the one you just gave." 14 70
        }

preinstallmsg() { \
        dialog --title "Let's get this party started!" --yes-label "Let's go!" --no-label "No, nevermind!" --yesno "The rest of the installation will now be totally automated, so you can sit back and relax.\\n\\nIt will take some time, but when done, you can relax even more with your complete system.\\n\\nNow just press <Let's go!> and the system will begin installation!" 13 60 || { clear; exit; }
        }

adduserandpass() { \
        # Adds user `$name` with password $pass1.
        dialog --infobox "Adding user \"$name\"..." 4 50
        groupadd wheel
        useradd -m -g wheel -s /bin/bash "$name" >/dev/null 2>&1 ||
        usermod -a -G wheel "$name" && mkdir -p /home/"$name" && chown "$name":wheel /home/"$name"
        echo "$name:$pass1" | chpasswd
unset pass1 pass2 ;}

installwallpaper(){
        dialog --infobox "Installing Cooler Wallpaper..." 4 50
	wget http://hdqwalls.com/wallpapers/kali-linux-nethunter-5k-bw.jpg >/dev/null 2>&1
	gsettings set org.gnome.desktop.background picture-uri "/root/KaliExtra/kali-linux-nethunter-5k-bw.jpg"
}

installextrahacking(){
        dialog --infobox "Installing Extra Hacker tools..." 4 50
	pip install shodan >/dev/null 2>&1
	shodanapi=$(dialog --inputbox "Please paste(ctrl+shift+v) in an Shodan API key or just leave blank." 10 60 3>&1 1>&2 2>&3 3>&1)
	shodan init $shodanapi
	apt install ranger gpsd -y >/dev/null 2>&1
	git clone https://github.com/Und3rf10w/kali-anonsurf.git
	cd kali-anonsurf
	chmod +x installer.sh
	./installer.sh
	cd ..
	gunzip /usr/share/wordlists/rockyou.txt.gz
	apt install gobuster -y

}

bootonstartup(){
        dialog --infobox "Adding things to start on bootup..." 4 50
	# Switch esc and caps.
	echo "setxkbmap -option caps:swapescape" >> ~/.bashrc
	# Turn off auto-suspend.
	echo "sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target" >> ~/.bashrc
}

dotfiles(){
        dialog --infobox "Configuring .vimrc..." 4 50
	git clone https://github.com/remembercds/bobs-dot-files.git
	shopt -s dotglob 
	cp bobs-dot-files/* /root
}

vpngate(){
        dialog --infobox "Configuring vpngate client..." 4 50
	git clone https://github.com/Dragon2fly/vpngate-with-proxy.git
	sed -i '29s/.*/    ifconfig eth0 down/' vpngate-with-proxy/user_script.sh.tmp
}

finalize(){ \
	dialog --infobox "Preparing welcome message..." 4 50
	dialog --title "All done!" --msgbox "Congrats! Provided there were no hidden errors, the script completed successfully and all the programs and configuration files should be in place." 12 80
}




### Calling all functions ###


# Welcome user.
welcomemsg

# Install dialogue.
installdepedencies

# Get user and pass.
getuserandpass

# Give warning if user already exists.
usercheck || error "User exited."

# Last chance for user to back out before install.
preinstallmsg || error "User exited."

# Adding user name and password.
adduserandpass || error "Error adding username and/or password."

# Install extra hacking programs.
installextrahacking

# Configure dotfiles.
dotfiles

# Slightly modified vpngate client.
vpngate

# Finishing Touches.
installwallpaper

# Boot on startup.
bootonstartup

# Last Screen.
finalize







