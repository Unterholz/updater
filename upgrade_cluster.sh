#!/bin/bash

# ================================================
# Couchbase Upgrade Automation Script
# with Optional Spare Node on Red Hat Linux for
# automating the process of upgrading a
# full-capacity Couchbase cluster online.
#
# 2024 - juanmanuel.ventura@spindox.it / federico.gallucci@spindox.it
# ================================================

export SPARE="37.27.84.179" #SPARE
export TARGET="7.6.3"
export USERNAME="Administrator"
export PASSWORD="spindox"
export SERVICES="data,index,query"
export NODES=("37.27.204.206" "95.216.205.85" "37.27.185.245")

resolve_cluster_address() {
  if [[ "${NODES[0]}" == $1 ]]; then
    echo "${NODES[1]}" # Return the second item if the first matches the exclude
  else
    echo "${NODES[0]}" # Return the first item if it doesn't match the exclude
  fi
}

log() {
  echo -e "\e[32m=> $1\e[0m"
}

warn() {
  echo -e "\e[33m=> $1\e[0m"
}

fatal() {
  echo -e "\e[31m=> $1\e[0m"
  exit 1
}

# === Stage 1: Backup the Cluster Data ===
log "Starting Stage 1: Backup Cluster Data"
BACKUP_DIR="/root/backup" CLUSTER=$(resolve_cluster_address) ./backup.sh

if [ $? -eq 0 ]; then
  echo "Backup completed successfully."
else
  echo "Backup failed."
  exit 1
fi

# === Stage 2: Add Spare Node ===
log "Starting Stage 2: Add Spare Node $SPARE"
CLUSTER=$(resolve_cluster_address) NODE=$SPARE ./add_node.sh

if [ $? -eq 0 ]; then
  echo "Spare node $SPARE added successfully."
else
  echo "Failed to add spare node."
  exit 1
fi

# === Stage 3: Rebalance the Cluster ===
log "Starting Stage 3: Rebalance the Cluster"
CLUSTER=$(resolve_cluster_address) ./rebalance.sh

if [ $? -eq 0 ]; then
  echo "Rebalance completed successfully."
else
  echo "Rebalance failed."
  exit 1
fi

# === Stage 4: Remove and Upgrade Each Node Sequentially ===
log "Starting Stage 4: Remove each node, upgrade, and re-add it to the cluster"
for CURRENT in "${NODES[@]}"; do
  echo "Removing $CURRENT"
  CLUSTER=$(resolve_cluster_address $CURRENT) NODE=$CURRENT ./remove_node.sh

  if [ $? -eq 0 ]; then
    echo "Node $CURRENT removed successfully."
  else
    echo "Failed to rebalance after removing node $CURRENT."
    exit 1
  fi

  echo "Upgrading $CURRENT"
  # invoke real upgrade script here

  TARGET=$TARGET NODE=$CURRENT ./upgrade_node.sh

  if [ $? -eq 0 ]; then
    echo "Node $CURRENT upgraded successfully."
    # warn "Sleeping for 10secs to simulate node upgrade."
    # sleep 10
  else
    echo "Failed to upgrade node $CURRENT."
    exit 1
  fi

  echo "Adding $CURRENT back againg to the cluster"
  CLUSTER=$(resolve_cluster_address $CURRENT) NODE=$CURRENT ./add_node.sh

  if [ $? -eq 0 ]; then
    echo "Node $CURRENT added back to the cluster successfully."
  else
    echo "Failed to add back node $CURRENT to the cluster."
    exit 1
  fi

done

# === Stage 5: Remove Spare Node ===
log "Starting Stage 5: Remove Spare Node"
CLUSTER=$(resolve_cluster_address $SPARE) NODE=$SPARE ./remove_node.sh

log "Couchbase cluster upgrade process completed successfully!"
