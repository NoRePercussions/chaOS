.. commands:

chaOS Commands
==============

.. contents::
	:local:
	:depth: 2


What are commands?
------------------

chaOS allows the user to use unix-style 
CLI commands in the chaOS GUI terminal 
(not the kOS terminal though). Most are 
file operations, but you can also tweak 
some chaOS settings and add custom commands.

Commands are not functions! They cannot be 
called in kOS code, and functions cannot be 
called from the command line.


Command Table
------------- 

.. list-table::
	:header-rows: 1
	
	* - Command
	  - Arguments {required} [optional]
	  - Description
	* - help
	  - 
	  - Shows a list of available commands
	* - man
	  - {command}
	  - Shows information about the command
	* - exit
	  - 
	  - Exits chaOS
	* - run
	  - {filepath}
	  - Runs the selected file
	* - edit
	  - {filepath}
	  - Opens the file in the chaOS editor
	* - ls
	  - [directorypath]
	  - List files in selected or current directory
	* - touch
	  - {filepath}
	  - Creates an empty file at the path
	* - whereami
	  - 
	  - Prints current directory path
	* - cd
	  - {directorypath}
	  - Changed directory to specified
	* - mkdir
	  - {directorypath}
	  - Creates a directory at the path
	* - rm
	  - {filepath}
	  - Removes the file at the path
	* - rmdir
	  - {directorypath}
	  - Removes the directory at the path
	* - cp
	  - {frompath} [topath]
	  - Copies a file or directory from the old path to the new or current path
	* - mv
	  - {frompath} [topath]
	  - Moves a file or directory from the old path to the new or current path