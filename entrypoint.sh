#!/bin/bash

replication_ready() {
  # just check replication got started
  running_threads=$(mysql -uroot -hreplica -P3307 -Be 'show replica status\G' | egrep -c 'Replica_(IO|SQL)_Running: Yes$')
  [ "$running_threads" -eq 2 ] && return 0
  return 1
}

echo "# $0: waiting for replication to be running"
until replication_ready; do
  echo "# $0: waiting for 'replica' to replicate from primary =="
  sleep 5
done

echo "# $0: enabling toxiproxy proxies"
curl -sLX POST http://toxiproxy:8474/reset

echo "# executing gh-ost command"
touch /postpone.flag
gh-ost $*
