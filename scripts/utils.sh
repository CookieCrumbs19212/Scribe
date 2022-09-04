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


# Function to write to scribe.conf file.
function write_to_config_file {
    echo "# Scribe Config File

    ###
    # User-set variables:

    # Number of backup that can be stored at a time. If limit is exceeded, oldest backup is deleted.
    BACKUP_LIMIT=$BACKUP_LIMIT

    # Custom prefix to prepend to the backup filenames. e.g. your username.
    FILENAME_PREFIX=\"$FILENAME_PREFIX\"

    # Backup Type: 0 - local backup, 1 - back up to external device.
    BACKUP_TYPE=$BACKUP_TYPE

    # Name of the backup directory where the backup files will be stored.
    BACKUP_DIR=\"$BACKUP_DIR\"

    # Path to backup location inside external device.
    EXT_BACKUP_PATH=\"$EXT_BACKUP_PATH\"


    ###
    # Action control variable:

    # When true, logs the verbose outputs of the tar command.
    LOG_TAR_VERBOSE=$LOG_TAR_VERBOSE

    # Exclude the script files from the backup (recommended).
    EXCLUDE_SCRIPT_FILES=$EXCLUDE_SCRIPT_FILES


    ###
    # Log File Locations:

    # Main log file. Contains all the logs from the error log file as well.
    MAIN_LOG=\"logs/backups.log\"

    # Tar Operation log file. Contains the verbose output (from the tar command using the -v option).
    TAR_LOG=\"logs/tar_verbose.log\"

    # Tar Error log file. Contains the error logs from the tar command.
    TAR_ERROR_LOG=\"logs/tar_errors.log\"


    ###
    # Backup Locations:

    # Local destination where the backup file will be stored.
    LOCAL_BACKUP_LOC=\"$LOCAL_BACKUP_LOC\"

    # External device destination where the backup file will be stored.
    EXTERNAL_BACKUP_LOC=\"$EXTERNAL_BACKUP_LOC\"

    # File containing list of directories to be backed up.
    BACKUP_LIST=\"config/backup_list.conf\"

    # File containing list of directories to be excluded from the backup.
    EXCLUDE_LIST=\"config/exclude_list.conf\"


    ###
    # Security File Locations: 
    # These files will be used to verify external device backup location.
    # Backups will only be created if the signature file inside the destination directory 
    # matches the signature file in the script's working directory.

    # Location of the system signature file (the signature file stored locally in the system).
    SYS_SIGN_LOC=\"config/sys_signature.hash\"

    # Location of the external device's signature file (the signature file in the external harddrive backup location). 
    EXT_DEV_SIGN_LOC=\"\${EXTERNAL_BACKUP_LOC}/ext_dev_signature.hash\"
    " >> $CONFIG_LOC
}


# Function to reset configurations to default.
function reset_config_defaults {
    # Number of backup that can be stored at a time. If limit is exceeded, oldest backup is deleted.
    BACKUP_LIMIT=3

    # Custom prefix to prepend to the backup filenames. e.g. your username.
    FILENAME_PREFIX=""

    # Backup Type: 0 - local backup, 1 - back up to external device.
    BACKUP_TYPE=0

    # Name of the backup directory where the backup files will be stored.
    BACKUP_DIR=""

    # When true, logs the verbose outputs of the tar command.
    LOG_TAR_VERBOSE=false

    # Exclude the script files from the backup (recommended).
    EXCLUDE_SCRIPT_FILES=true

    # Main log file. Contains all the logs from the error log file as well.
    MAIN_LOG="logs/backups.log"

    # Tar Operation log file. Contains the verbose output (from the tar command using the -v option).
    TAR_LOG="logs/tar_verbose.log"

    # Tar Error log file. Contains the error logs from the tar command.
    TAR_ERROR_LOG="logs/tar_errors.log"

    # Local destination where the backup file will be stored.
    LOCAL_BACKUP_LOC=""

    # External device destination where the backup file will be stored.
    EXTERNAL_BACKUP_LOC=""

    # File containing list of directories to be backed up.
    BACKUP_LIST="config/backup_list.conf"

    # File containing list of directories to be excluded from the backup.
    EXCLUDE_LIST="config/exclude_list.conf"

    # Location of the system signature file (the signature file stored locally in the system).
    SYS_SIGN_LOC="config/sys_signature.hash"

    # Location of the external device's signature file (the signature file in the external harddrive backup location). 
    EXT_DEV_SIGN_LOC=""


    # Lastly, write the changes to the config file.
    write_to_config_file
}


# Function to get the parent directory of the current script.
function get_parent_dir {
    echo "$( dirname " $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) " ) "
}


# Returns current timestamp in format "YYYY-MM-DD UTC<utc-offset> HH:MM:SS".
function get_timestamp {
    echo $(date "+%Y-%m-%d UTC%z %T")
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
