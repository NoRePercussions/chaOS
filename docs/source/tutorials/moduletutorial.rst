.. _moduletutorial:

Building a Telnet Module
========================

To demonstrate how modules work and 
interact with other modules, we will 
make a small module that can control 
Telnet in kOS.

.. contents::
	:local:
	:depth: 2

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


Making a GUI
------------

This part may be confusing for new kOS coders or 
anyone who does not work with GUIs. In addition, 
there are some weird bugs that necessitate more 
code that is unclear. I will just provide a 
prebuilt function for now.

The notable part is that the function must take a 
parameter of the GUI body and add all elements to 
it.

::

	function makeTelnetConfig {
		parameter body.
		local container is body:addhbox().
		local telnetOn is container:addcheckbox("Telnet", config:telnet).
		set telnetOn:ontoggle to { parameter state. toggleTelnet(state). }.
		local telnetPort is container:addtextfield(config:tport:tostring).
		set nextdebouncetime to time:seconds + 0.2.
		set telnetPort:onconfirm to {
			parameter newtport.
			if newtport:length = 0 or time:seconds < nextdebouncetime return.
			set nextdebouncetime to time:seconds + 0.2.
			changePort(newtport:toscalar).
		}.

	}


Onload and Adding the GUI
-------------------------

The `onload` function will run when 
all modules and libraries have been 
loaded. We can use the UI module for 
adding our GUI.

::

	function onload {
		module:ui:addConfigWidget(makeTelnetConfig@).
	}

Exposing Public Functions
-------------------------

All functions inside modules and libraries must 
be returned to `modulemanager` through a lexicon 
of functions. This just needs the names and 
delegates to each function.

::

	return lexicon(
		"toggleTelnet", toggleTelnet@,
		"changePort", changePort@,
		"onload", onload@
	).


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

You can also see the GUI settings by going to 
the Config menu when chaOS is booted.

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

		function makeTelnetConfig {
			parameter body.
			local container is body:addhbox().
			local telnetOn is container:addcheckbox("Telnet", config:telnet).
			set telnetOn:ontoggle to { parameter state. toggleTelnet(state). }.
			local telnetPort is container:addtextfield(config:tport:tostring).
			set nextdebouncetime to time:seconds + 0.2.
			set telnetPort:onconfirm to {
				parameter newtport.
				if newtport:length = 0 or time:seconds < nextdebouncetime return.
				set nextdebouncetime to time:seconds + 0.2.
				changePort(newtport:toscalar).
			}.

		}

		function onload {
		module:ui:addConfigWidget(makeTelnetConfig@).
		}
	
		return lexicon(
			"toggleTelnet", toggleTelnet@,
			"changePort", changePort@,
			"onload", onload@
		).
		
	}

	global loadingmodule is telnet@.