FROM alpine:3.17.2
RUN apk update && apk add bash curl python3 python3-dev py-pip build-base && rm -rf /var/cache/apk/*
RUN curl https://sdk.cloud.google.com | bash >/dev/null
ENV PATH=${PATH}:/root/google-cloud-sdk/bin:/root/google-cloud-sdk/platform/gsutil

RUN apk update && apk add mysql-client postgresql zip && rm -rf /var/cache/apk/*

# make a local postgres server to securely and easily manipulate data before dumping
RUN mkdir /run/postgresql
RUN chown postgres:postgres /run/postgresql/
USER postgres
RUN mkdir /var/lib/postgresql/data
RUN chmod 0700 /var/lib/postgresql/data
RUN initdb -D /var/lib/postgresql/data
RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf
RUN echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf
RUN pg_ctl start -D /var/lib/postgresql/data

WORKDIR /tmp
COPY . .

ARG git_revision
ENV GIT_REVISION=$git_revision
ARG version
ENV VERSION $version

CMD ["./run.sh"]
