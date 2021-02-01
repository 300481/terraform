#!/bin/bash

git config --global user.email "gitbot@300481.de"
git config --global user.name "GitBot"

HASHICORP_TAGS=$(curl -s https://api.github.com/repos/hashicorp/terraform/tags?per_page=100i | jq -r '.[].name')
echo ${HASHICORP_TAGS[@]}

for TAG in ${HASHICORP_TAGS[@]} ; do
    git tag -a ${TAG} -m "${TAG}"
done

git push --tags

exit 0

| jq -r '.[].name' \
| sed -e 's/^v//g' \
| while read version ; do 
    docker build \
        --build-arg version=$version \
        -t ghcr.io/300481/terraform:$version .
done
