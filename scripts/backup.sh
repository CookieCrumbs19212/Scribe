# Core backup functions for Scribe backup script.

# Performs checks to prevent fatal errors during backup creation.
function perform_pre_backup_checks {
    # Checking if the backup_list.conf file exists.
    # The backup_list.conf contains a list of directories and files that need to be included in the backup.
    if [ ! -f "${BACKUP_LIST}" ]; then
        log -f "Backup failed: ${BACKUP_LIST} file is missing"
        log -b
        exit 1

    else
        # Check if the backup list is empty.
        if [ ! -s "${BACKUP_LIST}" ]; then
            log -f "Backup failed: backup list is empty"
            log -b
            exit 1
        fi
    fi

    # Check if the backup location has been set.
    if [[ ! -d "$BACKUP_LOC" ]]; then
        log -f "Backup location has not been set"
        log -b
        exit 1
    fi


    # Checks completion message.
    log -b
    log -d "All checks completed"
}


# Creates the backup.
function create_backup {
    log -i "Backup started"

    # Loop removes oldest backups to make room for current backup.
    # -ge is the 'greater than or equal to' operator.
    while [ "$(get_stored_backup_count)" -ge "$BACKUP_LIMIT" ]
    do
        delete_oldest_backup
    done

    # Getting timestamp.
    BACKUP_TIMESTAMP=$(get_timestamp)
    
    # Filename for the backup is obtained by replacing the whitespaces in the BACKUP_TIMESTAMP with underscores.
    BACKUP_FILENAME="${FILENAME_PREFIX}${BACKUP_TIMESTAMP//[ ]/_}"

    # The destination where the backup file will be stored.    
    BACKUP_DESTINATION="${BACKUP_LOC}${BACKUP_FILENAME}.tar.gz"

    # Variable to store the list of directory/file names as a single line string separated by spaces.
    BACKUP_DIRS=""
    # Loop to create the single line string of directory names from BACKUP_LIST.
    while read -r directory_path
    do
        BACKUP_DIRS+=" $directory_path"
    done < "$BACKUP_LIST"

    # Generating the exclude string to pass to the tar command.
    # Stores the list of dirs and files to exclude from backup as a single line string separated by spaces.
    EXCLUDE_FILES=""
    
    # Exclude the current working directory of the backup script and its supporting files.
    if [[ "$EXCLUDE_SCRIPT_FILES" = true ]]; then
        # Get the current working directory.
        CWD=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
        EXCLUDE_FILES+="--exclude='$CWD'"
    fi

    # If the exclude list file is not empty, read its contents.
    if [ ! -s "${EXCLUDE_LIST}" ]; then
        # Loop to create the single line string of directory names from EXCLUDE_LIST.
        while read -r file_path
        do
            EXCLUDE_FILES+=" --exclude='$file_path'"
        done < "$EXCLUDE_LIST"
    fi
    
    # Clear any previous logs in the TAR_LOG and TAR_ERROR_LOG files.
    truncate -s 0 "$TAR_LOG" && log -d "Cleared ${TAR_LOG}"
    truncate -s 0 "$TAR_ERROR_LOG" && log -d "Cleared ${TAR_ERROR_LOG}"
    
    # Create the backup as a compressed tar archive
    # -c creates a tar archived file
    # -f indicates the archive should be a file
    # -v verbose - show all the files being archived and compressed
    # -z compress the tar file into a zip file (hence the file extension ".tar.gz", "gz" stands for GNU Zipped Archive)
    # -p preserves the file permissions of the files (only required during extraction of tar files)
    
    # To log the tar verbose outputs to tar_verbose.log.
    if [ "$LOG_TAR_VERBOSE" = true ]; then
        # Verbose output (i.e. stdout) redirected to TAR_LOG. Error messages (i.e. stderr) redirected to TAR_ERROR_LOG. 
        sudo tar "${EXCLUDE_FILES}" -cvpzf "${BACKUP_DESTINATION}" "${BACKUP_DIRS}" >> "$TAR_LOG" 2> "$TAR_ERROR_LOG"
    else
        # Error messages (i.e. stderr) redirected to TAR_ERROR_LOG. 
        sudo tar "${EXCLUDE_FILES}" -cpzf "${BACKUP_DESTINATION}" "${BACKUP_DIRS}" 2> "$TAR_ERROR_LOG"
    fi

    # Check if the tar_error log is not empty. If not empty: print the error messages to the main log.
    while read -r error_log
    do
        # If this error message is encountered, then a fatal error has occurred and the script should be exited.
        if [ "$error_log" = "tar: Error is not recoverable: exiting now" ]; then
            log -f "$error_log"
            log -b
        # If any of the logs contain the word "error", log them to the Main Log with the -e option.
        elif [[ "$error_log" == *"Error"* ]] || [[ "$error_log" == *"ERROR"* ]]; then
            log -e "$error_log"
        else 
            log -d "$error_log"
        fi
    done < "$TAR_ERROR_LOG"

    # Check if the backup file has been created successfully.
    if [ -s "${BACKUP_DESTINATION}" ]; then
        log -i "Backup created successfully"
        log -b
        exit 0
    else
        log -f "Backup failed unexpectedly"
        log -b
        exit 1
    fi
}