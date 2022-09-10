# Scribe
Scribe is a backup script written in Bash. It is intended for backing up personal files on a machine.

**Note:** Although this script was developed and tested on Linux systems, the use of any Linux specific commands or functions has been strictly avoided in the script. Which means, _in theory_, Scribe should work just as well on machines running macOS.  

Scribe will **NOT** work on Windows machines.  
___

## Getting Scribe
### Step 1: Download the Scribe Source Code 

Navigate to the Releases section and download the source code for the [Latest Release](https://github.com/CookieCrumbs19212/Scribe/releases/latest) of Scribe.   
Once you've downloaded the zip file containing the source code, unzip the file to extract its contents.

### Step 2: Grant Execute Permission to **scribe.sh**
In order to run a script on a machine, it needs to have execute permission.  
This can be granted by opening the Terminal in the directory containing the `scribe.sh` file and executing the following command:

```commandline
$ chmod u+x scribe.sh
```

This will grant execute permission for the script only to the owner of the file.  

### Step 3: Set up Scribe
Follow the step-by-step instructions in the [User Guide](./USER_GUIDE.md) to perform the [Initial Setup](./USER_GUIDE.md#initial-setup) for Scribe.  

### Step 4: Create an alias for Scribe _(optional)_

This step is optional but strongly recommended to improve your experience when using Scribe.  
Refer to [Creating an Alias](./USER_GUIDE.md#creating-an-alias) in the User Guide for instructions on how to create one.
___

## Notes
For detailed documentation on Scribe commands, refer to the [User Guide](./USER_GUIDE.md).  

Scribe is intended for backing up personal files. Although you can back up system files using Scribe, it is strongly advised that you use a program specially designed for that task like [Timeshift](https://github.com/linuxmint/timeshift).  
