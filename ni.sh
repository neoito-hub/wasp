#!/usr/bin/env bash

# Synopsis : Script for installing Nativescript on Ubuntu 16.04

# config parameters
CURR_DIR="$PWD"

# Start of functions
printBanner() {
	echo "
┏┓╻┏━┓╺┳╸╻╻ ╻┏━╸┏━┓┏━╸┏━┓╻┏━┓╺┳╸   ╻┏┓╻┏━┓╺┳╸┏━┓╻  ╻  ┏━╸┏━┓
┃┗┫┣━┫ ┃ ┃┃┏┛┣╸ ┗━┓┃  ┣┳┛┃┣━┛ ┃    ┃┃┗┫┗━┓ ┃ ┣━┫┃  ┃  ┣╸ ┣┳┛
╹ ╹╹ ╹ ╹ ╹┗┛ ┗━╸┗━┛┗━╸╹┗╸╹╹   ╹    ╹╹ ╹┗━┛ ╹ ╹ ╹┗━╸┗━╸┗━╸╹┗╸

 - This script will install nativescript on to this machine -
 - Run me as a normal user and have an internet connection ready :)

	"
}

checkForNet() {
	wget -q --tries=10 --timeout=20 --spider https://www.google.co.in/
	if [[ $? -ne 0 ]]; then
	    echo "Error: No internet"
	    exit
	fi
}

setupAndroidTools() {
	cd $HOME/Downloads/
	wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip

	# make dir if not found
	if [ ! -d $HOME/android ]
	then
		echo "making a directory for android sdk tools"
		mkdir $HOME/android
	fi

	cp sdk-tools-linux-3859397.zip $HOME/android
	cd $HOME/android
	unzip sdk-tools-linux-3859397.zip

	cd $CURR_DIR

	sudo chown $USER:$USER -R $HOME/android
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
	sudo $HOME/android/tools/bin/sdkmanager "tools" "platform-tools" "platforms;android-25" "build-tools;25.0.2" "extras;android;m2repository" "extras;google;m2repository"
	echo "installed android tools"
}

installNativeScript() {
	sudo npm install -g nativescript
	# error ?
	if [[ $? -ne 0 ]]; then
		echo "[warning] some erros creeped in. Applying a fix ... "
	    sudo npm install -g --unsafe-perm nativescript
	fi
}

# End of functions

# start of script
printBanner
checkForNet
echo "connected to net [ ok ]"
echo "(1 / 7) updating cache"
sudo apt update
echo "(2 / 7) installing runtime libraries"
sudo apt-get install -y lib32z1 lib32ncurses5 libbz2-1.0:i386 libstdc++6:i386
echo "(3 / 7) installing g++"
sudo apt-get install -y g++
echo "(4 / 7) downloading android tools"
setupAndroidTools
echo "(5 / 7) appending android vars to .bashrc"
configBashrc
echo "(6 / 7) installing android tools - This will take some time ..."
installAndroidTools
echo "(7 / 7) installing Nativescript from NPM"
installNativeScript

echo "Hey you! Run 'tns doctor' and check if you're ready to roll."
echo "installation is all done master :)"
# end of script
