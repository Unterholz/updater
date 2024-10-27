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
REQUIRED_VARS=("NODE" "CLUSTER" "USERNAME" "PASSWORD" "SERVICES")

for var in "${REQUIRED_VARS[@]}"; do
  case "${!var}" in
  "")
    echo "Error: $var is not set"
    exit 1
    ;;
  *) ;;
  esac
done

# add node to cluster
/opt/couchbase/bin/couchbase-cli server-add \
  -c $CLUSTER:8091 \
  -u $USERNAME \
  -p $PASSWORD \
  --server-add=https://$NODE:18091 \
  --server-add-username=$USERNAME \
  --server-add-password=$PASSWORD \
  --services=$SERVICES
