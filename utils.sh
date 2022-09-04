# Utilities file for Scribe backup script.

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