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