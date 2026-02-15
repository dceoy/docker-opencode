# syntax=docker/dockerfile:1
ARG UBUNTU_VERSION=24.04
FROM public.ecr.aws/docker/library/ubuntu:${UBUNTU_VERSION} AS cli

ARG USER_NAME=cli
ARG USER_UID=1001
ARG USER_GID=1001

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN \
      rm -f /etc/apt/apt.conf.d/docker-clean \
      && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
        > /etc/apt/apt.conf.d/keep-cache

# hadolint ignore=DL3008
RUN \
      --mount=type=cache,target=/var/cache/apt,sharing=locked \
      --mount=type=cache,target=/var/lib/apt,sharing=locked \
      apt-get -yqq update \
      && apt-get -yqq install --no-install-recommends --no-install-suggests \
        ca-certificates curl gh git

RUN \
      groupadd --gid "${USER_GID}" "${USER_NAME}" \
      && useradd --uid "${USER_UID}" --gid "${USER_GID}" --shell /bin/bash --create-home "${USER_NAME}"

ENV OPENCODE_INSTALL_DIR=/usr/local/bin

RUN \
      curl -fsSL https://opencode.ai/install | bash

HEALTHCHECK NONE

USER ${USER_NAME}
WORKDIR /workspace

RUN \
      echo '.DS_Store' > "${HOME}/.gitignore" \
      && git config --global color.ui auto \
      && git config --global core.excludesfile "${HOME}/.gitignore" \
      && git config --global core.pager '' \
      && git config --global core.quatepath false \
      && git config --global core.precomposeunicode false \
      && git config --global gui.encoding utf-8 \
      && git config --global fetch.prune true \
      && git config --global push.default matching \
      && git config --global user.name "${USER_NAME}" \
      && git config --global user.email "${USER_NAME}@localhost"

ENTRYPOINT ["/usr/local/bin/opencode"]
