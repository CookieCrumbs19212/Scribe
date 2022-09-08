# Core backup functions for Scribe backup script.

# Performs checks to prevent fatal errors during backup creation.
function perform_pre_backup_checks {
    # Check if the backup location has been set.
    if [[ "$BACKUP_LOC" == "" ]] || [[ ! -d "$BACKUP_LOC" ]]; then
        log -f "Backup location has not been set"
        log -b
        exit 1
    fi


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


    # Checks completion message.
    log -b
    log -d "All checks completed"
}


# Creates the backup.
function create_backup {
    log -i "Started back up process"


    # Clear any previous logs in the TAR_VERBOSE_LOG and TAR_ERROR_LOG files.
    truncate -s 0 "$TAR_VERBOSE_LOG" && log -d "Cleared ${TAR_VERBOSE_LOG}"
    truncate -s 0 "$TAR_ERROR_LOG" && log -d "Cleared ${TAR_ERROR_LOG}"


    # Loop removes oldest backups to make room for current backup.
    # -ge is the 'greater than or equal to' operator.
    while [ "$(get_stored_backup_count)" -ge "$BACKUP_LIMIT" ]
    do
        delete_oldest_backup
    done


    # Array used to build the command.
    # command pattern: tar [options] [backup destination] [paths of files to back up] -X [exclude_list_file_path] --exclude file_names >> redirection 2> err redirection
    local command
    # Control variable for loops in this function.
    local DONE


    # Add tar command to command string.
    command+=( "tar" )


    # Exclude the current working directory of the Scribe backup script and its supporting files.
    # Getting the parent path of the parent path.
    CWD=$(cd "$(dirname "$( dirname "${BASH_SOURCE[0]}" )" )" &> /dev/null && pwd)
    
    # If the parent dir of the Scribe dir is in the backup list and EXCLUDE_SCRIPT_FILES is true, exclude it.
    if [[ "$EXCLUDE_SCRIPT_FILES" = true ]]; then
        # Get the current working directory.
        CWD=$(cd "$(dirname "$( dirname "${BASH_SOURCE[0]}" )" )" &> /dev/null && pwd)
        
        # Adding "--exclude=<Scribe directory>" string to command.
        command+=("--exclude=$CWD")
    fi


    # Create the backup as a compressed tar archive
    # -c creates a tar archived file
    # -f indicates the archive should be a file
    # -v verbose - show all the files being archived and compressed
    # -z compress the tar file into a zip file (hence the file extension ".tar.gz", "gz" stands for GNU Zipped Archive)
    # -p preserves the file permissions of the files (only required during extraction of tar files)

    # Adding tar options to command. Add "v" option if LOG_TAR_VERBOSE is true.
    [[ "$LOG_TAR_VERBOSE" = true ]] && command+=( "-cvzf" ) || command+=( "-czf" )
    

    # Getting timestamp.
    BACKUP_TIMESTAMP=$(get_timestamp)
    
    # Filename for the backup is obtained by replacing the whitespaces in the BACKUP_TIMESTAMP with underscores.
    BACKUP_FILENAME="${FILENAME_PREFIX}${BACKUP_TIMESTAMP//[ ]/_}"

    # The destination where the backup file will be stored.    
    BACKUP_DESTINATION="${BACKUP_LOC}${BACKUP_FILENAME}.tar.gz"

    # Adding backup destination to command.
    command+=("$BACKUP_DESTINATION")


    # Clear any blank lines in the exclude list.
    sed -i '/^$/d' "$EXCLUDE_LIST"

    # Adding EXCLUDE_LIST to command using "--exclude-from" flag.
    command+=("--exclude-from=$EXCLUDE_LIST")


    # Clear any blank lines in the backup list.
    sed -i '/^$/d' "$BACKUP_LIST"

    # Loop to create an array BACKUP_PATHS containing paths to dirs/files to back up from BACKUP_LIST.
    DONE=false
    until $DONE; do
        read -r path || DONE=true
        # Only add the path to the BACKUP_PATHS array if it is not an empty string.
        if [[ ! "$path" == "" ]]; then
            BACKUP_PATHS+=("$path")
        fi
    done < "$BACKUP_LIST"

    # Converting the array BACKUP_PATHS to a space separated string and adding to command.
    command+=("${BACKUP_PATHS[@]}")
    
    
    # Adding stdout redirection to command To log the tar verbose outputs to tar_verbose.log.
    if [ "$LOG_TAR_VERBOSE" = true ]; then
        # Verbose output (i.e. stdout) redirected to TAR_VERBOSE_LOG. Error messages (i.e. stderr) redirected to TAR_ERROR_LOG. 
        command+=(">> $TAR_VERBOSE_LOG 2> $TAR_ERROR_LOG")
    else
        # Error messages (i.e. stderr) redirected to TAR_ERROR_LOG. 
        command+=(">> /dev/null 2> $TAR_ERROR_LOG")
    fi


    # Execute the tar command.
    "${command[@]}"


    # Check if the tar_error log is not empty. If not empty: print the error messages to the main log.
    DONE=false
    until $DONE; do
        read -r error_log || DONE=true

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