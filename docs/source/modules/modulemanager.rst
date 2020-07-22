.. modulemanager:

The Module Manager
==================

.. contents::
	:local:
	:depth: 2


What is the Module Manager?
---------------------------

The module manager loads all modules and libraries 
for chaOS. It is not structured like the other modules, 
as there is no other code for loading modules.


Key Elements
------------


The `module` and `library` lexicons
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

chaOS stores all public functions and variables exposed 
by modules and libraries within these two lexicons. Each 
module and library has its own lexicon of its functions 
and variables stored with the key being the name of the 
module or library. You can use these variables to call 
or reference other functions, such as the function to 
raise an error:

::

	module:utilities:raiseError("Ship should not be underground!").

These references can also be used to create an executable 
type object through ``module:utilities:reference(path)`` 
where path is a string such as ``"module:utilities:raiseError"`` 
and the object is returned. Paths to modules are 
case-insensitive.


The loadingmodule Function
~~~~~~~~~~~~~~~~~~~~~~~~~~

When moduleManager runs each module and library, it expects 
that each will produce a global function named `loadingmodule` 
and `loadinglibrary` respectively when run. These functions 
must take no parameters and return a lexicon of function name 
and delegate pairs. The `onload` function name is the only 
special name.


The onload Function
~~~~~~~~~~~~~~~~~~~

As each module and library is loaded, modulemanager checks the 
lexicon output for the function `onload`. All of these functions 
are saved into a queue and executed once all modules and libraries 
have been loaded. This is useful for anything that must be run at 
startup that relies on other modules, such as scheduling processes.