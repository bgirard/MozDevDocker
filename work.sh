#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ -z "$SSH_AUTH_SOCK" ]; then
  echo "WARNING:"
  echo "You must setup ssh-agent if you want to push."
  DOCKER_SSH_AGENT=""
else
  DOCKER_SSH_AGENT="-v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
fi

source $DIR/settings.sh

set -e

if [ "$1" == "-c" ]; then
  echo "WARNING!!!:"
  echo "Your running with an argument which conflicts with signal handling."
  echo "You may be disconnected when sending ^C"
  echo ""
fi

#BUG_NUMBER="$2"

function run {
  if [[ -z "$BUG_NUMBER" ]]; then
    echo "Active containers on this host:"
    docker ps -a | sed -e "1d" | sed -e 's/.*bug//g' | sort -n
    echo ""
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
  docker run $DOCKER_SSH_AGENT -P -i -t -d --name="$IMAGE_NAME" "$IMAGE_TO_LOAD" su -l mozillian

  DOCKER_IMAGE=$(docker ps -a | grep $IMAGE_NAME | awk '{ print $1 }')

  if [ ! -z "$DOCKER_SSH_AGENT" ]; then
    docker exec $DOCKER_IMAGE chown -R mozillian $(dirname $SSH_AUTH_SOCK)
    docker exec $DOCKER_IMAGE ls /home/
    docker exec $DOCKER_IMAGE ls /home/mozillian/
    docker exec $DOCKER_IMAGE ls /home/mozillian/.bashrc
    docker exec $DOCKER_IMAGE bash -c 'echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> /home/mozillian/.bashrc'
  fi

  resume_docker
}

function resume_docker {
  echo "Resuming contianer for bug $BUG_NUMBER."
  echo "You may need to press enter to get a prompt."

  echo "Ports:"
  docker inspect --format="{{ json .NetworkSettings.Ports }}" $DOCKER_IMAGE  | python -mjson.tool
  echo ""

  IS_RUNNING=$(docker inspect --format "{{ .State.Running }}" $DOCKER_IMAGE)
  if [[ "$IS_RUNNING" == true ]]; then
    docker exec -i -t $DOCKER_IMAGE su - mozillian
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
