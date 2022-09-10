# Setters for Scribe backup script.


function validate_path {
    local path="$1"
    # Remove any trailing "/" in the path.
    while [[ "${path: -1}" == "/" ]]; do
        # Removing the last character of the path.
        path="${path:0:-1}"
    done
    
    # Return the path.
    echo "$path"
}

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

    # Write changes to config file.
    write_to_config_file
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

    # Write changes to config file.
    write_to_config_file
}


# Setter for the backup location.
function set_backup_location {
    local path
    # Adding a trailing "/" if it is missing.
    path="$(validate_path "$1")"

    # Check that the input points is a valid directory path.
    if [[ ! -d "$path" ]]; then
        echo "$path is not a directory."

        # Create the directory and any intermediate directories.
        read -r -p "Would you like to create the directory $path? [N/y]: " response
        if [[ "$response" =~ ^[Yy](es)?$ ]]; then
            # Creating the directory.
            mkdir -p "$path" && log -i "Created directory $path"

            # Setting BACKUP_LOC to the newly created directory.
            BACKUP_LOC=$path && log -i "Backup location set successfully ($path)" 
        else
            log -w "Backup location not set"
            log -b
            exit 1
        fi
    else
        # If the input is valid, assign it to BACKUP_LOC.
        BACKUP_LOC=$path && log -i "Backup location set successfully ($path)"
    fi

    # Write changes to config file.
    write_to_config_file
}


function remove_path_from_list {
    # Check if the path to remove ($1) is in the list ($2), if it exists in the list, remove it.
    local path_to_remove=$1
    local list=$2

    # Flag to indicate if the inputted path exists in the list.
    local flag=false
    local array

    # Running a loop through the list and storing each line in the array.
    local DONE=false
    until $DONE; do
        read -r path || DONE=true

        # Only store a path in array if it doesn't match the input path and is not empty.
        if [[ "$path_to_remove" == "$path" ]]; then
            flag=true
        elif [[ ! "$path" == "" ]]; then
            array+=("$path")
        fi
    done < "$list"

    # If the inputted path exists in the list, print it.
    if [[ "$flag" = true ]]; then
        # Clear the contents of the list so that we can write over it.
        truncate -s 0 "$list"

        # Run a loop through the array elements and print them to the list.
        for path in "${array[@]}"
        do
            printf "%s\n" "$path" >> "$list"
        done

        # Confirmation message.
        echo "Removed $path_to_remove from $list."
    fi
}


function remove_path_from_backup_list {
    remove_path_from_list "$1" "$BACKUP_LIST"
}


function remove_path_from_exclude_list {
    remove_path_from_list "$1" "$EXCLUDE_LIST"
}


function add_to_backup_list {
    local path
    # Adding a trailing "/" if it is missing.
    path="$(validate_path "$1")"

    # Check if file path is valid path to directory or file.
    if [[ ! -d "$path" ]] && [[ ! -f "$path" ]]; then
        echo "invalid filepath $1"
    else
        # Add path to backup list.
        printf "%s\n" "$path" >> "$BACKUP_LIST" && echo "Added $path to backup list."
    fi

    # Check if path is in exclude list, if true, remove it from exclude list.
    remove_path_from_exclude_list "$path"    
}


function add_to_exclude_list {
    local path
    # Adding a trailing "/" if it is missing.
    path="$(validate_path "$1")"
    
    # Check if file path is valid path to directory or file.
    if [[ ! -d "$path" ]] && [[ ! -f "$path" ]]; then
        echo "invalid filepath $1"
    else
        # Add path to exclude list.
        printf "%s\n" "$path" >> "$EXCLUDE_LIST" && echo "Added $path to exclude list."
    fi

    # Check if path is in backup list, if true, remove it from backup list.
    remove_path_from_backup_list "$path"
}


function print_backup_list {
    # Running a loop through the list and printing each line.
    local DONE=false
    until $DONE; do
        read -r path || DONE=true

        # Print path to terminal.
        echo "$path"

    done < "$BACKUP_LIST"
}


function print_exclude_list {
    # Running a loop through the list and printing each line.
    local DONE=false
    until $DONE; do
        read -r path || DONE=true

        # Print path to terminal.
        echo "$path"

    done < "$EXCLUDE_LIST"
}