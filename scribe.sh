#! /bin/bash

# Source the utils.sh script.
. utils.sh

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


# If the config folder does not exist, create it and the files inside.
if [[ ! -d $CONFIG_DIR ]]; then
    # Making the config directory.
    mkdir $CONFIG_DIR

    # Create the config files inside the config directory.
    touch $CONFIG_FILE $BACKUP_LIST $EXCLUDE_LIST
fi

# Creating an array of the files inside the config/ directory.
CONFIG_FILES_ARRAY=($CONFIG_FILE $BACKUP_LIST $EXCLUDE_LIST)
# Running a loop to create the config files if they do not exist.
for file in "${CONFIG_FILES_ARRAY[@]}"
do
    # If the config file does not exist, create it.
    if [[ ! -f $file ]]; then
        # Create the config file.
        touch $file
    fi
done


# If the config file is empty, set defaults.
if [[ ! -s $CONFIG_FILE ]]; then
    # Setting to defaults.
    reset_config_defaults

    # Writing to the config file.
    write_to_config_file
fi


# Source the config file.
. $CONFIG_FILE


# If the logs folder does not exist, create it and the files inside.
if [[ ! -d $LOG_DIR ]]; then
    # Making the logs directory.
    mkdir $LOG_DIR

    # Create the log files inside the logs directory.
    touch $MAIN_LOG $TAR_LOG $TAR_ERROR_LOG
fi

# Creating an array of the files inside the logs/ directory.
LOG_FILES_ARRAY=($MAIN_LOG $TAR_LOG $TAR_ERROR_LOG)
# Running a loop to create the log files if they do not exist.
for file in "${LOG_FILES_ARRAY[@]}"
do
    # If the log file does not exist, create it.
    if [[ ! -f $file ]]; then
        # Create the log file.
        touch $file
    fi
done




