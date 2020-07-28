.. modules:

Modules and Libraries
=====================

.. contents::
	:local:
	:depth: 2
	
	
What are Modules?
-----------------

Modules and libraries are addons or 
extensions to chaOS. Instead of putting 
all addons into non-standardized, seperate 
systems, a module system offers a way to 
quickly and easily add extensions and code 
without technical knowledge. It is also 
useful when designing code that interfaces 
with the OS, or working with someone else's 
code.

Modules are similar in principle to linux modules, 
though they are not dynamically linked and only 
loaded at startup. There are also no internal 
module references, only symbol tables.

Libraries have the same structure as modules, 
with the main difference being that libraries 
do not extend the chaOS or kOS kernels.


Internal Modules
----------------

chaOS comes with 7 built-in modules and no libraries.

* ModuleManager - Handles loading all other modules
* ProcessManager - Handles all process-related ops
* SaveState - Saves and loads chaOS state
* UI - Controls user interface, including GUI
* CommandLine - Parses unix-style commands
* Utilities - Provides misc. utilities
* Control - Provides versatile and saveable ship controls


Adding modules and libraries
----------------------------

Modules and libraries can be added by dropping a compatible 
.ks or .ksm file into the respective folder in chaOS. You 
can also build your own code to add in. Check out the module 
tutorial and module documentation for a quickstart and structure. 
The built-in modules are good references.