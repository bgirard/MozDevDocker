# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

FROM bgirard/mozilla-central
MAINTAINER Benoit Girard "bgirard@mozilla.com"

# Setup .mozconfig
ADD .mozconfig /home/mozillian/mozilla/mozilla-central/tree/.mozconfig
RUN chown mozillian /home/mozillian/mozilla/mozilla-central/tree/.mozconfig

# Start build script
ADD script.sh /tmp/b4ed62419542.sh
RUN chown mozillian /tmp/b4ed62419542.sh
RUN sudo -i -u mozillian bash /tmp/b4ed62419542.sh
