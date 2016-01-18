#!/bin/bash
## ==================================
## Script to spin up Docker hosts
## Initial verison: Mike Sandman
## Updated version: Petar Smilajkov
## ==================================
## Updates: 
## - 12/15/2015 - added option switches and help - Petar Smilajkov
## ================================================================
## Todo: 
##     [] Check if long options work
##     [] Add other providers
##     [] Do some error checking for provided argument values
##     [] Remove API keys from this file, move into ENV variables
## ================================================================

# set fonts for help highlights
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

# API Keys
DO_KEY=""

function show_help {
  cat << EOF
Usage: ${BOLD}create-machines${NORM} [-n|--name | -p|--provider | -q|--quantity | -r|--region | -s|--size]

Example: ${REV}create-machines -n prettyName -p do -q 3 -r nyc3 -s 4gb${NORM}
-> Creates a specified -q NUMBER of Docker Hosts @ -p PROVIDER in -r REGION of -s SIZE prefixed with -n prettyName.

        -h|--help      		displays this help

        -n|--name NAME		name prefix to be used in the full docker host name, default=dh
				full name will be namePrefix.provider.region.host#
				ex: dh.do.nyc3.0001, or prettyName.aws.us-east-1a.1234

        -p|--provider PROVIDER	provider identifier on which to spin up docker hosts
				vb = VirtualBox (default)
                        	do = Digital Ocean

        -q|--quantity NUMBER	number of docker hosts to spin up (default: 3)

        -r|--region REGION      region identifier for new docker hosts
				- VirtualBox: local (default)
                        	- DigitalOcean: nyc1..3, ams1..3, sfo1..3, sgp1..3, lon1..3

        -s|--size SIZE		Size of machine (512mb, 1gb, 2gb (default), 4gb, 8gb, ... 64gb)

EOF
}

function create_machine {
  local PROVIDER=$1
  local REGION=$2
  local SIZE=$3
  local FULLNAME=$4
  local NODENUMBER=$5
  local PREFIX=""

  case ${#NODENUMBER} in
    0)
      echo "What a heck?"
      exit 1
      ;;
    1)
      PREFIX="000$NODENUMBER"
      ;;
    2)
      PREFIX="00$NODENUMBER"
      ;;
    3)
      PREFIX="0$NODENUMBER"
      ;;
    *)
      PREFIX="$NODENUMBER"
      ;;
  esac

  case $PROVIDER in
    vb)
      docker-machine create \
        --driver virtualbox \
        $PREFIX.$FULLNAME &
      ;;
    do)
      docker-machine create \
        --driver digitalocean \
        --digitalocean-access-token=$DO_KEY \
        --digitalocean-region=$REGION \
        --digitalocean-size=$SIZE \
        $PREFIX.$FULLNAME &
      ;;
    aws)
      echo "Amazon Web Services"
      ;;
    *)
      echo "ERROR: Unknown Provider: $PROVIDER"
      exit 1
  esac
}

NUMARGS=$#
if [ $NUMARGS -eq 0 ]; then
  echo "Spinning up default Docker Cluster: 3 hosts on VirtualBox, 2gb RAM, 001..3.dh-virtualbox-local"
fi

# init vars to default values
PROVIDER="vb"
QUANTITY=3
REGION="local"
SIZE="2gb"
NAME="dh"

  while getopts "n:name:p:provider:q:quantity:r:region:s:size:h help" opt
  do

    echo "-----$OPTIND----------$opt-----------$OPTARG"

    case $opt in
      n|name)
        NAME="$OPTARG"
        ;;
      p|provider)
        PROVIDER="$OPTARG"
        ;;
      q|quantity)
        QUANTITY="$OPTARG"
        ;;
      r|region)
        echo "Getting Region $opt --> $OPTARG"
        REGION="$OPTARG"
        ;;
      s|size)
        SIZE="$OPTARG"
        ;;
      h|help)
        show_help
        exit 1
        ;;
      \?|*)
        show_help
        exit 1
        ;;
    esac
  done
  shift "$((OPTIND-1))"

FULLNAME="$NAME.$PROVIDER.$REGION"

echo $FULLNAME.$QUANTITY

create docker host nodes
for ((a=1; a <= QUANTITY ; a++)) do
  create_machine $PROVIDER $REGION $SIZE $FULLNAME $a
done
