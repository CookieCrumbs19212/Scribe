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

An alias is a kind of shorthand you can use in the terminal in place of a long command.  

For example:  
To create a backup, you will need to run the command:
```commandline
$ /path/to/scribe.sh backup
```


It gets tedious to type out the above command everytime you want to run the script so let's create an alias to make this step a little easier.

___

## Creating an Alias

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

___

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

___

You have successfully set up a short alias to run the `scribe.sh` script.  

Now, you can run your commands for Scribe like so:  
```commandline
$ scribe backup
```

___

## Notes

For detailed documentation on Scribe commands, refer to the [User Guide](./USER_GUIDE.md).  

Scribe is intended for backing up personal files. Although you can back up system files using Scribe, it is strongly advised that you use a program specially designed for that task like [Timeshift](https://github.com/linuxmint/timeshift).