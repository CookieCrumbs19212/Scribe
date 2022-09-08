# Utilities file for Scribe backup script.


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
            echo "$(get_timestamp) : DEBUG : $2" >> "$MAIN_LOG"
        ;;
        
        --info | -i)
            echo "$(get_timestamp) : INFO  : $2" >> "$MAIN_LOG"

            # -i messages must also be printed to the terminal output.
            echo "$2"
        ;;
        
        --warning | -w)
            echo "$(get_timestamp) : WARN  : $2" >> "$MAIN_LOG"
        ;;
        
        --error | -e)
            echo "$(get_timestamp) : ERROR : $2" >> "$MAIN_LOG"
        ;;
        
        --fatal | -f)
            echo "$(get_timestamp) : FATAL : $2" >> "$MAIN_LOG"

            # -f messages must also be printed to the terminal output.
            echo "$2"
        ;;
        
        --break | -b)
            echo "--" >> "$MAIN_LOG"
        ;;
    
        # wildcard, i.e. default case.
        *)
            echo "Invalid arguments."
        ;;
    esac
}


# Function to write to scribe.conf file.
function write_to_config_file {
    # The template for the config file.
    local config_template="# Scribe Config File

    ###
    # User-set variables:

    # Number of backup that can be stored at a time. If limit is exceeded, oldest backup is deleted.
    BACKUP_LIMIT=$BACKUP_LIMIT

    # Custom prefix to prepend to the backup filenames. e.g. your username.
    FILENAME_PREFIX=\"$FILENAME_PREFIX\"


    ###
    # Action control variable:

    # When true, logs the verbose outputs of the tar command.
    LOG_TAR_VERBOSE=$LOG_TAR_VERBOSE

    # Exclude the script files from the backup (recommended).
    EXCLUDE_SCRIPT_FILES=$EXCLUDE_SCRIPT_FILES


    ###
    # Storage Location for Backups:

    # Destination where the backup file will be saved.
    BACKUP_LOC=\"$BACKUP_LOC\"
    "

    echo "$config_template" > "$CONFIG_FILE"
}


# Function to reset configurations to default.
function reset_config_defaults {
    # Number of backup that can be stored at a time. If limit is exceeded, oldest backup is deleted.
    BACKUP_LIMIT=3

    # Custom prefix to prepend to the backup filenames. e.g. your username.
    FILENAME_PREFIX=""

    # When true, logs the verbose outputs of the tar command.
    LOG_TAR_VERBOSE=false

    # Exclude the script files from the backup (recommended).
    EXCLUDE_SCRIPT_FILES=true

    # Local destination where the backup file will be stored.
    BACKUP_LOC=""


    # Lastly, write the changes to the config file.
    write_to_config_file
}


# Function to get the parent directory of the current script.
function get_parent_dir {
    echo "$( dirname " $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) " ) "
}


# Returns current timestamp in format "YYYY-MM-DD HH:MM:SS".
function get_timestamp {
    echo "$(date "+%Y-%m-%d %T")"
}


# Checks if the external harddrive where the backups are to be stored is mounted.
function check_external_device_mounted {
    if [[ -d ${BACKUP_LOC} ]]; then
        log -d "External Backup Device found."
    else 
        log -f "Backup failed: External Backup Device is either not connected or not mounted"
        log -b
        exit 1
    fi
}


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
    if [[ ! -s "${EXT_DEV_SIGN_LOC}" ]]; then
        log -e "External Device Signature file is missing"
        signature_files_missing=true
    else 
        log -d "External Device Signature file located successfully"
    fi

    # If one or more signature files are missing, ask the user if they want to continue with backup creation anyway.
    # Not recommended as the credibility of the external device cannot be established.
    if [[ "$signature_files_missing" = true ]]; then
        echo "One or more signature files are missing."
        read -r -p "Do you want to continue with the backup creation anyway?(Not Recommended) [N/y]: " response

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
        if cmp -s "${SYS_SIGN_LOC}" "${EXT_DEV_SIGN_LOC}"; then
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
    # the "-c" counts the number of lines returned by grep (since each line consists the name of one file: number files = number lines).
    echo "$(ls "${BACKUP_LOC}" | grep -c .tar.gz$ )"
}


# Deletes the oldest backup.
function delete_oldest_backup {
    # ls returns the files in the BACKUP_LOC directory.
    # -t option sorts the files by last modified time (latest at the top).
    # -r option reverses the list (so that oldest is at the top).
    # grep picks out just the backup files (which end in .tar.gz).
    # head -n 1 returns just the filename at the top of the list (i.e. the oldest backup file).
    OLDEST_BACKUP=$(ls -tr "${BACKUP_LOC}" | grep .tar.gz$ | head -n 1)
    
    # Print information to terminal
    echo "Backup files limit exceeded. Deleting oldest backup:"

    # Deleting the backup file.
    rm "${BACKUP_LOC}${OLDEST_BACKUP}"

    log -i "Deleted old backup file ${OLDEST_BACKUP}"
}

