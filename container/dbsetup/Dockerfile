FROM alpine
RUN apk update && apk add bash curl python3 python3-dev py-pip build-base && rm -rf /var/cache/apk/*
RUN curl https://sdk.cloud.google.com | bash >/dev/null
ENV PATH=${PATH}:/root/google-cloud-sdk/bin:/root/google-cloud-sdk/platform/gsutil

RUN apk update && apk add mysql-client unzip && rm -rf /var/cache/apk/*
ADD ./cron.sh /tmp/
ADD ./run.sh /tmp/run
RUN /bin/chmod +x /tmp/cron.sh && /bin/chmod +x /tmp/run
ARG git_revision
ENV GIT_REVISION=$git_revision
ARG cron_pattern
ENV CRON_PATTERN $cron_pattern
ARG version
ENV VERSION $version
CMD ["/tmp/cron.sh"]
