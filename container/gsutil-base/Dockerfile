FROM alpine
RUN apk update && apk add bash curl python python-dev py-pip build-base && rm -rf /var/cache/apk/*
RUN curl https://sdk.cloud.google.com | bash
ENV PATH=${PATH}:/root/google-cloud-sdk/platform/gsutil
ADD run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh
RUN find / -name gsutil
WORKDIR /tmp
CMD ["/bin/sh", "run.sh"]
ARG git_revision
ENV GIT_REVISION=$git_revision
ENV GCLOUD_BUCKET=gs://serlo_dev_terraform
