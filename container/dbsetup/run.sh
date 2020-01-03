#!/bin/sh

log_info() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"info\",\"time\":\"$time\",\"message\":\"$1\"}"
}

log_fatal() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"fatal\",\"time\":\"$time\",\"message\":\"$1\"}"
}

log_warn() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"warn\",\"time\":\"$time\",\"message\":\"$1\"}"
}

retry() {
    seconds=30
    log_info "retrying in ${seconds} seconds"
    sleep ${seconds}
}

log_info "run athene2 dbsetup version $VERSION revision $GIT_REVISION"

# add nameserver as currently alpine images dns seems not to work properly in GKE
cat /etc/resolv.conf | grep 1.1.1.1 || printf "\nnameserver 1.1.1.1\n" >> /etc/resolv.conf

connect="-h $ATHENE2_DATABASE_HOST --port $ATHENE2_DATABASE_PORT -u $ATHENE2_DATABASE_USER -p$ATHENE2_DATABASE_PASSWORD"

log_info "wait for athene2 database to be ready"
until mysql $connect -e "SHOW DATABASES" >/dev/null 2>/dev/null
do
    log_warn "could not find athene2 server - retry in 10 seconds"
    sleep 10
done

log_info "create serlo database if it's not there yet"
mysql $connect -e "CREATE DATABASE IF NOT EXISTS serlo"

[ -z "GCLOUD_BUCKET_URL" ] && { log_fatal "GCLOUD_BUCKET_URL not given"; exit 1; }

echo $GCLOUD_SERVICE_ACCOUNT_KEY > /tmp/service_account_key.json
gcloud auth activate-service-account ${GCLOUD_SERVICE_ACCOUNT_NAME} --key-file /tmp/service_account_key.json
newest_dump_uri=$(gsutil ls -l gs://anonymous-data | grep dump | sort -rk 2 | head -n 1 | awk '{ print $3 }')
[ -z "$newest_dump_uri" ] && { log_fatal "no database dump available in gs://anonymous-data"; exit 1; }
newest_dump=$(basename $newest_dump_uri)
[ -f "/tmp/$newest_dump" ] && exit 0

gsutil cp $newest_dump_uri "/tmp/$newest_dump"
log_info "downloaded newest dump $newest_dump"
unzip -o "$newest_dump" -d /tmp || { log_error "unzip of dump file failed"; exit 1; }
mysql $connect serlo < "/tmp/dump.sql" || { log_error "import of dump failed"; exit 1; }
log_info "imported serlo database dump $newest_dump"

# delete all unnecessary files
rm -f $(ls /tmp/dump*.zip | grep -v $newest_dump)
rm $(ls /tmp/dump.sql)
