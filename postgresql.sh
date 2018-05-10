#!/bin/bash

# clone postrges repository
tmppg=$(mktemp -d)
git clone https://github.com/docker-library/postgres/ "${tmppg}"
pushd "${tmppg}" > /dev/null
# and pick the version behind postres:10.3 image
git checkout 6fe8c15843400444e4ba6906ec6f94b0d526a678
pushd 10 > /dev/null
# remove the VOLUME line
sed -i '/VOLUME \/var\/lib\/postgresql\/data/d' Dockerfile
# and build a new image
docker build -t postgres:10 .
popd > /dev/null
popd > /dev/null
rm -rf "${tmppg}"
