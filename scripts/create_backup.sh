#! /bin/bash

#----------------------------------------------------------------------------------------------------------
# Backup Type: 
# Local    (0) : Backup will be stored on the system harddrive. Does not require signature verification.
# External (1) : Backup will be stored on an external harddrive. Requires signature verification procedure.
#----------------------------------------------------------------------------------------------------------

# Checking if the configurations.conf file exists.
if [ ! -s "config/configurations.conf" ]; then
    echo "Backup failed: config/configurations.conf file is missing"
    exit 1
fi

# Sourcing the configurations.conf file.
. config/configurations.conf

# Setting the backup location depending on BACKUP_TYPE.
if (( "$BACKUP_TYPE" == 1 )); then
    BACKUP_LOC=$EXTERNAL_BACKUP_LOC
else
    BACKUP_LOC=$LOCAL_BACKUP_LOC
fi

# Returns current timestamp in format "YYYY-MM-DD UTC<utc-offset> HH:MM:SS".
function get_timestamp {
    echo $(date "+%Y-%m-%d UTC%z %T")
}

# Appends log messages with timestamp to the log file destination in MAIN_LOG.
function log {
    # log syntax:
    #               log -i message_to_be_logged
    #                   $1          $2
    #
    # $1 parameter that contains the log level.
    # $2 parameter contains the log message.
    
    # Log Levels: Debug, Info, Warning, Error, Fatal
    
    case "$1" in
        --debug | -d)
            echo "$(get_timestamp) : DEBUG : $2" >> $MAIN_LOG
        ;;
        
        --info | -i)
            echo "$(get_timestamp) : INFO  : $2" >> $MAIN_LOG

            # -i messages must also be printed to the terminal output.
            echo $2
        ;;
        
        --warning | -w)
            echo "$(get_timestamp) : WARN  : $2" >> $MAIN_LOG
        ;;
        
        --error | -e)
            echo "$(get_timestamp) : ERROR : $2" >> $MAIN_LOG
        ;;
        
        --fatal | -f)
            echo "$(get_timestamp) : FATAL : $2" >> $MAIN_LOG

            # -f messages must also be printed to the terminal output.
            echo $2
        ;;
        
        --break | -b)
            echo "--" >> $MAIN_LOG
        ;;
    
        # wildcard, i.e. default case.
        *)
            echo "Invalid arguments."
        ;;
    esac
}

# Stores the list of dirs and files to exclude from backup as a single line string separated by spaces.
EXCLUDE_FILES=""

# Function to generate the exclude string containing the files to exclude from the backup. 
function generate_exclude_string {
    # Exclude the current working directory of the backup script and its supporting files.
    # Get the current working directory.
    cwd=$(dirname $0)
    EXCLUDE_FILES+="--exclude='$cwd'"

    # If the exclude list file is not empty, read its contents.
    if [ ! -s ${EXCLUDE_LIST} ]; then
        # Loop to create the single line string of directory names from EXCLUDE_LIST.
        while read file_path
        do
            EXCLUDE_FILES+=" --exclude='$file_path'"
        done < $EXCLUDE_LIST
    fi
}

# Checks if the external harddrive where the backups are to be stored is mounted.
function check_external_device_mounted {
    if [ -d "${BACKUP_LOC}" ]; then
        log -d "External Backup Device found."
    else 
        log -f "Backup failed: External Backup Device is either not connected or not mounted"
        log -b
        exit 1
    fi
}

# SECURITY MEASURE:
# Checks if the signature files in the system and the external device match.
# This prevents the backup files from being stored on an unkown external device not belonging to the owner.
function verify_signatures {
    signature_files_missing=false
    # Checking if the signature file exists in the system.
    if [ ! -s "${SYS_SIGN_LOC}" ]; then
        log -e "System Signature file is missing"
        signature_files_missing=true
    else 
        log -d "System Signature file located successfully"
    fi

    # Checking if the signature file exist in the external device.
    if [ ! -s "${EXT_DEV_SIGN_LOC}" ]; then
        log -e "External Device Signature file is missing"
        signature_files_missing=true
    else 
        log -d "External Device Signature file located successfully"
    fi

    # If one or more signature files are missing, ask the user if they want to continue with backup creation anyway.
    # Not recommended as the credibility of the external device cannot be established.
    if [ "$signature_files_missing" = true ]; then
        echo "One or more signature files are missing."
        read -p "Do you want to continue with the backup creation anyway?(Not Recommended) [N/y]: " response

        if [[ "$response" =~ ^[Yy](es)?$ ]]; then
            log -w "Proceeding to create backup without verifying external device signature."
        else
            log -i "Backup process cancelled"
            log -b
            exit 1
        fi
    else
        # Checking if the signature files match.
        log -d "Verifying signatures..."
        if cmp -s ${SYS_SIGN_LOC} ${EXT_DEV_SIGN_LOC}; then
            log -i "Signature files verified: Backup authorized"
        else
            log -f "Backup failed: External Device Signature does not match System Signature"
            log -b
            exit 1
        fi
    fi
}

# Gets the number of backups currently stored.
function get_stored_backup_count {
    # ls lists all the contents in the BACKUP_LOC directory.
    # grep picks out all the files ending with ".tar.gz" from the list returned by ls.
    # wc -l counts the number of lines returned by grep (since each line consists the name of one file: number files = number lines).
    echo $(ls ${BACKUP_LOC} | grep .tar.gz$ | wc -l)
}

