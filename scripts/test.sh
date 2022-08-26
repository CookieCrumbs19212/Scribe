#! /bin/bash

. conf/configurations.conf

BACKUP_TYPE=1

if (( "$BACKUP_TYPE" == 1 )); then
    echo "val is 1"
else
    echo "val is 0"
fi