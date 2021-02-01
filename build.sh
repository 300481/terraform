#!/bin/bash

TAG_PATTERN="refs/tags/.*"

if [[ ${GITHUB_REF} =~ $TAG_PATTERN ]] ; then
    TAG=$(echo ${GITHUB_REF} | sed -e 's#refs/tags/##g')
    echo Given git tag: ${TAG}
    DOCKER_TAG=$(echo ${TAG} | sed -e 's#^v##g')

    echo $GHTOKEN | docker login ghcr.io -u 300481 --password-stdin
    docker build --build-arg version=${DOCKER_TAG} -t ghcr.io/300481/terraform:${DOCKER_TAG} .
    docker push ghcr.io/300481/terraform:${DOCKER_TAG}
fi

exit 0

