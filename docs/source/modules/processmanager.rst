.. _processmanager:

The ProcessManager Module
=========================

.. contents::
	:local:
	:depth: 2


What is processmanager?
-----------------------

The ProcessManager module handles every process 
that is run on chaOS. It is the largest module 
in chaOS, as it is the core of code execution.

ProcessManager features the following components:

- A generic process generator
- 3 types of process spawners
- A record of processes
- The process queues
- A task scheduler and executer
- A widget for UI configuration

See the theory section for more information about 
the process structure.


Public ProcessManager Functions
-------------------------------

ProcessManager exposes a number of functions 
in the module:processmanager lexicon.


spawnProcess
~~~~~~~~~~~~

Parameters:

- functionObject: an executable type object representing the function to be executed
- priority [optional]: a number 0-3 representing the process priority
- state [optional]: a list of parameters to be unpacked into the functionObject function on execution

Returns:

PID: a number indicating which process is being referenced. Can be used as an index in processrecord.

SpawnProcess generates a process of the class process via makeProcess and adds it to 
the queue. It simplifies the required information for generation significantly from 
makeProcess for ease of use. Processes spawned will be added to the 
process queue and executed on the next update tick if not killed.


spawnDaemon
~~~~~~~~~~~

Parameters:

- functionObject: an executable type object representing the function to be executed
- priority [optional]: a number 0-3 representing the process priority
- state [optional]: a list of parameters to be unpacked into the functionObject function on execution
- frequency [optional]: a number in the range (0,1] that is the fraction of update ticks the daemon should run in.

Returns:

PID: a number indicating which process is being referenced. Can be used as an index in processrecord.

SpawnDaemon generates a daemon of the class process via makeProcess and adds it to 
the daemon queue. Daemons are processes that are run at some set frequency. Daemons 
spawned will be added to the queue and will be executed starting within 25 update ticks 
or less. This offset is randomly applied to daemons to prevent multiple daemons spawned by 
the same function from triggering in the same ticks to spread out computation.

For example, the processmanager garbage collector daemon runs every 500 ticks.


spawnListener
~~~~~~~~~~~~~

Parameters:

- listenerObject: an executable type object representing the condition to be tested
- functionObject: an executable type object representing the function to be executed
- priority [optional]: a number 0-3 representing the process priority
- state [optional]: a list of parameters to be unpacked into the functionObject function on execution

Returns:

PID: a number indicating which process is being referenced. Can be used as an index in processrecord.

SpawnListener generates a listener of the class process via makeProcess and adds it to 
the listener queue. Listeners are designed to be low-overhead methods of waiting for a 
condition to execute. Instead of, for example, a daemon that checks a condition, listeners 
skip over most of the process execution setup and simply run the condition test function. 
Listeners will be checked once every update tick.


removeProcess
~~~~~~~~~~~~~

Parameters:

PID: the ID of the process to be removed

Returns:

Removed: `true` if removal was successful, else `false`.


RemoveProcess sets the `alive` key of the process indicated to false. 
This will prevent execution by the scheduler and will allow deletion of 
the process from the record by the garbage collector as long as the 
`retain` key of the process is not `true`.


respawnProcess
~~~~~~~~~~~~~~

Parameters:

PID: the ID of the process to be respawned

Returns:

Removed: `true` if respawn was successful, else `false`.


RemoveProcess sets the `alive` key of the process indicated to `true`. 
This does not re-add the process to any queue, but it prevents the garbage 
collector from discarding the process.


executeProcessByPID
~~~~~~~~~~~~~~~~~~~

Parameters:

PID: the ID of the process to be executed

Returns:

Removed: the return data from process execution


ExecuteProcessByPID will execute the indicated process with the state 
indicated in process's processrecord entry. This will not set the `alive` 
flag to false, nor will it remove the process executed from any queue. 
This function should generally not be used, and instead processes should 
be scheduled for execution, but some situations may necessitate usage of 
this function. ExecuteProcessByPID is called internally by the scheduler 
to execute queued tasks.


iterateOverQueues
~~~~~~~~~~~~~~~~~

iterateOverQueues will go through the queues in the following order of execution:

priority > queue (listeners, daemons, processes) > order added (FIFO)

This function is publicly exposed so it can be called from the main chaosinit 
file. It should not be called by any other function or file. It is called every 
update tick and runs until either all queues have been emptied or the game clock 
has moved to the next update tick.


unpackListToParams
~~~~~~~~~~~~~~~~~~

Parameters:

- targetFunction: a delegate for the function that parameters will be unpacked into
- parameterList: a list of parameters to be unpacked into the function

Returns:

boundFunction: a delegate that has the parameters bound to it

UnpackListToParams will take a list of parameters and map them to the parameters of 
the function passed in. It uses the bind() function to add each item to the function 
input. 

Code Example::

	function numberPrinter {
		parameter number.
		print "The number is " + number.
	}
	local printSeven is module:processmanager:unpackListToParams(
		numberprint@, list(7) ).
	printSeven().

The output will be:

``The number is 7``


onload
~~~~~~

Gets called by modulemanager when all modules and libraries are loaded. 
Adds a configuration widget to the UI, adds the global UPS setting to the 
config lexicon, and creates the garbageCollector daemon to run every 500 ticks.