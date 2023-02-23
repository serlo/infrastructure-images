#!/bin/sh

set -e

source ./utils.sh

log_info "run serlo.org dbdump"

mysql_connect="--host=${MYSQL_HOST} --port=${MYSQL_PORT} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD}"

set +e
mysql $mysql_connect -e "SHOW DATABASES; USE serlo; SHOW TABLES;" | grep uuid >/dev/null 2>/dev/null
if [[ $? != 0 ]]; then
    log_info "database serlo does not exist; nothing to dump"
    exit 0
fi
set -e

cd /tmp

log_info "dump serlo.org database - start"
log_info "dump database schema"

mysqldump $mysql_connect --no-data --lock-tables=false --add-drop-database serlo >mysql.sql

for table in ad ad_page attachment_container attachment_file blog_post comment comment_vote entity entity_link entity_revision entity_revision_field event event_log event_parameter event_parameter_name event_parameter_string event_parameter_uuid flag instance instance_permission language license metadata metadata_key migrations navigation_container navigation_page navigation_parameter navigation_parameter_key notification notification_event page_repository page_repository_role page_revision permission related_content related_content_category related_content_container related_content_external related_content_internal role role_inheritance role_permission role_user subscription taxonomy term term_taxonomy term_taxonomy_comment term_taxonomy_entity type url_alias uuid; do
    mysqldump $mysql_connect --no-create-info --lock-tables=false --add-locks serlo $table >>mysql.sql
done
# just dump teachers for data protection reasons
mysqldump $mysql_connect --no-create-info --lock-tables=false --add-locks --where "field = 'interests' and value = 'teacher'" serlo user_field >>mysql.sql
mysql $mysql_connect --batch -e "SELECT id, concat(@rn:=@rn+1, '@localhost') as email, username, '8a534960a8a4c8e348150a0ae3c7f4b857bfead4f02c8cbf0d' AS password, logins, date, concat(@rn:=@rn+1, '') as token, last_login, description FROM user, (select @rn:=2) r;" serlo >user.csv

log_info "dump identities data"

export PGPASSWORD=$POSTGRES_PASSWORD
postgres_connect="--host=${POSTGRES_HOST} --user=serlo kratos"
# export the production data and then import it into local database to easier manipulate it. Better idea?
pg_dump $postgres_connect >temp.sql
psql --quiet -c "create user serlo;"
psql --quiet -c "create database kratos;"
psql --quiet -c "grant all privileges on database kratos to serlo;"
psql -d kratos <temp.sql
rm temp.sql
# hash emails to anonymize them. We could even use a salt to make it more difficult to hack.
# Since we have many tables to insert the email, the solution used in mysql doesn't seem easy to implement (or am I wrong?).
psql --quiet kratos -c "UPDATE identity_credentials SET config = '{\"hashed_password\": \"\$sha1\$pf=e1NBTFR9e1BBU1NXT1JEfQ==\$YTQwYzEwY2ZlNA==\$hTlqikjjSFoK43S4V7+t8CyMvw0=\"}';"
psql --quiet kratos -c "UPDATE identity_verifiable_addresses SET value = concat(md5(value), '@localhost');"
psql --quiet kratos -c "UPDATE identity_credential_identifiers SET identifier = concat(md5(identifier), '@localhost');"
psql --quiet kratos -c "UPDATE identity_recovery_addresses SET value = concat(md5(value), '@localhost');"
psql --quiet kratos -c "UPDATE identities SET traits = JSONB_SET(traits, '{email}', TO_JSONB(CONCAT(md5(traits ->> 'email'), '@localhost')));"
psql --quiet kratos -c "TRUNCATE sessions CASCADE;"
psql --quiet kratos -c "TRUNCATE continuity_containers CASCADE;"
psql --quiet kratos -c "TRUNCATE courier_messages CASCADE;"
psql --quiet kratos -c "TRUNCATE sessions CASCADE;"
# TODO: check if some of these tables are needed. Otherwise, truncate them/dump without data
#  identity_recovery_codes
#  identity_recovery_tokens
#  identity_verification_tokens
#  networks
#  selfservice_errors
#  selfservice_login_flows
#  selfservice_recovery_flows
#  selfservice_registration_flows
#  selfservice_settings_flows
#  selfservice_verification_flows
#  session_devices
pg_dump kratos >postgres.sql

log_info "compress database dump"
rm -f *.zip
zip "dump-$(date -I)".zip mysql.sql user.csv postgres.sql >/dev/null

cat <<EOF | gcloud auth activate-service-account --key-file=-
${bucket_service_account_key}
EOF
gsutil cp dump-*.zip "${bucket_url}"
log_info "latest dump ${bucket_url} uploaded to serlo-shared"

log_info "dump of serlo.org database - end"
