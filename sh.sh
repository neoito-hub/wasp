#!/usr/bin/env bash

#----------------------------------------------------------------------------------
#                !WARNING!  NOT SAFE FOR USE, YET.  !WARNING!
#----------------------------------------------------------------------------------

# -> Package selection by Paulson P.S and Abhilash Anandan
# -> This is a shitty script, that for the time being gets shit done.
#    there will be an update to this :)

XERR(){ printf "[L%0.4d] ERROR: %s\n" "$1" "$2" 1>&2; exit 1; }
ERR(){ printf "[L%0.4d] ERROR: %s\n" "$1" "$2" 1>&2; }

DEB_FOLDER="./debs"

USAGE(){
	while read -r; do
		printf "%s\n" "$REPLY"
	done <<-EOF
		            SH.SH

		            Simple bash script to install packages for web dev at work.

		SYNTAX:     sh.sh [OPTS]

		OPTS:       --help|-h|-?            - Displays this help information.
		            --less-verbose|-L       - Output fewer informational tidbits.
		            --deb-store|-D PATH     - Where the packages are to be downloaded.
		            --yes-apt|-y            - Assume yes to APT prompts.

		FILE:       The default location for DEB packages:

		              $DEB_FOLDER
	EOF
}

CLI_DEV_PKGS=(git-core git vim tmux htop build-essential libssl-dev curl)
APT_OPTS='-q -o Dpkg::Progress=true -o Dpkg::Progress-Fancy=true'
WGET_OPTS='-q --show-progress'

while [ "$1" ]; do
	case "$1" in
		--help|-h|-\?)
			USAGE; exit 0 ;;
		--less-verbose|-L)
			LESS_VERBOSE="True" ;; # <-- Unset means False.
		--deb-store|-D)
			shift; DEB_FOLDER="$1" ;;
		--yes-apt|-y|--yes|--assume-yes)
			YES_APT="True" ;;
		*)
			XERR "$LINENO" "Incorrect argument(s) specified." ;;
	esac
	shift
done

declare -i DEPCOUNT=0
for DEP in wget apt-{get,key} service dpkg; {
	if ! type -fP "$DEP" > /dev/null; then
		ERR "$LINENO" "Dependency '$DEP' not met."
		DEPCOUNT+=1
	fi
}

[ $DEPCOUNT -eq 0 ] || exit 1

#-----------------------------------------------------------------------| FUNCTIONS

INFO(){ [ $LESS_VERBOSE ] || printf "$1\n"; }

printBanner() {
	if ! [ $LESS_VERBOSE ]
	then
		while read; do
			printf "%s\n" "$REPLY"
		done <<-EOF
			┏━┓┏━╸╺┳╸╻ ╻┏━┓   ╻ ╻┏━┓╻ ╻┏┓╻╺┳┓
			┗━┓┣╸  ┃ ┃ ┃┣━┛   ┣━┫┃ ┃┃ ┃┃┗┫ ┃┃
			┗━┛┗━╸ ╹ ┗━┛╹     ╹ ╹┗━┛┗━┛╹ ╹╺┻┛

			 - This script will install packages needed to make your ubuntu system kickass.
			 - Run me as root, and have an Internet connection ready. :)

		EOF
	fi
}

[ $EUID -ne 0 ] && XERR "$LINENO" "Root access is required."

checkForNet() {
	if ! wget -q --tries=10 --timeout=20 --spider https://www.google.co.in/
	then
		XERR "$LINENO" "An active Internet connection is required."
	else
		INFO "Active Internet connection established."
	fi
}

aptgetUpdate(){
	INFO "Resynchronizing package index files with their sources..."
	apt-get update
}

doDebs() {
	INFO "\n(3 / 9) Installing chrome, slack, and vscode..."

	# Clean output (0 exit status, too) even if the directory already exists.
	mkdir -vp "$DEB_FOLDER"

	# Now double-check the directory was created properly.
	if [ -d "$DEB_FOLDER" ]
	then
		# This array variable is a key=value system for the below for loop.
		LINKS=(
			'vscode@https://az764295.vo.msecnd.net/stable/b813d12980308015bcd2b3a2f6efa5c810c33ba5/code_1.17.2-1508162334_amd64.deb'
			'google-chrome@https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
			'slack@https://downloads.slack-edge.com/linux_releases/slack-desktop-2.8.2-amd64.deb'
		)

		for LINK in ${LINKS[@]}
		{
			INFO "Downloading '%s'..." "${NAME%%@*}"
			wget $WGET_OPTS "${LINK#*@}" -O "$DEB_FOLDER/${LINK##*/}"
			chown -v "$SUDO_USER:$SUDO_USER" "$DEB_FOLDER/${LINK##*/}"
			# Comment out the above line and uncomment the below chown
			# line, if you want to chown it all; might be pointless.
		}

		#chown -vR "$SUDO_USER:$SUDO_USER" "$DEB_FOLDER"
	else
		XERR "$LINENO" "Directory '$DEB_FOLDER' missing or inaccessible."
	fi
}

