.. _moduletutorial:

Building a Telnet Module
========================

To demonstrate how modules work and 
interact with other modules, we will 
make a small module that can control 
Telnet in kOS.

Getting Started: Module Structure
---------------------------------

It is always a good idea to start out 
with some comments about what your code is 
and what it does.

::

	// telnet.ks
	// telnet configuration module

Then we want to create our central function, 
and make a reference to it by loadingmodule. 

::

	global function telnet {
		
	}
	
	global loadingmodule is utilities@.

This sets up the function that will contain our 
module, and exposes it to modulemanager through 
the `loadingmodule` function.


Building Public Functions
-------------------------

To start, we need a function to toggle telnet 
on or off depending on input. This function 
will go in the `telnet` function.

::

	function toggleTelnet {
		parameter toggleOnOff.
		
		set config:telnet to toggleOnOff.
	}

Maybe we also want to change the port that telnet 
is on. We can build a function for that, too.

::

	function changePort {
		parameter newPort.
		
		set config:tport to newPort.
	}

Both of these funtions must be added to the 
`telnet` function. We now have a way of 
changing the telnet settings, but there is 
no way for modules and programs to access 
these functions! To do this, we must 
expose these functions to chaOS.


Exposing Public Functions
-------------------------

All functions inside modules and libraries must 
be returned to `modulemanager` through a lexicon 
of functions. We will also make an internal `self` 
lexicon for object-oriented programmers that prefer 
using self as a reference to internal functions and variables.
Again, this will go at the end of the `telnet` function.

::

	local self is lexicon(
		"toggleTelnet", toggleTelnet@,
		"changePort", changePort@
	).

Finally, all we need to do now is return the lexicon 
to modulemanager.

``return self.``


Accessing Our Functions
-----------------------

Once chaOS has loaded, our lexicon of functions will be 
loaded into ``module:telnet``. If you do not save the 
module as telnet.ks or compile it to telnet.ksm, 
the label of the module in the module lexicon will 
be the file name. If you saved the module as 
`mytelnetmodule.ks`, you can access the functions lexicon 
in ``module:mytelnetmodule``. Also note that the module 
must be saved in the `chaos/modules/` folder.

Our two functions are accessible as:

::

	module:telnet:toggleTelnet()
	module:telnet:changePort()


Final Code
----------

``chaos/modules/telnet.ks``

::

	// telnet.ks
	// telnet configuration module
	
	global function telnet {
		
		function toggleTelnet {
			parameter toggleOnOff.
			
			set config:telnet to toggleOnOff.
		}
		
		function changePort {
			parameter newPort.
			
			set config:tport to newPort.
		}
		
		local self is lexicon(
			"toggleTelnet", toggleTelnet@,
			"changePort", changePort@
		).
		
		return self.
		
	}
	
	global loadingmodule is utilities@.