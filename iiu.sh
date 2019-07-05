#!/usr/bin/env bash

# Synopsis : Checks if a set of urls give a 200 using curl

URL_LIST="$HOME/tmp/iiu.url.list"

printMsg() {
  echo "[msg] $1"
}

printErr() {
  echo "[err] $1"
}

getFileName() {
  if [ $# -eq 0 ]
  then
    printMsg "No arguments supplied"
    printMsg "Using default list: $URL_LIST"
  else
    URL_LIST=$1
    printMsg "Using list: $URL_LIST"
  fi
}

checkForNet() {
	wget -q --tries=10 --timeout=20 --spider https://www.google.co.in/
	if [ $? -ne 0 ]; then
	  printErr "No internet" 1>&2
		exit 1
	fi
}

checkForFile() {
  if [[ -f "$URL_LIST" ]]; then
    printMsg "$URL_LIST exists"
  else
    printErr "$URL_LIST does not exist"
    exit 1
  fi
}

processList() {
  echo ""
  while IFS= read -r line
  do
    status=$(curl -I $line 2> /dev/null | head -n 1|cut -d$' ' -f2)
    msg="ERR"
    if [[ $status == 200 || $status == 302 ]]; then
      msg="OK "
    fi

    if [ -z $status ]; then
      status="err"
    fi

    echo "$status | $msg | $line"
  done < "$URL_LIST"
  echo ""
  printMsg "done"
}

# start
# if invoked like iiu.sh file.list
getFileName $1
checkForFile
checkForNet
processList $1
exit 0
# end