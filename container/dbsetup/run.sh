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

if [[ ! -f /tmp/dump.zip ]] ; then
    if [[ "${GCLOUD_BUCKET_URL}" != "" ]] ; then
        echo ${GCLOUD_SERVICE_ACCOUNT_KEY} >/tmp/service_account_key.json
        gcloud auth activate-service-account ${GCLOUD_SERVICE_ACCOUNT_NAME} --key-file /tmp/service_account_key.json
        bucket_file=$(gsutil ls -l gs://anonymous-data | grep dump | sort -rk 2 | sed 1q | awk '{ print $3 }')
        if [[ "${bucket_file}" == "" ]] ; then
            log_warn "no anonymous database dump available in gs://anonymous-data"
            exit 1
        fi
        gsutil cp ${bucket_file} /tmp/dump.zip
        log_info "latest dump ${bucket_file} downloaded from serlo-shared"
        mysql $connect serlo -e "SET FOREIGN_KEY_CHECKS = 0; DROP TABLE IF EXISTS uuid; DROP TABLE IF EXISTS event_parameter_uuid"
    fi
fi

for retry in 1 2 3 4 5 6 7 8 9 10 ; do
    log_info "check if athene2 database exists"
    mysql $connect -e "SHOW DATABASES" | grep "serlo" >/dev/null 2>/dev/null && mysql $connect -e "USE serlo; SHOW TABLES;" | grep uuid >/dev/null 2>/dev/null
    if [ $? -ne 0 ] ; then
        log_info "could not find serlo database or atleast uuid table is missing - lets import the latest dump"
        if [[ -f /tmp/dump.zip ]] ; then
            rm -f /tmp/dump.sql
            unzip /tmp/dump.zip -d /tmp
            if [[ $? != 0 ]] ; then
                log_warn "could not unzip dump zip - failure" ; exit 1
            fi
        else
            log_info "no dump zip file present"
            retry
            continue
        fi

        mysql $connect serlo </tmp/dump.sql
        if [[ $? != 0 ]] ; then
            log_warn "import dump failed" ; retry
            continue
        else
            log_info "import serlo database was successful" ; exit 0
        fi
    else
        log_info "serlo database exists - nothing to do" ; exit 0
    fi
    log_info "serlo database does not exist" ; retry
done

log_error "could not add dump - retrying with cron"
