#!/bin/bash

source settings.sh

set -e

BUG_NUMBER="$1"

function run {
  if [[ -z "$BUG_NUMBER" ]]; then
    echo -n "Please enter the bug number you're working on: "
    read BUG_NUMBER
  fi


  if [[ ! "$BUG_NUMBER" =~ ^-?[0-9]+$ ]]; then
    echo "Bad bug number"
    exit
  fi

  IMAGE_NAME=bug$BUG_NUMBER
  DOCKER_IMAGE=$(docker ps -a | grep $IMAGE_NAME | awk '{ print $1 }')

  if [[ -z "$DOCKER_IMAGE" ]]; then
    create_docker $IMAGE_NAME
  else
    resume_docker $IMAGE_NAME
  fi
  exit
}

function create_docker {
  SEARCH=$(docker search "mc-opt64-$IMAGE_NAME" | sed '1d')
  if [[ -n "$SEARCH" ]]; then 
    echo -e "Images for bug $BUG_NUMBER:\n"
    echo $SEARCH | awk '{ print $1 }'
    echo ""
    echo -n "Pick an image to load: "
    read IMAGE_TO_LOAD
  else
    IMAGE_TO_LOAD=bgirard/mc-opt64
  fi

  echo Creating $IMAGE_NAME
  docker run -P -i -t -d --name="$IMAGE_NAME" "$IMAGE_TO_LOAD" su -l mozillian

  DOCKER_IMAGE=$(docker ps -a | grep $IMAGE_NAME | awk '{ print $1 }')
  resume_docker
}

function resume_docker {
  echo "Resuming contianer for bug $BUG_NUMBER."
  echo "You may need to press enter to get a prompt."

  echo "Ports:"
  docker inspect --format="{{ json .NetworkSettings.Ports }}" 7932641e216d  | python -mjson.tool
  echo ""

  IS_RUNNING=$(docker inspect --format "{{ .State.Running }}" $DOCKER_IMAGE)
  if [[ "$IS_RUNNING" == true ]]; then
    docker attach $DOCKER_IMAGE
  else
    docker start -i $DOCKER_IMAGE
  fi

  check_commit
}

function commit {
  #echo -n "Please enter a commit message (or leave blank): "
  #read COMMIT_MSG
  #if [[ -n "$COMMIT_MSG" ]]; then
  #  # XXX prevent injections!
  #  COMMIT_MSG_FLAGS="-m $COMMIT_MSG"
  #else
  #  COMMIT_MSG_FLAGS=""
  #fi
  docker commit $COMMIT_MSG_FLAGS $DOCKER_IMAGE bgirard/mc-opt64-bug$BUG_NUMBER
  docker push bgirard/mc-opt64-bug$BUG_NUMBER

  echo "You may want to consider pasting the following in bugzilla:"
  echo ""
  echo "Updated container for bug $BUG_NUMBER."
  echo "To connect: ssh $URL $BUG_NUMBER"
  echo ""
  echo "For more information see: https://wiki.mozilla.org/DockerEnv"
  echo ""
  echo ""
}

function check_commit {
#  echo Check commit $1
  echo "Your contaier will be saved for up to 2 weeks."
  echo -n "Would you like to commit/publish your container changes to make them permanent? [y/N] "
  read COMMIT
  COMMIT=$(echo $COMMIT | awk '{print tolower($0)}')
  if [[ "${COMMIT}" == "y" ]]; then
    commit
  fi
}

run
