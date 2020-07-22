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