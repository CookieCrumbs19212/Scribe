#! /bin/bash

# shellcheck source=scripts/utils.sh
# shellcheck source=scripts/setters.sh
# shellcheck source=scripts/backup.sh
# shellcheck source=config/scribe.conf


# Paths to directories.
CONFIG_DIR="config"
LOG_DIR="logs"
SCRIPT_DIR="scripts"

# Critical file locations.
CONFIG_FILE="${CONFIG_DIR}/scribe.conf"
BACKUP_LIST="${CONFIG_DIR}/backup_list.conf"
EXCLUDE_LIST="${CONFIG_DIR}/exclude_list.conf"

# Log file locations.
MAIN_LOG="${LOG_DIR}/backups.log"
TAR_LOG="${LOG_DIR}/tar_verbose.log"
TAR_ERROR_LOG="${LOG_DIR}/tar_errors.log"

# Helper Scripts locations.
UTILS="${SCRIPT_DIR}/utils.sh"
SETTERS="${SCRIPT_DIR}/setters.sh"
BACKUP_FUNCS="${SCRIPT_DIR}/backup.sh"


# Source the utils.sh script.
. "$UTILS"


# If the logs folder does not exist, create it.
if [[ ! -d $LOG_DIR ]]; then
    # Making the logs directory.
    mkdir $LOG_DIR
fi

# Creating an array of the files inside the logs/ directory.
LOG_FILES_ARRAY=("$MAIN_LOG" "$TAR_LOG" "$TAR_ERROR_LOG")
# Running a loop to create the log files if they do not exist.
for file in "${LOG_FILES_ARRAY[@]}"
do
    # If the log file does not exist, create it.
    if [[ ! -f $file ]]; then
        # Create the log file.
        touch "$file"
    fi
done


# Start logging from this point.
log -b


# If the config folder does not exist, create it.
if [[ ! -d $CONFIG_DIR ]]; then
    log -e "config/ directory not found"

    # Making the config directory.
    mkdir $CONFIG_DIR && log -d "Created config/ directory"
fi

# Creating an array of the files inside the config/ directory.
CONFIG_FILES_ARRAY=("$CONFIG_FILE" "$BACKUP_LIST" "$EXCLUDE_LIST")
# Running a loop to create the config files if they do not exist.
for file in "${CONFIG_FILES_ARRAY[@]}"
do
    # If the config file does not exist, create it.
    if [[ ! -f $file ]]; then
        log -e "${file} file is missing"

        # Create the config file.
        touch "$file" && log -d "Created ${file}"
    fi
done

# If the config file is empty, set defaults.
if [[ ! -s $CONFIG_FILE ]]; then
    log -e "scribe.conf file is empty"

    # Setting to defaults.
    reset_config_defaults

    log -d "Reset configurations to default"

    # Writing to the config file.
    write_to_config_file
fi


# Source the config file.
. "$CONFIG_FILE"

# Source the setters.sh script.
. "$SETTERS"

# Source the backup.sh script.
. "$BACKUP_FUNCS"


# Analyzing command.
case "$1" in
    --set-limit)
        set_backup_limit "$2"
    ;;

    --set-prefix)
        set_filename_prefix "$2"
    ;;

    --tar-verbose-on)
        LOG_TAR_VERBOSE=true
    ;;

    --tar-verbose-off)
        LOG_TAR_VERBOSE=false
    ;;

    --exclude-script)
        EXCLUDE_SCRIPT_FILES=true
    ;;

    --include-script)
        EXCLUDE_SCRIPT_FILES=false
    ;;

    --set-backup-loc)
        set_backup_location "$2"
    ;;

    --reset-config | --reset)
        reset_config_defaults
    ;;

    backup)
        perform_pre_backup_checks
        create_backup
    ;;

    *)
        echo "Invalid command"
    ;;
esac