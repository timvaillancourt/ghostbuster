#!/bin/bash

replication_ready() {
  # just check replication got started
  running_threads=$(mysql -uroot -hreplica -e 'show replica status\G' | egrep -c 'Replica_(IO|SQL)_Running: Yes$')
  [ "$running_threads" -eq 2 ] && return 0
  return 1
}

echo "# $0: waiting for replication to be running"
until replication_ready; do
  echo "# $0: waiting for 'replica' to replicate from primary =="
  sleep 5
done

gh-ost $*
