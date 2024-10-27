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
REQUIRED_VARS=("NODE" "CLUSTER" "USERNAME" "PASSWORD")

for var in "${REQUIRED_VARS[@]}"; do
  case "${!var}" in
  "")
    echo "Error: $var is not set"
    exit 1
    ;;
  *) ;;
  esac
done

echo "Removing node: $NODE"

# Remove node from cluster
/opt/couchbase/bin/couchbase-cli rebalance -c $CLUSTER:8091 -u $USERNAME -p $PASSWORD --server-remove=$NODE:8091

if [ $? -eq 0 ]; then
  echo "Node removed successfully."
else
  echo "Failed to remove node $NODE."
  exit 1
fi
