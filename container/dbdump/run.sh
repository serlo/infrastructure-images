#!/bin/sh

set -e

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

check_serlo_db() {
    until mysql $1 -e "SHOW DATABASES" >/dev/null 2>/dev/null && mysql $1 -e "USE serlo; SHOW TABLES;" | grep uuid >/dev/null 2>/dev/null
    do 
        log_warn "could not connect to athene2 database instance error [$?]- retrying later"
        sleep 30
    done
}

log_info "run athene2 dbdump version $VERSION revision $GIT_REVISION"

connect="-h $ATHENE2_DATABASE_HOST --port $ATHENE2_DATABASE_PORT -u $ATHENE2_DATABASE_USER -p$ATHENE2_DATABASE_PASSWORD"

log_info "run anonymizer revision [$GIT_REVISION]"

if [[ "$ATHENE2_DATABASE_HOST" == "" ]] ; then
    log_fatal "database host not set"
fi

wait_for_serlo_db $connect

log_info "dump serlo database - start"

log_info "dump database schema"
mysqldump $connect \
    --no-data \
    --lock-tables=false \
    --add-drop-database \
    serlo \
    > /tmp/dump.sql

cd /tmp

log_info "dump database data"
mysqldump $connect \
    --no-create-info \
    --lock-tables=false \
    --add-locks \
    serlo \
    >> dump.sql

log_info "anonymize database ump"
sed -i -r "/([0-9]+, ?)'[^']+\@[^']+', ?'[^']+', ?'[^']+',( ?[0-9]+, ?'[^']+', ?[0-9], ?)'[^']+'/ s//\1CONCAT\(LEFT\(UUID\(\), 8\),'@localhost'\), LEFT\(UUID\(\), 8\), '8a534960a8a4c8e348150a0ae3c7f4b857bfead4f02c8cbf0d',\2LEFT\(UUID\(\), 8\)/" dump.sql

log_info "compress database dump"
rm -f *.zip
cd zip "dump-$(date -I)".zip dump.sql >/dev/null

bucket_folder="${GCLOUD_BUCKET_URL}"

if [[ "${bucket_folder}" != "" ]] ; then
    echo ${GCLOUD_SERVICE_ACCOUNT_KEY} >/tmp/service_account_key.json
    gcloud auth activate-service-account ${GCLOUD_SERVICE_ACCOUNT_NAME} --key-file /tmp/service_account_key.json  
    gsutil cp dump.zip ${bucket_folder}
    log_info "latest dump ${bucket_folder} uploaded to serlo-shared"
fi

log_info "dump of serlo database - end"
