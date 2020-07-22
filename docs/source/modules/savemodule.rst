.. savemodule:

The Save Module
===============

.. contents::
	:local:
	:depth: 2


What is the Save Module?
------------------------

The Save Module saves and loads the current state 
of chaOS, including all process data and configs, 
to a set of files on the core filesystem. The state 
is typically saved at the start of each update tick.


Limitations
-----------

The save module uses chaOS's `writejson` and `readjson` 
functions. These functions cannot serialize delegates, 
so they are stripped before saving. Loading data relies 
on path references to functions (such as ``module:ui:updateactivegui``) 
and string copies of functions (such as ``print "test".``), 
the latter of which are parsed by ``module:utilities:textToRef``.

Public Save Module Functions
----------------------------

saveCurrentState
~~~~~~~~~~~~~~~~

Saves the current state of chaOS, including the following:

- The process record -> savedata/processrecord.dat
- All process queues -> savedata/queues.dat
- Configuration data -> savedata/config.dat

Before saving, the processrecord data is stripped of delegates. 
These delegates will be reconstructed later when loaded.


loadSavedState
~~~~~~~~~~~~~~

Loads the saved state of chaOS.

All path references and string copies of functions are 
reconstructed into delegates. Any saved processes that 
do not have either of these will be discarded.