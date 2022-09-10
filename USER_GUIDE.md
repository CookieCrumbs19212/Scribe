# Scribe User Guide

This guide will walk you through the initial setup for Scribe and provide details about all the commands.

Throughout this guide, it is assumed that the alias `scribe` has been set up for executing Scribe commands.  

Refer to [Creating an Alias](./USER_GUIDE.md#creating-an-alias) section for instructions on creating an alias for Scribe.  

___

## Initial Setup

Before you can begin creating backups on your system, you need to provide some information to Scribe so that it knows where to store the backup files and which files and directories need to be included in the backup.  
&nbsp;  

### Step 1: Setting Backup Location

To set the backup location, run the following command:  

```commandline
$ scribe set-loc <path-to-backup-location>
```

#### Usage:  
Setting the directory `/home/user/backups/` as the backup location:  

```commandline
$ scribe set-loc /home/user/backups/
```

If the directory path you entered does not exist, Scribe will prompt if you wish to create the directory.  
&nbsp;  

### Step 2: Add Files and Directories to Backup List

To indicate which files and directories must be included in the backup, their respective paths should be added to the Backup List.  

Command to add a path to the Backup List:  

```commandline
$ scribe add <path>
```

#### Usage:
```commandline
$ scribe add /home/user/Documents/
```
&nbsp;  

### Step 3: Create Backup
To create a backup, run the command:

```commandline
$ scribe backup
```
&nbsp;  
___

## Scribe Commands

| Command                    | Description                                           |
|----------------------------|-------------------------------------------------------|
| set-loc <path>             | Set the path to the Backup Location                   |
| set-limit <lim>            | Set the maximum number of backups that can be stored  |
| set-prefix <string>        | Set the backup filename prefix                        |
| add <path>                 | Add a path to the Backup List                         |
| remove <path>              | Remove a path from the Backup List                    |
| exclude <path>             | Add a path to the Exclude List                        |
| remove-from-exclude <path> | Remove a path from the Exclude List                   |
| backup                     | Create a backup                                       |
| backup-loc                 | Prints the Backup Location                            |
| backup-lim                 | Prints the Backup Limit                               |
| config                     | Prints the config settings                            |
| tar-verbose-on             | Turn on tar verbose output logging                    |
| tar-verbose-off            | Turn off tar verbose output logging                   |
| exclude-script             | Excludes the Scribe directory from backups            |
| include-script             | Includes the Scribe directory in backups              |
| ls-backup                  | List all the paths in the Backup List                 |
| ls-exclude                 | List all the paths in the Exclude List                |
| clr-backup                 | Clear all the paths in the Backup List                |
| clr-exclude                | Clear all the paths in the Exclude List               |
| clr-logs                   | Clear all the log files                               |
| reset                      | Reset the configurations to defaults and clear logs   |
___


### 1. Set Backup Location
The `set-loc` command is used to set the Backup Location.  

If the provided directory path does not exist, the user will be prompted and asked whether they want to create the directory path.  

```commandline
$ scribe set-loc /home/user/backups/
```
___

### 2. Set Backup Limit
The `set-limit` command is used to set the `BACKUP_LIMIT`, which is the maximum number of backups that can be stored.  

By default, the `BACKUP_LIMIT` is 3.

```commandline
$ scribe set-limit 5
```

During backup creation, Scribe checks how many backup files exist in the Backup Location.  
If the number of saved backup files is >= `BACKUP_LIMIT`, Scribe will delete the oldest backup.  
___

### 3. Set Filename Prefix
The filenames for the backup file have the format "`YYYY-MM-DD_HH:MM:SS.tar.gz`".  
If you want to add a specific prefix to the backup filename, you can set a the prefix using `set-prefix`.  

The default Filename Prefix is an empty string.  

```commandline
$ scribe set-prefix "important-files-backup"
```
___

### 4. Add path to Backup List
Add a directory path or file path to the Backup List to include them in the backups.  

If the path you are adding to the Backup List already exists in the Exclude List, the path will be removed from the Exclude List then added to the Backup List.   

```commandline
$ scribe add /home/user/Documents/ID-document.pdf
```
___

### 5. Remove path from Backup List
Remove paths you no longer want to include in backups from the Backup List.

```commandline
$ scribe remove /home/user/Pictures/
```
___

### 6. Exclude File or Directory from Backups
Suppose you want to include your `Documents` directory in the backups but you do not want to the `Documents/junk-files/` directory to be included in the backup.  
You can add the absolute path of the `junk-files` directory to the Exclude List, this will exclude the directory from the backup.  

```commandline
$ scribe exclude /home/user/Documents/junk-files/
```
___

### 7. Remove a path from Exclude List
If you no longer want to exclude a file or directory from backups, remove it from the Exclude List.

```commandline
$ scribe remove-from-exclude /home/user/Documents/junk-files/
```
___

### 8. Create a Backup
To create a backup, run the following command:

```commandline
$ scribe backup
```
___

### 9. Toggling tar Verbose Logging
The tar verbose option prints out each file name as it is archived.  
The output of the tar verbose will be stored in `tar_verbose.log`.  

By default, tar verbose logging is off.  

To turn on tar verbose logging:
```commandline
$ scribe tar-verbose-on
```

To turn off tar verbose logging:
```commandline
$ scribe tar-verbose-off
```
___

### 10. Include/Exclude Scribe Files
The Scribe files (config files, logs, scripts) are excluded from the backup by default.  

To include the Scribe files in the backups (not recommended):
```commandline
$ scribe include-script-files
```

To exclude the Scribe files from backups:
```commandline
$ scribe exclude-script-files
```
___

### 11. Viewing Configurations
To print all the configuration settings:
```commandline
$ scribe config
```

Print the Backup Location `BACKUP_LOC`:
```commandline
$ scribe backup-loc
```

Print the Backup Limit `BACKUP_LIMIT`:
```commandline
$ scribe backup-lim
```
___

### 12. Viewing Lists
Print contents of Backup List:
```commandline
$ scribe ls-backup
```

Print contents of Exclude List:
```commandline
$ scribe ls-exclude
```
___

### 13. Clearing Files
Clear the Backup List:
```commandline
$ scribe clr-backup
```

Clear the Exclude List:
```commandline
$ scribe clr-exclude
```

Clear Log Files:
```commandline
$ scribe clr-logs
```
___

### 14. Reset Configurations
Reset all configurations to default values.
```commandline
$ scribe reset
```
___

## Creating an Alias
An alias is a kind of shorthand you can use in the terminal in place of a long command.  

For example:  
To create a backup, you will need to run the command:
```commandline
$ /path/to/scribe.sh backup
```

Creating an alias allows you to assign a shorter _alias_ to `/path/to/scribe.sh`.
&nbsp;  

### Creating an Alias in Linux: 
* **Step 1:** Open up the Terminal in the home directory.  

* **Step 2:** Enter `ls -a` and check if there is a `.bashrc` file listed.    

* **Step 3:** If the `.bashrc` file does not already exist, you should create one in the home directory by running `touch .bashrc` in the Terminal.   

* **Step 4:** Now run the command `nano .bashrc` to open up the file in the nano editor.  

* **Step 5:** On a fresh line at the end of the file, add the line:
  ```bash
  alias scribe='/path/to/scribe.sh'
  ```

  Make sure to replace `path/to/scribe.sh` with the path to wherever you stored the `scribe.sh` script on your system.  

* **Step 6:** Press <kbd>Ctrl</kbd> + <kbd>X</kbd> and then press <kbd>Y</kbd> to save the changes you made to the `.bashrc` file. Now close the Terminal.  

Open up a fresh terminal for the changes to take effect.  
&nbsp;  

### Creating an Alias in macOS:  
* **Step 1:** Open up the Terminal in the home directory. 

* **Step 2:** Enter `ls -a` and check if there is a `.zshrc` file.    

* **Step 3:** If the `.zshrc` file does not already exist, you should create one in the home directory by running `touch .zshrc` in the Terminal.     

* **Step 4:** Now run the command `nano .zshrc` to open up the file in the nano editor.  

* **Step 5:** On a fresh line at the end of the file, add the line:
  ```zsh
  alias scribe='/path/to/scribe.sh'
  ```

  Make sure to replace `path/to/scribe.sh` with the path to wherever you stored the `scribe.sh` script on your system.  

* **Step 6:** Press <kbd>Cmd</kbd> + <kbd>X</kbd> and then press <kbd>Y</kbd> to save the changes you made to the `.zshrc` file. Now close the Terminal.  

Open up a fresh terminal for the changes to take effect.  
&nbsp;  

You have successfully set up a short alias to run the `scribe.sh` script.  

Now, you can run your commands for Scribe like so:  
```commandline
$ scribe backup
```
___

## Notes
The backup location is excluded from backups by default.  
This is done because it is redundant and costly to include previous backups in your new backup.  

**WARNING:** **DO NOT** store other `.tar.gz` files in your backup location as they may accidentally be deleted. Scribe checks the number of `.tar.gz` files in the backup location to see if it is within the backup limit. If the number of `.tar.gz` files exceed the backup limit, the oldest `.tar.gz` file is deleted from the backup location.  