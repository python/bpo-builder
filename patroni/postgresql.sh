#!/bin/bash

# clone postrges repository
tmppg=$(mktemp -d)
git clone https://github.com/docker-library/postgres/ "${tmppg}"
pushd "${tmppg}" > /dev/null
pushd 10 > /dev/null
# remove the VOLUME line
sed -i '/VOLUME \/var\/lib\/postgresql\/data/d' Dockerfile
# and build a new image
docker build -t postgres:10 .
popd > /dev/null
popd > /dev/null
rm -rf "${tmppg}"
