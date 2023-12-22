#!/bin/bash

replication_ready() {
  running_threads=$(mysql -uroot -hreplica -e "show replica status\G" | egrep "Replica_(IO|SQL)_Running:" | grep -c 'Yes$')
  if [ "$running_threads" -eq 2 ]; then
    return 0
  else
    return 1
  fi
}

until replication_ready; do
  echo "== Waiting for replica to connect to primary =="
  sleep 2
done

gh-ost $*
