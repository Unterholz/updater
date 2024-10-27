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
REQUIRED_VARS=("BACKUP_DIR" "CLUSTER" "USERNAME" "PASSWORD")

for var in "${REQUIRED_VARS[@]}"; do
  case "${!var}" in
  "")
    echo "Error: $var is not set"
    exit 1
    ;;
  *) ;;
  esac
done

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Create a new backup repository (only needs to be done once)
/opt/couchbase/bin/cbbackupmgr config --archive $BACKUP_DIR --repo backup_repo

# Backup the cluster data
/opt/couchbase/bin/cbbackupmgr backup --archive $BACKUP_DIR --repo backup_repo --cluster http://$CLUSTER:8091 --username $USERNAME --password $PASSWORD

# Verify backup status
/opt/couchbase/bin/cbbackupmgr info --archive $BACKUP_DIR --repo backup_repo