# Deletes the oldest backup.
function delete_oldest_backup {
    # ls returns the files in the BACKUP_LOC directory.
    # -t option sorts the files by last modified time (latest at the top).
    # -r option reverses the list (so that oldest is at the top).
    # grep picks out just the backup files (which end in .tar.gz).
    # head -n 1 returns just the filename at the top of the list (i.e. the oldest backup file).
    OLDEST_BACKUP=$(ls -tr ${BACKUP_LOC} | grep .tar.gz$ | head -n 1)
    
    # Print information to terminal
    echo "Backup files limit exceeded. Deleting oldest backup:"

    # Deleting the backup file.
    rm "${BACKUP_LOC}${OLDEST_BACKUP}"

    log -i "Deleted old backup file ${OLDEST_BACKUP}"
}

# Creates the backup.
function create_backup {
    log -i "Backup started"

    # Loop removes oldest backups to make room for current backup.
    # -ge is the 'greater than or equal to' operator.
    while [ "$(get_stored_backup_count)" -ge $BACKUP_LIMIT ]
    do
        delete_oldest_backup
    done

    # Getting timestamp.
    BACKUP_TIMESTAMP=$(get_timestamp)
    
    # Filename for the backup is obtained by replacing the whitespaces in the BACKUP_TIMESTAMP with underscores.
    BACKUP_FILENAME="${FILENAME_PREFIX}${BACKUP_TIMESTAMP//[ ]/_}"

    # The destination where the backup file will be stored.    
    BACKUP_DESTINATION="${BACKUP_LOC}${BACKUP_FILENAME}.tar.gz"

    # Variable to store the list of directory names as a single line string separated by spaces.
    BACKUP_DIRS=""
    # Loop to create the single line string of directory names from BACKUP_LIST.
    while read directory_path
    do
        BACKUP_DIRS+=" $directory_path"
    done < $BACKUP_LIST

    # Generating the exclude string to pass to the tar command.
    generate_exclude_string

    # Clear any previous logs in the TAR_LOG and TAR_ERROR_LOG files.
    truncate -s 0 $TAR_LOG
    truncate -s 0 $TAR_ERROR_LOG
    
    # Create the backup as a compressed tar archive
    # -c creates a tar archived file
    # -f indicates the archive should be a file
    # -v verbose - show all the files being archived and compressed
    # -z compress the tar file into a zip file (hence the file extension ".tar.gz", "gz" stands for GNU Zipped Archive)
    # -p preserves the file permissions of the files (only required during extraction of tar files)
    
    # To log the tar verbose outputs to tar_verbose.log.
    if [ "$LOG_TAR_VERBOSE" = true ]; then
        # Verbose output (i.e. stdout) redirected to TAR_LOG. Error messages (i.e. stderr) redirected to TAR_ERROR_LOG. 
        sudo tar ${EXCLUDE_FILES} -cvpzf ${BACKUP_DESTINATION} ${BACKUP_DIRS} >> $TAR_LOG 2> $TAR_ERROR_LOG
    else
        # Error messages (i.e. stderr) redirected to TAR_ERROR_LOG. 
        sudo tar ${EXCLUDE_FILES} -cpzf ${BACKUP_DESTINATION} ${BACKUP_DIRS} 2> $TAR_ERROR_LOG
    fi

    # Check if the tar_error log is not empty. If not empty: print the error messages to the main log.
    while read error_log
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
    done < $TAR_ERROR_LOG

    # Check if the backup file has been created successfully.
    if [ -s ${BACKUP_DESTINATION} ]; then
        log -i "Backup created successfully"
        log -b
        exit 0
    else
        log -f "Backup failed unexpectedly"
        log -b
        exit 1
    fi
}

#--

# Checking if the log files exist.
if [ ! -f ${MAIN_LOG} ]; then
    log -e "Missing file: backups.log"

    # Create the missing log file.
    touch $MAIN_LOG

    log -d "Created backups.log file at ${MAIN_LOG}"
fi

# Checking if the backup_list.conf file exists.
# The backup_list.conf contains a list of directories and files that need to be included in the backup.
if [ ! -f ${BACKUP_LIST} ]; then
    log -f "Backup failed: /conf/backup_list.conf file is missing"
    log -b
    exit 1

else
    # Check if the backup list is empty.
    if [ ! -s ${BACKUP_LIST} ]; then
        log -f "Backup failed: backup list is empty."
        log -b
        exit 1
fi

# Checking the backup destination type. 0 is backup to local system harddrive. 1 is backup to external harddrive device.
# Backup to external device requires some additional checks: 
# 1) Check device is mounted. 
# 2) Verify device signature. 
if (( "$BACKUP_TYPE" == 1 )); then
    # Check if the external harddrive where the backups will be stored is mounted.
    check_external_device_mounted

    # Verify the signature files in the system and external device.
    verify_signatures

    BACKUP_LOC=${EXTERNAL_BACKUP_LOC}
fi

# Checks completion message.
log -b
log -d "All checks completed"

# TODO: lock Scribe supporting files

# TODO: Exclude Scribe working directory from backup.


# Finally, create the backup.
create_backup