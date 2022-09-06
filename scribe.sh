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

    # Set the limit for maximum number of backups.
    --set-limit)
        set_backup_limit "$2"
    ;;

    # Set the filename prefix that will be prepended to the backup file's name.
    --set-prefix)
        set_filename_prefix "$2"
    ;;

    # Set the backup destination, i.e. the location where the backup files will be stored.
    --set-loc)
        set_backup_location "$2"
    ;;


    # Turn on tar verbose logging.
    --tar-verbose-on)
        LOG_TAR_VERBOSE=true
    ;;

    # Turn off tar verbose logging.
    --tar-verbose-off)
        LOG_TAR_VERBOSE=false
    ;;

    # Exclude the Scribe script files from the backup.
    --exclude-script)
        EXCLUDE_SCRIPT_FILES=true
    ;;

    # Include the Scribe script files in the backup.
    --include-script)
        EXCLUDE_SCRIPT_FILES=false
    ;;

    # Reset the configurations to default values.
    --reset-config | --reset)
        reset_config_defaults
    ;;


    # Add a path to the backup list.
    --add | --include)
        add_to_backup_list "$2"
    ;;

    # Remove a path from the backup list.
    --remove | --remove-backup)
        remove_path_from_backup_list "$2"
    ;;


    # Add a path to the exclude list.
    --exclude)
        add_to_exclude_list "$2"
    ;;

    # Remove a path from the exclude list.
    --remove-exclude)
        remove_path_from_exclude_list "$2"
    ;;


    # Show backup location.
    --backup-loc)
        if [[ "$BACKUP_LOC" == "" ]]; then
            echo "Backup location has not been set. Set Backup location using --set-loc <path>"
        else
            echo "$BACKUP_LOC"
        fi
    ;;

    # List the paths in the backup list.
    --show-backup-list)
        print_backup_list
    ;;

    # List the paths in the exclude list.
    --show-exclude-list)
        print_exclude_list
    ;;


    # Create a backup.
    backup)
        perform_pre_backup_checks
        create_backup
    ;;


    # Invalid commands.
    *)
        echo "Invalid command"
    ;;
esac