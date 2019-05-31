#!/bin/sh

### Install Depedencies ###
apt install dialog -y


### Functions ###

error() { clear; printf "ERROR:\\n%s\\n" "$1"; exit;}

welcomemsg() { \
        dialog --title "Welcome!" --msgbox "Welcome to The's Kali Extra  Script!\\n\\nThis script will automatically make your Kali Extra!" 10 60
        }

getuserandpass() { \
        # Figure out how to automatically make this root
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




welcomemsg

getuserandpass

# Give warning if user already exists.
usercheck || error "User exited."

# Last chance for user to back out before install.
preinstallmsg || error "User exited."

### The rest of the script requires no user input.

adduserandpass || error "Error adding username and/or password."
