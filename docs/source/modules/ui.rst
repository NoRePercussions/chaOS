.. ui:

The UI Module
=========================

.. contents::
	:local:
	:depth: 2


What is the UI module?
----------------------

The UI module handles all User Interface elements 
of chaOS, including the central Graphical User 
Interface (GUI). It is the second largest module 
after processmanager.

The UI module features:

- Debug and console logs
- The active and configuration guis
- Functions for logging
- Custom widgets
- The chaOS file editor
- Command-line interface terminal

See the CLI section for more information about commands 
and file editing.


Public UI variables
-------------------

fulldebug
~~~~~~~~~

Fulldebug is a list containing every debug and console log 
in order. Items can be added with the record and debug functions 
and will be displayed in the chaOS terminal when the debug setting 
is enabled.


nodebug
~~~~~~~

Nodebug is a list containing every console log in chronological order. 
It contains no debug data. Items can be added with the record function 
and will be always displayed in the chaOS terminal when visible.


gui
~~~

Gui is an object of type GUI of the currently displayed GUI. It contains 
the gui for the active, edit, and config menus. It can be used with widget 
indices to interface with elements on the current active gui.


Public UI Functions
-------------------


debug
~~~~~

Parameters:

- Prefix [optional]: A string to be added before the timestamp
- Log text: The data to be logged

The debug function adds a timestamped log with an optional prefix to 
the debug log. When the debug setting is enabled, all logged data will 
be displayed on the terminal.


record
~~~~~~

Parameters:

- Prefix [optional]: A string to be added before the timestamp
- Log text: The data to be logged

The record function adds a timestamped log with an optional prefix to 
the console log. All logged data will be displayed on the terminal.


makeActiveGUI
~~~~~~~~~~~~~

Clears the current GUI and draws the active chaOS GUI with the terminal. 
If the edit or config windows are open, no data will be saved. Generally, 
this function should not be called by modules except for on load and GUI 
interaction, but it may be useful in some scenarios such as bringing user 
attention to fatal errors.


updateActiveGUI
~~~~~~~~~~~~~~~

Updates the chaOS GUI's terminal. Run every 5 update ticks by the 
updateActiveGUI daemon.


addConfigWidget
~~~~~~~~~~~~~~~

Parameters:

widgetDelegate: A delegate for a function that takes a guilayout parameter 
and adds GUI elements

AddConfigWidget allows for other modules, libraries, and programs to add 
their own settings to the config GUI. The delegate passed in must take a 
guilayout parameter and add all GUI elements to that guilayout.


enterEditMode
~~~~~~~~~~~~~

Parameters:

filepath: The file to open in the editor

Opens the file in the chaOS GUI editor, hiding the terminal GUI. 
Called by the CLI module's `edit` command.


onload
~~~~~~

Spawns the updateActiveGUI daemon via module reference to be run once every 5 ticks.