# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Create a build and development environment for Firefox.

FROM ubuntu:14.04
MAINTAINER Benoit Girard "bgirard@mozilla.com"

RUN apt-get update

# Basic build dependencies.
RUN sudo apt-get install -y zip unzip mercurial g++ make autoconf2.13 yasm libgtk2.0-dev libglib2.0-dev libdbus-1-dev libdbus-glib-1-dev libasound2-dev libcurl4-openssl-dev libiw-dev libxt-dev mesa-common-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libpulse-dev m4 flex ccache

# Libraries required for building.
# RUN apt-get install -y libasound2-dev libcurl4-openssl-dev libdbus-1-dev libdbus-glib-1-dev libgtk2.0-dev libiw-dev libnotify-dev libxt-dev mesa-common-dev uuid-dev

# Gold linker is much faster than standard linker.
# RUN apt-get install -y binutils-gold

# Developer tools.
RUN apt-get install -y bash-completion curl emacs git man-db python-dev python-pip vim gdb
RUN pip install mercurial

# Window manager
sudo apt-get install -y vnc4server xfce4

# Create a user for development.
RUN useradd -ms /bin/bash mozillian
echo -e "mozilla\nmozilla" | passwd mozillian
