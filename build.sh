#!/bin/bash

TAG_DATA='{"local": [], "remote": [], "diff": []}'
LOCAL_TAGS="https://api.github.com/repos/300481/terraform/tags?per_page=100"
REMOTE_TAGS="https://api.github.com/repos/hashicorp/terraform/tags?per_page=100"

# fetch tags of hashicorp terraform
for TAG in $(curl -s ${REMOTE_TAGS} | jq -r '.[].name') ; do
    TAG_DATA=$(jq '.remote += ['\"${TAG}\"']' <<< ${TAG_DATA})
done

# fetch tags of 300481 terraform
for TAG in $(curl -s ${LOCAL_TAGS} | jq -r '.[].name') ; do
    TAG_DATA=$(jq '.local += ['\"${TAG}\"']' <<< ${TAG_DATA})
done

# find the missing tags
TAG_DATA=$(jq '.diff = .remote - .local' <<< ${TAG_DATA})

# login to docker registry
echo ${TERRAFORM_TOKEN} | docker login ghcr.io -u 300481 --password-stdin

# set git config
git config user.email "gitbot@300481.de"
git config user.name "GitBot"

# build and push the images
for TAG in $(jq -r '.diff[]' <<< ${TAG_DATA} | sed -e 's/^v//g') ; do
    docker build -t ghcr.io/300481/terraform:${TAG} --build-arg version=${TAG} . \
    && docker push  ghcr.io/300481/terraform:${TAG} \
    && git tag -a v${TAG} -m v${TAG} \
    && git push origin v${TAG}
done

# cleanup system
for TAG in $(jq -r '.remote[]' <<< ${TAG_DATA} | sed -e 's/v//g') ; do
    docker image rm ghcr.io/300481/terraform:${TAG}
    docker image rm hashicorp/terraform:${TAG}
done

exit 0

