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
REQUIRED_VARS=("NODE" "TARGET")

for var in "${REQUIRED_VARS[@]}"; do
  case "${!var}" in
  "")
    echo "Error: $var is not set"
    exit 1
    ;;
  *) ;;
  esac
done

# replace this with Viseca's actual upgrade script

#  stop the service
systemctl stop couchbase-server.service
#  remove the package
yum autoremove couchbase-server -y
#  remove current configuration
# rm -r /opt/couchbase
# get the target package version
curl -O https://packages.couchbase.com/releases/$TARGET/couchbase-server-enterprise-$TARGET-linux.x86_64.rpm
#  install the target package
yum install -y ./couchbase-server-enterprise-$TARGET-linux.x86_64.rpm

systemctl daemon-reload

#  restart the service
systemctl start couchbase-server.service

#  remove the local package fron the fs
rm -f ./couchbase-server-enterprise-$TARGET-linux.x86_64.rpm
