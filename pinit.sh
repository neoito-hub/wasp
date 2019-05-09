#!/usr/bin/env bash

# Synopsis : Project initialization
# Support : nodejs, xxx, xxx
# Checks for
# 1. .gitignore file
# 2. pulls in config for appropriate project type


CURR_DIR="$PWD"

printHelp() {
  echo "$0: missing operand
Invoke as :  \$ $0 <project_type>
An example:  \$ $0 node"
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
  npm i --save-dev eslint eslint-config-airbnb eslint-config-prettier eslint-plugin-import eslint-plugin-jsx-a11y eslint-plugin-prettier eslint-plugin-react prettier

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
*) echo "Project type $1 is not configured"
   echo "File an issue at https://github.com/neoito-hub/wasp"
   ;;
esac

echo "$0 exiting ..."
exit 0
