#!/bin/bash
sleep 10s
status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:18000)
if [ "$status_code" -eq 200 ] ; then
  echo "Service is working fine"
  exit 0
else
  echo "Site status changed to $status_code"
  exit 1
fi