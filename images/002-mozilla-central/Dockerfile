# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

FROM bgirard/base_ff_dev
MAINTAINER Benoit Girard "bgirard@mozilla.com"

ADD script.sh /tmp/b4ed62419542.sh
RUN chown mozillian /tmp/b4ed62419542.sh
RUN sudo -i -u mozillian bash /tmp/b4ed62419542.sh
