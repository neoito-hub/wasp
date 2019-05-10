#!/usr/bin/env bash

# Synopsis : Script for installing Nativescript on Ubuntu 16.04

# config parameters
CURR_DIR="$PWD"

# Start of functions
printBanner() {
	while read; do
		echo "$REPLY"
	done <<-EOF
		┏┓╻┏━┓╺┳╸╻╻ ╻┏━╸┏━┓┏━╸┏━┓╻┏━┓╺┳╸   ╻┏┓╻┏━┓╺┳╸┏━┓╻  ╻  ┏━╸┏━┓
		┃┗┫┣━┫ ┃ ┃┃┏┛┣╸ ┗━┓┃  ┣┳┛┃┣━┛ ┃    ┃┃┗┫┗━┓ ┃ ┣━┫┃  ┃  ┣╸ ┣┳┛
		╹ ╹╹ ╹ ╹ ╹┗┛ ┗━╸┗━┛┗━╸╹┗╸╹╹   ╹    ╹╹ ╹┗━┛ ╹ ╹ ╹┗━╸┗━╸┗━╸╹┗╸

		 - This script will install nativescript on to this machine -
		 - Run me as a normal user and have an internet connection ready :)

	EOF
}

checkForNet() {
	wget -q --tries=10 --timeout=20 --spider https://www.google.co.in/
	if [ $? -ne 0 ]; then
		echo "Error: No internet" 1>&2
		exit 1
	fi
}

setupAndroidTools() {
	wget --quiet --show-progress\
		'https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip'\
		-O "$HOME/Downloads/sdk-tools-linux-3859397.zip"

	ANDROID="$HOME/android"

	# make dir if not found
	if [ ! -d "$ANDROID" ]; then
		echo "Making a directory for Android sdk tools..."
		mkdir "$ANDROID"
	fi

	cp sdk-tools-linux-3859397.zip "$ANDROID"
	cd "$ANDROID"
	unzip sdk-tools-linux-3859397.zip

	cd $CURR_DIR

	sudo chown $USER:$USER -R "$ANDROID"
}

configBashrc() {
	printf "\n" >> $HOME/.bashrc
	printf "export ANDROID_HOME=\$HOME/android\n" >> $HOME/.bashrc
	printf "export PATH=\${PATH}:\$ANDROID_HOME/tools\n" >> $HOME/.bashrc
	printf "export PATH=\${PATH}:\$ANDROID_HOME/tools/bin\n" >> $HOME/.bashrc
	printf "export PATH=\${PATH}:\$ANDROID_HOME/platform-tools\n" >> $HOME/.bashrc

	# reloading bashrc
	source $HOME/.bashrc
}

installAndroidTools() {
	sudo "$ANDROID/tools/bin/sdkmanager"\
		"tools" "platform-tools" "platforms;android-25"\
		"build-tools;25.0.2" "extras;android;m2repository"\
		"extras;google;m2repository"

	echo "Installed Android tools."
}

installNativeScript() {
	if ! sudo npm install -g nativescript; then
		echo "[WARNING] Some erros creeped in. Applying a fix..." 1>&2
		sudo npm install -g --unsafe-perm nativescript
	fi
}

# End of functions

# start of script
printBanner
checkForNet
echo "Internet connection established."
echo "(1 / 7) Updating cache..."
sudo apt update
echo "(2 / 7) Installing runtime libraries..."
sudo apt-get install -y lib32z1 lib32ncurses5 libbz2-1.0:i386 libstdc++6:i386
echo "(3 / 7) Installing 'g++'..."
sudo apt-get install -y g++
echo "(4 / 7) Downloading Android tools..."
setupAndroidTools
echo "(5 / 7) Appending Android vars to '.bashrc'..."
configBashrc
echo "(6 / 7) Installing Android tools; this will take some time..."
installAndroidTools
echo "(7 / 7) Installing Nativescript from NPM..."
installNativeScript

echo "Hey you! Run 'tns doctor' and check if you're ready to roll."
echo "Installation is all done, Master. :)"
# end of script
