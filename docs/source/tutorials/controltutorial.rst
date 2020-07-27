.. _controltutorial:

Building a Launch Library
=========================

To demonstrate how to use the Control 
module, processes, and the commandline, 
we will make a script to launch a rocket!

.. contents::
	:local:
	:depth: 2

Getting Started: Library Structure
----------------------------------

It is always a good idea to start out 
with some comments about what your code is 
and what it does.

::

	// Launch Library
	// libraries/launch.ks

Then we want to create our central function, 
and make a reference to it by loadingmodule. 

::

	function launchlib {
		
	}
	
	global loadingmodule is launchlib@.

This sets up the function that will contain our 
module, and exposes it to modulemanager through 
the `loadingmodule` function.


Building Library Contents
-------------------------

We need code to handle the 3 main 
parts of launch:

1. Takeoff
2. Gravity Turn
3. Circularization

We also need to consider staging spent 
stages.


The Takeoff
-----------

Let's start with a function `launchnow` that 
begins the launch sequence.

::

	function launchnow {
	
	}

The first thing we need to do it set steering 
and throttle. We can use the control module to 
set these values, because it will be restart-tolerant.

::

	module:control:setSteering(up:vector).
	module:control:setThrottle(1).

We can also add a message to let the user know we are launching.

::

	module:ui:record("Going up!").


Now we must create a listener with `processmanager:spawnListener` 
to start the gravity turn when we have reached that point. 
Our condition to start the turn will be our speed passing 100 m/s. 

The `spawnListener` function requires a conditional and 
a function to run. There are 3 main ways to pass in the 
values:

* A copy of a function in a string
* A path to a function in a string
* A delegate pointing to a function

We will use the first two.

Our conditional will be written out as:

::

	"return ship:verticalspeed > 100."

.. Note::

	Make sure your conditional returns a value!

Our gravity turn function will be called `gravityTurn` 
and is in the module `launch`, so we will use the path

::

	"module:launch:gravityTurn"

Our final listener will be:

::

	module:processmanager:spawnListener(
		"return ship:verticalspeed > 100.",
		"library:launch:gravityTurn").


We can also make a daemon that checks if we need to stage. 
We will use a daemon because listeners get despawned after 
being run.

We will check if our ship's thrust has dropped since last 
checked. To do this, we need to initialize a global variable 
to hold the last value:

::

	chaOSConfig:add("targetThrust", 10^20).

We can set a priority of 3, the max; an empty state because 
our daemon takes no parameters, and a frequency of 1/25 so 
it runs twice a second. Our final spawn command is:

::

	module:processmanager:spawnDaemon(
		"if ship:maxthrust < chaOSConfig:targetThrust { stage. "
			 + "set chaOSConfig:targetThrust to ship:maxthrust. print chaOSConfig:targetThrust. }.",
		3, list(), 1/25).


The complete `launchnow` function is as follows:

::

	function launchnow {
		module:control:setSteering(up:vector).
		module:control:setThrottle(1).
		module:ui:record("Going up!").
		module:processmanager:spawnListener(
			"return ship:verticalspeed > 100.",
			"library:launch:gravityTurn",
			3, list()).
		module:processmanager:spawnDaemon(
			"if ship:maxthrust < chaOSConfig:targetThrust { stage. "
				 + "set chaOSConfig:targetThrust to ship:maxthrust. }.",
			3, list(), 1/25).
	}



The Gravity Turn
----------------

Our next function, `gravityTurn`, will start 
turning the ship and then follow prograde.

Our initial turn will be 15° off vertical, set 
with the control module.

::

	module:control:setSteering(heading(90, 75)).


We can create a listener so that when the ship is 
pointing prograde, it swaps to following the 
prograde vector. To set the steering to prograde, 
we can just pass a string copy of a function to 
`setSteering`. It can also take delegates and paths. 
We can use single quotes for the string inside the 
double quotes, and chaOS will handle interpretation.

::

	module:processmanager:spawnListener(
		"return vang(heading(90,75):vector, ship:srfprograde:vector) < 1.",
		"module:control:setSteering('return ship:srfprograde:vector.').").


After the ship reaches 36 km, the navball mode changes 
to orbit mode, so we have to update our steering to use 
orbit prograde instead of surface prograde.

::

	module:processmanager:spawnListener(
		"return ship:altitude > 36_000.",
		"module:control:setSteering('return ship:prograde:vector.').").


To prevent our ship from going interstellar, it 
needs to stop burning when its apoapsis is high enough.
Our target will be 80 km, but you can set it to anything.

::

	module:processmanager:spawnListener(
		"return ship:apoapsis > 80_000.",
		"module:control:setThrottle(0).").


Finally, when the ship is almost at apoapsis, it 
must start the circlarization sequence. This also 
checks that the apoapsis is close to the target, 
so that a ship that is still taking off will not 
go into circularization mode.

::

	module:processmanager:spawnListener(
		"return eta:apoapsis <= 15 and ship:apoapsis > 70_000.",
		"library:launch:circularize").


