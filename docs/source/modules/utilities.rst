.. _utilities:

The Utilities Module
====================

.. contents::
	:local:
	:depth: 2


What is Utilities?
------------------

The utilities module adds many small features 
to the core of chaOS, including new types of 
references and logging functions.


Public Utilities Functions
--------------------------

textToRef
~~~~~~~~~

Parameters:

stringFunction: A string copy of the function to be run

Returns:

functionDelegate: A delegate to the compiled function


TextToRef takes a string and converts it to a function. This is 
useful for functions such as conditionals for listeners, where a 
path reference would clutter modules with many small functions, 
but delegates cannot be preserved on reload.

This function creates a temporary file with the string, runs the 
function, and then deletes it. The delegate remains active even 
after file deletion.


raiseWarning and throwWarning
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Parameters:

warningText: a string of the warning text


Takes a warning string and uses ``module:ui:record("Warning @ ", warningText)`` 
to create a log that looks similar to:

``Warning @ 1:55:10 - Ship is traveling too fast!``

raiseWarning and throwWarning are aliases of each other.


raiseError and throwError
~~~~~~~~~~~~~~~~~~~~~~~~~

Parameters:

errorText: a string of the error text


Takes an error string and uses ``module:ui:record("Error @ ", errorText)`` 
to create a log that looks similar to:

``Error @ 1:55:10 - Ship should not be underground!``

raiseError and throwError are aliases of each other.


delegate
~~~~~~~~

Parameters:

delegate - a delegate to the function to be referenced


Returns:

execObject - an executable object of type delegate in the following list:

- 'delegate': delegate@ - a delegate to the referenced function
- 'type': 'delegate' - the string type of the executable object


The delegate utility creates a chaOS executable object from a delegate. 
This can be passed into process spawning functions.


reference
~~~~~~~~~

Parameters:

referencePath - a path to the function in its module or library

	ex. 'module:utilities:throwWarning' with state ('This is a warning')


Returns:

execObject - an executable object of type reference path in the following list:

- 'delegate': delegate@ - a delegate to the referenced function
- 'type': 'reference' - the string type of the executable object
- 'source': referencePath - the string path to the function


The reference utility creates a chaOS executable object from a reference path. 
This can be passed into process spawning functions. Note that this reference path 
is not a kOS delegate! It is a path to a function in a module or library.


stringFunction
~~~~~~~~~~~~~~

Parameters:

stringFunction - a string copy of the function to reference


Returns:

execObject - an executable object of type stringfunction in the following list:

- 'delegate': delegate@ - a delegate to the referenced function
- 'type': 'stringFunction' - the string type of the executable object
- 'source': stringFunction - the string copy of the function


The stringFunction utility creates a chaOS executable object from a string, 
creating a function along the way. 
This can be passed into process spawning functions.


smartType
~~~~~~~~~

Parameters:

Unknown - A valid executable with type unknown

Returns:

execObject - A typed executable, or the unknown if it is not valid.


This function automatically selects an executable type from stringFunction, 
reference, and delegate and creates an executable object, or returns the input 
if it is already an executable or cannot be typed. This reduces the extra code 
and understanding needed to manually type and create executable objects, though 
manually creating executable objects is still valid. This is used when spawning 
processes in processmanager and setting controls in the control module.