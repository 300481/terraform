#!/bin/sh

nproc
uname -a
free -g


exit 0

curl -s https://api.github.com/repos/hashicorp/terraform/tags?per_page=5 \
| jq -r '.[].name' \
| sed -e 's/^v//g' \
| while read version ; do 
    docker build \
        --build-arg version=$version \
        -t ghcr.io/300481/terraform:$version .
done
