#!/bin/bash

CID=$(docker create -it elixir:latest /bin/sh -c "cd /tmp/slackin_ex && bin/srelease.sh")
docker cp . $CID:/tmp/slackin_ex
docker start -ai $CID
TEMP=$(mktemp -d)
mkdir -p $TEMP
docker cp $CID:/tmp/slackin_ex/_build/prod/rel/slackin_ex $TEMP
docker stop $CID
docker rm $CID
cp Dockerfile $TEMP
docker build $TEMP -t ${1:-deadtrickster/slackin_ex} -f $TEMP/Dockerfile
