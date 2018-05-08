#!/bin/bash

tmpcfg="$(mktemp)"
cat > "${tmpcfg}" <<__EOF__
bootstrap:
  dcs:
    postgresql:
      use_pg_rewind: true
  initdb:
  - auth-host: md5
  - auth-local: trust
  - encoding: UTF8
  - locale: en_US.UTF-8
  - data-checksums
  pg_hba:
  - host all all 0.0.0.0/0 md5
  - host replication ${PATRONI_REPLICATION_USERNAME} ${PATRONI_KUBERNETES_POD_IP}/16    md5
restapi:
  connect_address: ${PATRONI_KUBERNETES_POD_IP}:8008
postgresql:
  connect_address: ${PATRONI_KUBERNETES_POD_IP}:5432
  authentication:
    replication:
      username: ${PATRONI_REPLICATION_USERNAME}
      password: ${PATRONI_REPLICATION_PASSWORD}
    superuser:
      username: ${PATRONI_SUPERUSER_USERNAME}
      password: ${PATRONI_SUPERUSER_PASSWORD}
__EOF__

unset PATRONI_SUPERUSER_PASSWORD PATRONI_REPLICATION_PASSWORD
export KUBERNETES_NAMESPACE=$PATRONI_KUBERNETES_NAMESPACE
export POD_NAME=$PATRONI_NAME

exec /usr/bin/python /usr/local/bin/patroni "${tmpcfg}"
