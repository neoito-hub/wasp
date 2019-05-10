#!/usr/bin/env bash

# Synopsis : Project initialization
# Support : nodejs, xxx, xxx
# Checks for
# 1. .gitignore file
# 2. pulls in config for appropriate project type

DOTFILE_REPO="https://raw.githubusercontent.com/neoito-hub/dotfiles/master"
CURR_DIR="$PWD"

printHelp() {
  echo "$0: missing operand
Invoke as :  \$ $0 <project_type>
An example:  \$ $0 node
Supported :   node ts"
}

downloadFileName() {
  url="$DOTFILE_REPO/$1"
  saveAs=$1
  echo "fetching: $url"
  echo "saving as $saveAs"
  wget -O $saveAs $url
}

initNodeProject() {
  if [ ! -f package.json ]; then
    touch package.json
    echo "error: no package.json. do an npm init"
    exit 1
  fi

  if [ ! -f .gitignore ]; then
    touch .gitignore
    echo "node_modules" >> .gitignore
  fi

  echo "installing dev deps"
  npm i --save-dev eslint eslint-config-airbnb eslint-config-prettier \
  eslint-plugin-import eslint-plugin-jsx-a11y eslint-plugin-prettier \
  eslint-plugin-react prettier

  downloadFileName .prettierrc
  downloadFileName .eslintrc.json
}

initTsProject() {
  if [ ! -f package.json ]; then
    touch package.json
    echo "error: no package.json. not in a ts project"
    exit 1
  fi

  echo "installing dev deps"
  npm i --save-dev tslint-config-airbnb
  echo "Put this in your tslint.json file
---------------------8<-------------8<--------------
{
  'extends': 'tslint-config-airbnb'
}
---------------------8<--------------8<--------------
  "
}

if [ $# -eq 0 ]
then
  printHelp
  exit 1
fi

PTYPE=$1

case "$1" in
  'node')  echo "Initializing node project"
    initNodeProject
    ;;
  'ts')  echo "Initializing typescript project"
    initTsProject
    ;;
  *) echo "Project type $1 is not configured"
    echo "File an issue at https://github.com/neoito-hub/wasp"
    exit 1
    ;;
esac

echo "$0 exiting ..."
