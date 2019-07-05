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

log_info "run athene2 dbdump version $VERSION revision $GIT_REVISION"

connect="-h $ATHENE2_DATABASE_HOST --port $ATHENE2_DATABASE_PORT -u $ATHENE2_DATABASE_USER -p$ATHENE2_DATABASE_PASSWORD"

if [[ "$ATHENE2_DATABASE_HOST" == "" ]] ; then
    log_fatal "database host not set"
fi

set +e
mysql $connect -e "SHOW DATABASES; USE serlo; SHOW TABLES;" | grep uuid >/dev/null 2>/dev/null
if [[ $? != 0 ]] ; then
    log_info "database serlo das not exist nothing to dump"
    exit 0
fi
set -e

cd /tmp

log_info "dump serlo database - start"
log_info "dump database schema"

mysqldump $connect --no-data --lock-tables=false --add-drop-database serlo >dump.sql

log_info "dump database data"
mysqldump $connect --no-create-info --lock-tables=false --add-locks serlo >> dump.sql

log_info "anonymize database dump"
sed -i -r "/([0-9]+, ?)'[^']+\@[^']+', ?'[^']+', ?'[^']+',( ?[0-9]+, ?'[^']+', ?[0-9], ?)'[^']+'/ s//\1CONCAT\(LEFT\(UUID\(\), 8\),'@localhost'\), LEFT\(UUID\(\), 8\), '8a534960a8a4c8e348150a0ae3c7f4b857bfead4f02c8cbf0d',\2LEFT\(UUID\(\), 8\)/" dump.sql

log_info "compress database dump"
rm -f *.zip
zip "dump-$(date -I)".zip dump.sql >/dev/null

bucket_folder="${GCLOUD_BUCKET_URL}"

if [[ "${bucket_folder}" != "" ]] ; then
    echo ${GCLOUD_SERVICE_ACCOUNT_KEY} >/tmp/service_account_key.json
    gcloud auth activate-service-account ${GCLOUD_SERVICE_ACCOUNT_NAME} --key-file /tmp/service_account_key.json
    gsutil cp dump-*.zip "${bucket_folder}"
    log_info "latest dump ${bucket_folder} uploaded to serlo-shared"
fi

log_info "dump of serlo database - end"
