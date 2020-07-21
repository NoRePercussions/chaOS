.. _aboutmodules:

chaOS Modules
=============

.. contents::
	:local:
	:depth: 2


What are modules?
-----------------

**chaOS** modules are extensions of the chaOS microkernel. 
They each contribute towards the system function. This contrasts 
with libraries, which may add useful function but do not extend 
**chaOS**'s internal operation (ie math functions vs a GUI).


Built-in modules
----------------

**chaOS** relies on the following modules to run:

- modulemanager.ks
- processmanager.ks
- utilities.ks
- ui.ks
- commandline.ks
- savestate.ks


Components of modules
---------------------

All modules must share the same structure. 
(modulemanager is exempt because it has the load logic)


Module loading functions
~~~~~~~~~~~~~~~~~~~~~~~~

Modules must declare the global function `loadingmodule()` 
when run. In the built-in modules, the module is set up 
in a function sharing the module name, and then the 
`loadingmodule` function is set to a reference. 

Ex. the end of `processmanager.ks` reads:

``global loadingmodule is processmanager@.``


Exposing module functions and variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The global function loadingmodule must return 
a lexicon when run. This lexicon must include 
all public function names matched with their reference. 
This lexicon can also include variables.
All functions and variables returned will be added 
to the global lexicon `module:{modulename}`.

Ex. `processmanager` returns the 
lexicon pair ``{"spawnProcess", spawnProcess@}``

and the `spawnProcess` function can be called with 
``module:processmanager:spawnProcess({parameters}).``


Private variables and functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Any variables and function declared local to the main 
module function and not returned in the lexicon will 
remain private to the module. They can be accessed 
by public and private functions inside the module, 
but cannot be accessed outside of the module.

The `processmanager` module has the following 
private variable that is used by the module:
``local updatecycle is 0.``


Module onload()
~~~~~~~~~~~~~~~

Each module may expose an optional function `onload` 
that will be run after every module has been loaded. 
This is ideal for if you have code that relies on 
another module or library, and for moving intensive 
early operations from the module loading phase 
to the start of operation. It is best practice to streamline 
the module load and put more intensive operations into 
onload, or better, their own process.

`processmanager` has an onload function that interfaces 
with the ui module and the central configuration::

	function onload {
		chaOSconfig:add("ups", 50).
		module:ui:addConfigWidget(configWidget@).
		module:processmanager:spawndaemon(module:utilities:reference("module:processmanager:garbageCollector"), 3, list(), 1/500).
	}