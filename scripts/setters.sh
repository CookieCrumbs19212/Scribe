# Setters for Scribe backup script.

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
    # Check that the input points is a valid directory path.
    if [[ ! -d "$1" ]]; then
        echo "$1 directory does not exist."

        # Create the directory and ny intermediate directories.
        read -r -p "Would you like to create the directory $1? [N/y]: " response
        if [[ "$response" =~ ^[Yy](es)?$ ]]; then
            # Creating the directory.
            mkdir -p "$1" && log -i "Created directory $1"

            # Setting BACKUP_LOC to the newly created directory.
            BACKUP_LOC=$LOCAL_BACKUP_LOC && log -i "Backup location set successfully ($1)" 
        else
            log -w "Backup location not set"
            log -b
            exit 1
        fi
    else
        # If the input is valid, assign it to BACKUP_LOC.
        BACKUP_LOC=$1 && log -i "Backup location set successfully ($1)"
    fi

    # Write changes to config file.
    write_to_config_file
}


function remove_path_from_list {
    # Check if the path to remove ($1) is in the list ($2), if it exists in the list, remove it.

    path_to_remove=$1
    list=$2

    # Putting a newline character to ensure that the last line is read.
    # If there isn't a newline after the last line, the last line is not read into the array.
    printf "\n" >> "$list"

    # Flag to indicate if the inputted path exists in the list.
    flag=false

    # Running a loop through the list and storing each line in the array.
    while read -r path
    do
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

    # Clear any blank lines.
    sed -i '/^$/d' "$list"

    # Delete local variables.
    unset array
    unset flag
}


function remove_path_from_backup_list {
    remove_path_from_list "$1" "$BACKUP_LIST"
}


function remove_path_from_exclude_list {
    remove_path_from_list "$1" "$EXCLUDE_LIST"
}


function add_to_backup_list {
    # Check if file path is valid path to directory or file.
    if [[ ! -d "$1" ]] && [[ ! -f "$1" ]]; then
        echo "invalid filepath $1"
    else
        # Add path to backup list.
        printf "%s\n" "$1" >> "$BACKUP_LIST" && echo "Added $1 to backup list."
    fi

    # Check if path is in exclude list, if true, remove it from exclude list.
    remove_path_from_exclude_list "$1"    
}


function add_to_exclude_list {
    # Check if file path is valid path to directory or file.
    if [[ ! -d "$1" ]] && [[ ! -f "$1" ]]; then
        echo "invalid filepath $1"
    else
        # Add path to exclude list.
        printf "%s\n" "$1" >> "$EXCLUDE_LIST" && echo "Added $1 to exclude list."
    fi

    # Check if path is in backup list, if true, remove it from backup list.
    remove_path_from_backup_list "$1"
}


function print_backup_list {
    # Putting a newline character to ensure that the last line is read.
    # If there isn't a newline after the last line, the last line is not read into the array.
    printf "\n" >> "$BACKUP_LIST"
    # Running a loop through the list and storing each line in the array.
    while read -r path
    do
        # Print path to terminal.
        echo "$path"
        
    done < "$BACKUP_LIST"
}


function print_exclude_list {
    # Putting a newline character to ensure that the last line is read.
    # If there isn't a newline after the last line, the last line is not read into the array.
    printf "\n" >> "$EXCLUDE_LIST"
    # Running a loop through the list and storing each line in the array.
    while read -r path
    do
        # Print path to terminal.
        echo "$path"
        
    done < "$EXCLUDE_LIST"
}