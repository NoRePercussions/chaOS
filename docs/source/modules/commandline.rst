.. commandline:

The CLI Module
=========================

.. contents::
	:local:
	:depth: 2


What is the CLI module?
-----------------------

The Command-Line Interface of chaOS is based on 
a mix of Unix and kOS commands. Commands are documented 
in the Commands section.


Public CLI Functions
--------------------


addCommandToQueue
~~~~~~~~~~~~~~~~~

Parameters:

commandToAdd: A string of the full command to be added to the queue

Adds the command passed in to the queue to be parsed. Called whenever 
a new command is entered into the UI terminal.


parseAllCommands
~~~~~~~~~~~~~~~~

Goes through every command waiting in the queue, parses, 
and acts on them. Called by the parseAllCommands daemon 
every 5 update ticks.

addCustomCommand
~~~~~~~~~~~~~~~~

Parameters:

- commandName: the name of the command that will be used in the terminal
- delegate: a delegate of the function to be executed on call
- minParams [optional] : the minimum number of parameters expected for the command. 0 by default.
- maxParams [optional] : the maximum number of parameters expected for the command. 0 by default.
- manual [optional] : a description of the command. An empty string by default.

Allows programs to add their own commands, similar to the UI's ``addConfigWidget()``. 
Custom commands must specify the bound for the number of arguments to be passed in if 
they are nonzero, and may add their own manual description.