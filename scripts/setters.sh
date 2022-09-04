function set_backup_limit {
    BACKUP_LIMIT=$2
}

# Setting the backup location depending on BACKUP_TYPE.
function set_backup_location {
    if (( "$BACKUP_TYPE" == 1 )); then
        BACKUP_LOC=$EXTERNAL_BACKUP_LOC
    else
        BACKUP_LOC=$LOCAL_BACKUP_LOC
    fi
}