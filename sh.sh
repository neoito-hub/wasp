#!/usr/bin/env bash

# Synopsis: A simple bash script to install packages for web dev at work.

# -> Package selection by Paulson P.S and Abhilash Anandan
# -> This is a shitty script, that for the time being gets shit done.
#    there will be an update to this :)

# config parameters
NORMAL_USER="user"
DEB_FOLDER="./debs"
CURR_DIR="$PWD"
APT_OPTS='-q -o Dpkg::Progress=true -o Dpkg::Progress-Fancy=true'
WGET_OPTS='-q --show-progress'

XERR(){ printf "[L%0.4d] ERROR: %s\n" "$1" "$2" 1>&2; exit 1; }
ERR(){ printf "[L%0.4d] ERROR: %s\n" "$1" "$2" 1>&2; }

# Start of functions
printBanner() {
	while read; do
		echo "$REPLY"
	done <<-EOF
		┏━┓┏━╸╺┳╸╻ ╻┏━┓   ╻ ╻┏━┓╻ ╻┏┓╻╺┳┓
		┗━┓┣╸  ┃ ┃ ┃┣━┛   ┣━┫┃ ┃┃ ┃┃┗┫ ┃┃
		┗━┛┗━╸ ╹ ┗━┛╹     ╹ ╹┗━┛┗━┛╹ ╹╺┻┛

		 - This script will install a few packages needed to make your ubuntu system kickass.
		 - Run me as root, and have an Internet connection ready. :)

	EOF
}

# Checking for root access is pointless here, since 'sudo' is used in-script.
[ $EUID -ne 0 ] && XERR "$LINENO" "Root access is required."

checkForNet() {

	if ! wget -q --tries=10 --timeout=20 --spider https://www.google.co.in/
	then
		XERR "$LINENO" "An active Internet connection is required."
	fi
}

doDebs() {
	# make dir if not found
	if [ ! -d $DEB_FOLDER ]
	then
		echo "Making a directory for deb downloads..."
		mkdir "$DEB_FOLDER"
	fi

	LINKS=(
		# This is a key=value system, where '@' (least likely to be in the
		# URL itself) is the '=' substitute. Remember to single-quote to
		# protect from shell interpretation.
		'vscode@https://az764295.vo.msecnd.net/stable/b813d12980308015bcd2b3a2f6efa5c810c33ba5/code_1.17.2-1508162334_amd64.deb'
		'google-chrome@https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
		'slack@https://downloads.slack-edge.com/linux_releases/slack-desktop-2.8.2-amd64.deb'
	)

	for LINK in ${LINKS[@]}
	{ 
		echo "Downloading ${NAME%%@*}..."
		wget $WGET_OPTSs "${LINK#*@}" -O "$DEB_FOLDER/${LINK##*/}"
		#chown "$NORMAL_USER:$NORMAL_USER" "$DEB_FOLDER/${LINK##*/}"
		# Uncomment the above line and comment out the below chown line, -
		# if you would prefer only to chown the downloaded files.
	}

	chown -R "$NORMAL_USER:$NORMAL_USER" "$DEB_FOLDER"
}

installSublimeText() {
	echo "Adding Sublime public key..."
	wget $WGET_OPTS https://download.sublimetext.com/sublimehq-pub.gpg -O -\
		| sudo apt-key add -

	sudo apt-get $APT_OPTS install -y apt-transport-https

	echo "deb https://download.sublimetext.com/ apt/stable/"\
		| sudo tee /etc/apt/sources.list.d/sublime-text.list

	echo "Updating repositories..."
	sudo apt-get $APT_OPTS update
	sudo apt-get $APT_OPTS install -y sublime-text
}

installNodeJS() {
	sudo apt-get $APT_OPTS install -y python-software-properties nodejs
	curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
}

installMongoDB() {
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80\
		--recv 0C49F3730359A14518585931BC711F9BA15703C6

	echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse"\
		| sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list

	sudo apt-get update
	sudo apt-get $APT_OPTS install -y mongodb-org
	sudo service mongod restart
}

installrobo3T() {
	ARCHIVE='robo3t-1.1.1-linux-x86_64-c93c6b0.tar.gz'

	cd $DEB_FOLDER
	echo "Getting '$ARCHIVE'..."
	wget $WGET_OPTS 'https://download.robomongo.org/1.1.1/linux/'
	echo "Extracting...."
	tar -xzvf robo3t-1.1.1-linux-x86_64-c93c6b0.tar.gz

	# make dir if not found
	if [ ! -d /home/$NORMAL_USER/Programs ]
	then
		echo "making a directory for other programs"
		mkdir /home/$NORMAL_USER/Programs
	fi

	mv robo3t-1.1.1-linux-x86_64-c93c6b0 /home/$NORMAL_USER/Programs/robo3t
	echo "applying robo mongo fix"
	# make dir if not found
	if [ ! -d /home/$NORMAL_USER/Programs/robo3t/backup ]
	then
		echo "making a directory for backup"
		mkdir /home/$NORMAL_USER/Programs/robo3t/backup
	fi
	mv /home/$NORMAL_USER/Programs/robo3t/lib/libstdc++* /home/$NORMAL_USER/Programs/robo3t/backup

	echo "making shortcut on desktop"
	ln -s /home/$NORMAL_USER/Programs/robo3t/bin/robo3t /home/$NORMAL_USER/Desktop/robo3t

	chown -R $NORMAL_USER:$NORMAL_USER /home/$NORMAL_USER/Programs/robo3t
	cd $CURR_DIR
}

installJava() {
	sudo apt-get $APT_OPTS install -y default-jre
	sudo apt-get $APT_OPTS install -y default-jdk
}

installLAMP() {
	sudo apt-get $APT_OPTS -y install mysql-{server,client,workbench} libmysqld-dev
	sudo apt-get $APT_OPTS -y install apache2 php libapache2-mod-php php-mcrypt php-mysql phpmyadmin
	sudo chmod 755 -R /var/www/
	sudo printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php
	sudo service apache2 restart
}
# End of functions


# start of script
printBanner
checkForRoot
echo "running as root [ ok ]"
checkForNet
echo "connected to net [ ok ]"

echo "(1 / 9) updating cache"
sudo apt update
echo "(2 / 9) installing command-line dev-tools"
sudo apt install git-core git vim tmux htop build-essential libssl-dev curl
echo "(3 / 9) installing chrome, slack and vscode"
doDebs

# cleaning up
if ! sudo dpkg -i "$DEB_FOLDER"/*.deb; then
	echo "[WARNING] DPKG detected errors; attempting fix..."
	sudo apt install -f -y
fi

echo "(4 / 9) installing nodejs"
installNodeJS
echo "(5 / 9) installing sublime-text"
installSublimeText
echo "(6 / 9) installing mongoDB community edition"
installMongoDB
echo "(7 / 9) installing robo3T"
installrobo3T
echo "(8 / 9) installing java"
installJava
echo "(9 / 9) installing lamp"
installLAMP

echo "all done master :)"

# end of script