installSublimeText() {
	INFO "\n(5 / 9) Installing 'sublime-text'..."

	INFO "Adding the GNU Privacy Guard key for Sublime..."
	wget $WGET_OPTS https://download.sublimetext.com/sublimehq-pub.gpg -O -\
		| apt-key add -

	apt-get $YES_APT $APT_OPTS install apt-transport-https

	LIST='/etc/apt/sources.list.d/sublime-text.list'
	printf "deb https://download.sublimetext.com/ apt/stable/\n" > "$LIST"

	INFO "Installing the 'sublime-text' package..."
	apt-get $YES_APT $APT_OPTS install sublime-text
}

installNodeJS() {
	INFO "\n(4 / 9) Installing 'nodejs'..."

	TMP_FILE='/tmp/setup_6.x'

	apt-get $YES_APT $APT_OPTS install python-software-properties nodejs
	wget -q https://deb.nodesource.com/setup_6.x -O "$TMP_FILE"

	# You'll need to test these environment variables injected into the bash
	# session called here. I'm not familiar with the script it executes. If
	# all is however good, then the script should treat HOME and UID as those
	# of the user who ran sudo.
	#
	# Whichever environment variables are needed, relating to the user you
	# actually want it to process, can be prepended to the command (bash).
	if HOME="/home/$SUDO_USER" UID=$SUDO_UID bash "$TMP_FILE"
	then
		INFO "Script '$TMP_FILE' execute successfully."
	else
		XERR "$LINENO" "Script '$TMP_FILE' exited with a non-zero status."
	fi
}

installMongoDB() {
	INFO "\n(6 / 9) Installing community edition of 'mongoDB'..."

	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80\
		--recv 0C49F3730359A14518585931BC711F9BA15703C6

	LINK='http://repo.mongodb.org/apt/ubuntu'
	printf "deb [ %s ] %s %s %s\n" "arch=amd64,arm64"\
		"$LINK" "xenial/mongodb-org/3.4" "multiverse"\
		> /etc/apt/sources.list.d/mongodb-org-3.4.list

	apt-get $YES_APT $APT_OPTS install mongodb-org
	service mongod restart
}

installrobo3T() {
	INFO "\n(7 / 9) Installing 'robo3T'..."

	ARCHIVE='robo3t-1.1.1-linux-x86_64-c93c6b0.tar.gz'
	PROG_DIR="$HOME/Programs"

	INFO "Getting '$ARCHIVE'..."
	wget $WGET_OPTS "https://download.robomongo.org/1.1.1/linux/$ARCHIVE"

	INFO "Extracting..."
	tar -C "$DEB_FOLDER" -xzvf "$ARCHIVE"

	mkdir -vp "$PROG_DIR"
	mv -v "${ARCHIVE%.tar.gz}" "$PROG_DIR/robo3t"

	INFO "Applying Robomongo fix..."
	mkdir -vp "$PROG_DIR/robo3t/backup"
	mv -v "$PROG_DIR/robo3t/lib/libstdc++"* "$PROG_DIR/robo3t/backup"

	INFO "Create desktop shortcut..."
	ln -vs "$PROG_DIR/robo3t/bin/robo3t" "$HOME/Desktop/robo3t"

	chown -vR $SUDO_USER:$SUDO_USER /home/$SUDO_USER/Programs/robo3t
}

installJava() {
	INFO "\n(8 / 9) Installing 'java'..."

	apt-get $YES_APT $APT_OPTS install default-jre
	apt-get $YES_APT $APT_OPTS install default-jdk
}

installLAMP() {
	INFO "\n(9 / 9) Installing 'lamp'..."

	apt-get $YES_APT $APT_OPTS install mysql-{server,client,workbench} libmysqld-dev
	apt-get $YES_APT $APT_OPTS install apache2 php libapache2-mod-php php-mcrypt php-mysql phpmyadmin
	printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php
	# Above line will be affected by below chmod and chown; is that intended?

	chmod -vR 755 /var/www/
	chown -vR 0:0 /var/www/ # <-- Is this what you want here? Am no web dev.

	service apache2 restart # <-- No systems running SystemD?
}

installDevTools(){
	INFO "\n(2 / 9) Installing command-line dev-tools..."

	apt-get $YES_APT $APT_OPTS install ${CLI_DEV_PKGS[@]}
}

installDevTools(){
	INFO "\n(2 / 9) installing command-line dev-tools..."
	if ! dpkg -i "$DEB_FOLDER"/*.deb; then
		ERR "$LINENO" "DPKG detected errors; attempting fix..."
		if ! apt-get $YES_APT $APT_OPTS install -f
		then
			XERR "$LINENO" "Non-zero exit status during fix attempt."
		fi
	fi
}

#---------------------------------------------------------------------------| BEGIN

printBanner
checkForNet
aptgetUpdate

installDevTools	

doDebs

installNodeJS
installSublimeText
installMongoDB
installrobo3T
installJava
installLAMP

INFO "All done, Master. :)"

# end of script
