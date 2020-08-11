# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM moby/buildkit:v0.7.2-rootless

ENV HOME="/home/buildkit"

USER root

RUN mkdir -p ${HOME} && \
    mkdir -p ${HOME}/.docker && \
    mkdir /projects && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
      chmod -R o+rwX ${f}; \
    done && \
    # /var/tmp/buildkit
    mkdir -p /var/tmp/buildkit && \
    chmod -R g+rwX /var/tmp/buildkit && \
    chmod -R o+rwX /var/tmp/buildkit

ENV XDG_RUNTIME_DIR /var/tmp/buildkit
ENV TMPDIR=/var/tmp/buildkit
ENV DOCKER_CONFIG=${HOME}/.docker

# https://github.com/moby/buildkit/blob/master/docs/rootless.md#troubleshooting
ENV BUILDKITD_FLAGS="--oci-worker-snapshotter=native --oci-worker-no-process-sandbox"

ADD etc/entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

CMD tail -f /dev/null
