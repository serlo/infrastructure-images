FROM alpine
RUN apk update && apk add bash curl python3 python3-dev py-pip build-base && rm -rf /var/cache/apk/*
RUN curl https://sdk.cloud.google.com | bash >/dev/null
ENV PATH=${PATH}:/root/google-cloud-sdk/bin:/root/google-cloud-sdk/platform/gsutil

RUN apk update && apk add mysql-client zip && rm -rf /var/cache/apk/*
ARG git_revision
ENV GIT_REVISION=$git_revision
ARG version
ENV VERSION $version
CMD ["/tmp/run.sh"]