Our complete gravity turn function is:

::

	function gravityTurn {
		module:control:setSteering(heading(90, 75)).
		module:processmanager:spawnListener(
			"return vang(heading(90,75):vector, ship:srfprograde:vector) < 1.",
			"module:control:setSteering('return ship:srfprograde:vector.').").
		module:processmanager:spawnListener(
			"return ship:altitude > 36_000.",
			"module:control:setSteering('return ship:prograde:vector.').").
		module:processmanager:spawnListener(
			"return ship:apoapsis > 80_000.",
			"module:control:setThrottle(0).").
		module:processmanager:spawnListener(
			"return eta:apoapsis <= 15 and ship:apoapsis > 70_000.",
			"library:launch:circularize").
	}



Circularizing
-------------

To circularize, we start the burn at full throttle 
parallel to Kerbin's surface (what will be prograde 
at apoapsis)

::

	module:control:setThrottle(1).
	module:control:setSteering(heading(90,0)).

When the periapsis is a bit lower than target height 
we stop the burn. 

::

	module:processmanager:spawnListener(
		"return ship:periapsis > 79_000.",
		"module:control:setThrottle(0).").

This particular method of doing a gravity 
turn and circularizing is not super accurate, 
especially the circularization, but it is much 
easier to implement and understand than other 
methods. It will also work fairly well on the 
majority of ships without a need to tune parameters, 
and the entire script, even when compiled for chaOS, 
only takes up 63 lines.

The complete circularization function:

::

	function circularize {
		module:control:setThrottle(1).
		module:control:setSteering(heading(90,0)).
		module:processmanager:spawnListener(
			"return ship:periapsis > 79_000.",
			"module:control:setThrottle(0).").
	}



Adding a Launch Command
-----------------------

We can use the `commandline` module's addCustomCommand 
function to add a command to launch. It will simply be 
`launch`, run the `launchnow` function, and take no arguments 
(or command parameters). It is also useful to add a 
description for users, which is known as a manual and can 
be retrieved with the `man {command}` command. A simple 
description will work well: "launch - Launches the rocket!"

Wrapping this in the `onload` function gets us:

::

	function onload {
		module:commandline:addCustomCommand("launch", launchnow@, 0,0, "launch - Launches the rocket!").
	}


Exposing Public Functions
-------------------------

We have four public functions to add to 
the function lexicon:

* launchnow
* gravityTurn
* circularize
* onload

We can compile these in a `self` lexicon 
and return it to `modulemanager`:

::

	local self is lexicon(
		"launchnow", launchnow@,
		"gravityTurn", gravityTurn@,
		"circularize", circularize@,
		"onload", onload@
	).



Setting up the Library
----------------------

Save the code as `launch.ks` (if you use 
a different name, you will have to change 
all of the reference paths to the new name) 
and drop it into the *libraries* folder in 
the main *chaos* directory. 

When you next boot chaOS from the chaosboot file, 
select *launch* as a library to use. It will be 
copied in and you can use the launch command to 
launch your rocket!



Final Code
----------

`/chaos/libraries/launch.ks`


::

	// Launch Library
	// launch.ks

	function launchlib {

	local stcontrol is up.

	chaOSConfig:add("targetThrust", 10^20).

	function launchnow {
		lock steering to stcontrol.
		module:control:setSteering(up:vector).
		module:control:setThrottle(1).
		module:ui:record("Going up!").
		module:processmanager:spawnListener(
			"return ship:verticalspeed > 100.",
			"library:launch:gravityTurn").
		module:processmanager:spawnDaemon(
			"if ship:maxthrust < chaOSConfig:targetThrust { stage. "
				 + "set chaOSConfig:targetThrust to ship:maxthrust. }.",
			3, list(), 1/25).
	}

	function gravityTurn {
		module:control:setSteering(heading(90, 75)).
		module:processmanager:spawnListener(
			"return vang(heading(90,75):vector, ship:srfprograde:vector) < 1.",
			"module:control:setSteering('return ship:srfprograde:vector.').").
		module:processmanager:spawnListener(
			"return ship:altitude > 36_000.",
			"module:control:setSteering('return ship:prograde:vector.').").
		module:processmanager:spawnListener(
			"return ship:apoapsis > 80_000.",
			"module:control:setThrottle(0).").
		module:processmanager:spawnListener(
			"return eta:apoapsis <= 15 and ship:apoapsis > 70_000.",
			"library:launch:circularize").
	}

	function circularize {
		module:control:setThrottle(1).
		module:control:setSteering(heading(90,0)).
		module:processmanager:spawnListener(
			"return ship:periapsis > 79_000.",
			"module:control:setThrottle(0).").
	}

	function onload {
		module:commandline:addCustomCommand("launch", launchnow@, 0,0, "launch - Launches the rocket!").
	}

	local self is lexicon(
		"launchnow", launchnow@,
		"gravityTurn", gravityTurn@,
		"circularize", circularize@,
		"onload", onload@
	).

	return self.
		
	}

	global loadinglibrary is launchlib@.