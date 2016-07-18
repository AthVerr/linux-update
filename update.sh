URL='https://raw.githubusercontent.com/CoderDojoChi/linux-update/master'

SCRIPTDIR=/etc/init.d
SCRIPT=coderdojochi-phonehome
CONFDIR=/etc/init
CONF=$SCRIPT.conf

output() {
    echo "\n\n####################\n# $1\n####################\n\n";
    sudo -H -u coderdojochi bash -c 'notify-send --urgency=low "$1"';
}

# Install the coderdojochi-phone autoupdate script
if [ ! -f $CONFDIR/$CONF ]; then
    output "Installing phonehome config file"
    wget -qLO $CONFDIR/$CONF $URL/$CONFDIR/$CONF
fi

if [ ! -f $SCRIPTDIR/$SCRIPT ]; then
    output "Installing phonehome script"
    wget -qLO $SCRIPTDIR/$SCRIPT $URL/$SCRIPTDIR/$SCRIPT
fi

sudo -H -u coderdojochi bash -c 'notify-send --urgency=critical "Updating System"'

# Adding Google to package manager
output "Adding Google to package manager"
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
wget -qLO /etc/apt/sources.list.d/google-chrome.list \
     "$URL/etc/apt/sources.list.d/google-chrome.list"

# Adding Elementary Tweaks to package manager
output "Adding Elementary Tweaks to package manager"
add-apt-repository ppa:mpstark/elementary-tweaks-daily -y

# Upgrading system
output "Upgrading system"
apt-get update
apt-get dist-upgrade -y

# Uninstalling unused packages
output "Uninstalling unused packages"
command -v zeitgeist-daemon &> /dev/null
if [ $? -eq 0 ]; then
    zeitgeist-daemon --quit
fi

apt-get autoremove --purge -y deja-dup indicator-messages empathy-* gnome-online-accounts activity-log-manager-common activity-log-manager-control-center zeitgeist zeitgeist-core zeitgeist-datahub midori-granite noise software-center update-manager scratch-text-editor modemmanager geary

# Installing git
output "Installing git"
apt-get install -y git

# Installing elementary-tweaks
output "Installing elementary-tweaks"
apt-get install -y elementary-tweaks

# Installing gedit
output "Installing gedit"
apt-get install -y gedit

# Installing vim
output "Installing vim"
apt-get install -y vim

# Installing atom
output "Installing atom"
# https://github.com/atom/atom/releases/download/v1.8.0/atom-amd64.deb
wget -qLO /tmp/atom-amd64.deb https://github.com/atom/atom/releases/download/v1.8.0/atom-amd64.deb
dpkg --install /tmp/atom-amd64.deb

# Installing google-chrome-stable
output "Installing google-chrome-beta"
apt-get install -y google-chrome-beta

rm -rf /home/coderdojochi/.config/midori /home/coderdojochi/.config/google-chrome-beta

wget -qLO /opt/google/chrome-beta/default_apps/external_extensions.json \
     "$URL/opt/google/chrome-beta/default_apps/external_extensions.json"

sudo -H -u coderdojochi bash -c 'google-chrome-beta --no-first-run > /dev/null 2>&1 &'
sudo -H -u coderdojochi bash -c 'sleep 10'
sudo -H -u coderdojochi bash -c 'killall chrome'
sudo -H -u coderdojochi bash -c 'sleep 5'

# Chrome: disable password manager
output "Chrome: disable password manager"
sed -i 's/user",/user","password_manage_enabled":false,/' /home/coderdojochi/.config/google-chrome-beta/Default/Preferences

# Chrome: change startup URL to google.com
output "Chrome: change startup URL to google.com"
sed -i 's/"restore_on_startup_migrated":true,/"restore_on_startup":4,"restore_on_startup_migrated":true,"startup_urls":["https:\/\/google.com\/"],/' /home/coderdojochi/.config/google-chrome-beta/Default/Preferences

# Chrome: turn off custome frame
output "Chrome: turn off custome frame"
sed -i 's/"window_placement"/"clear_lso_data_enabled":true,"custom_chrome_frame":false,"pepper_flash_settings_enabled":true,"window_placement"/' /home/coderdojochi/.config/google-chrome-beta/Default/Preferences

sed -i 's/"cjpalhdlnbpafiamejdnhcphjbkeiagm":{/"cjpalhdlnbpafiamejdnhcphjbkeiagm":{"browser_action_visible":false,/' /home/coderdojochi/.config/google-chrome-beta/Default/Preferences

# Setting up the dock
output "Setting up the dock"
rm /home/coderdojochi/.config/plank/dock1/launchers/*.dockitem

wget -qLO /home/coderdojochi/.config/plank/dock1/launchers/pantheon-files.dockitem \
     "$URL/home/coderdojochi/.config/plank/dock1/launchers/pantheon-files.dockitem"
wget -qLO /home/coderdojochi/.config/plank/dock1/launchers/gedit.dockitem \
     "$URL/home/coderdojochi/.config/plank/dock1/launchers/gedit.dockitem"
wget -qLO /home/coderdojochi/.config/plank/dock1/launchers/google-chrome-beta.dockitem \
     "$URL/home/coderdojochi/.config/plank/dock1/launchers/google-chrome-beta.dockitem"

sed -i 's/HideMode=3/HideMode=0/g' /home/coderdojochi/.config/plank/dock1/settings

# Changing desktop background
output "Changing desktop background"
wget -qLO /usr/share/backgrounds/coderdojochi.png \
     "$URL/usr/share/backgrounds/coderdojochi.png"
sudo -H -u coderdojochi bash -c 'gsettings set "org.gnome.desktop.background" "picture-uri" "file:///usr/share/backgrounds/coderdojochi.png"'
sudo -H -u coderdojochi bash -c 'gsettings set "org.gnome.desktop.background" "picture-options" "zoom"'

# Setting screensaver settings
output "Setting screensaver settings"
sudo -H -u coderdojochi bash -c 'gsettings set "org.gnome.desktop.screensaver" "lock-delay" 3600'
sudo -H -u coderdojochi bash -c 'gsettings set "org.gnome.desktop.screensaver" "lock-enabled" false'
sudo -H -u coderdojochi bash -c 'gsettings set "org.gnome.desktop.screensaver" "idle-activation-enabled" false'

killall plank

wget -qLO /usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf \
     "$URL/usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf"

# Cleanup
output "Cleanup"
apt-get autoremove -y
apt-get autoclean -y
rm -rf {/root,/home/*}/.local/share/zeitgeist

# Remove old files that students might of saved
rm -rf /home/coderdojochi/Downloads/*
rm -rf /home/coderdojochi/Documents/*
rm -rf /home/coderdojochi/Music/*
rm -rf /home/coderdojochi/Pictures/*
rm -rf /home/coderdojochi/Videos/*
rm -rf /home/coderdojochi/Public/*
rm -rf /home/coderdojochi/Templates/*

# Restarting in 1 minute
output "Restarting in 1 minute"
shutdown -r 1
