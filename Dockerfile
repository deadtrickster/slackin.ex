FROM debian:jessie
MAINTAINER Ilya Khaprov <i.khaprov@gmail.com>

ARG port=4000

## os env
ENV DEBIAN_FRONTEND noninteractive
ENV SHELL=/bin/sh

## E/E env
ENV MIX_ENV=prod
ENV REPLACE_OS_VARS=true

## Application env
EXPOSE $port
ENV PORT=$port

## libcrypto
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl1.0.0

## locale stuff
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
RUN apt-get install -y --no-install-recommends locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && dpkg-reconfigure locales

COPY . .
ENTRYPOINT ["./slackin_ex/bin/slackin_ex"]
