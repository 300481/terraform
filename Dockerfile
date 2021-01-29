ARG version

FROM hashicorp/terraform:${version}

RUN apk add --no-cache jq curl

ARG version

LABEL org.label-schema.name="terraform" \
      org.label-schema.description="Terraform Container Image with additional tools installed" \
      org.label-schema.version=$version