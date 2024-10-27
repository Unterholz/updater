#!/bin/bash

# ================================================
# Couchbase Upgrade Automation Script
# with Optional Spare Node on Red Hat Linux for
# automating the process of upgrading a
# full-capacity Couchbase cluster online.
#
# 2024 - juanmanuel.ventura@spindox.it / federico.gallucci@spindox.it
# ================================================

# Check all of required environment variables
REQUIRED_VARS=("NODE" "USER" "TARGET")

for var in "${REQUIRED_VARS[@]}"; do
  case "${!var}" in
  "")
    echo "Error: $var is not set"
    exit 1
    ;;
  *) ;;
  esac
done

ssh "$USER@$NODE" <<EOF
  #  stop the service
  systemctl stop couchbase-server.service

  #  remove the package
  yum autoremove couchbase-server -y

  #  remove current configuration
  rm -fr /opt/couchbase

  # get the target package version
  curl -O https://packages.couchbase.com/releases/$TARGET/couchbase-server-enterprise-$TARGET-linux.x86_64.rpm

  #  install the target package
  yum install -y ./couchbase-server-enterprise-$TARGET-linux.x86_64.rpm

  # reload
  systemctl daemon-reload

  #  restart the service
  systemctl start couchbase-server.service

  # Reload the certificates before adding back the node to the cluster
  curl -X POST $NODE:8091/node/controller/loadTrustedCAs
  curl -X POST $NODE:8091/node/controller/reloadCertificate

  #  remove the local package fron the fs
  rm -f ./couchbase-server-enterprise-$TARGET-linux.x86_64.rpm
EOF
