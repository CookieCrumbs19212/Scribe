# Setters for Scribe backup script.

# Setter for the backup limit.
function set_backup_limit {
    # Making sure that the input is a number.
    if [[ ! "$1" =~ ^[0-9]+$ ]]; then
        echo "input is not a number"
        exit 1
    else
        # If the input is valid, assign it to BACKUP_LIMIT.
        BACKUP_LIMIT=$1
    fi
}


# Setter for filename prefix.
function set_filename_prefix {
    # Check if the input contains any illegal filename characters.
    # [[ "$1" == *\\* ]] || [[ "$1" =~ ['!@#$%^&*()+'] ]]
    if [[ "$1" == */* ]]; then
        echo "filename prefix contains illegal characters"
    else
        # If the input does not contain illegal characters, assign to FILENAME_PREFIX.
        FILENAME_PREFIX="$1"
    fi
}


# Setter for the backup location.
function set_backup_location {
    # Check that the input points is a valid directory path.
    if [[ ! -d "$1" ]]; then
        echo "$1 is not a valid location or does not exist."
    else
        # If the input is valid, assign it to BACKUP_LOC.
        BACKUP_LOC=$LOCAL_BACKUP_LOC
    fi
}