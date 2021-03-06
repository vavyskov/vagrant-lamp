#!/bin/bash
set -eu

## Detect permission
if [ $(id -u) != 0 ]; then
   echo -e "\nYou have to run this script as root or with sudo prefix!\n"
   exit
fi

## Current script directory path
CURRENT_DIRECTORY=$(dirname $0)

## Environment variables
source "$CURRENT_DIRECTORY/../config/env.sh"

## -----------------------------------------------------------------------------

## Sources
apt-get update



## Node.js (latest)
#curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -

## Node.js (LTS)
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

## Node.js
apt-get install -y nodejs

## -----------------------------------------------------------------------------

##
## JavaScript package management
##

## NPM (included in Node.js)

## YARN
npm install -g yarn

## PNPM
npm install -g pnpm
## PNPM upgrade
#pnpm install -g pnpm

## -----------------------------------------------------------------------------

## Services
#service apache2 reload
