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


Public ProcessManager Variables
-------------------------------

Processmanager has four global variables - the processRecord, 
that holds information about all active processes, and three 
queues of active processes. These queues are really lists each 
holding four queues, one per priority.


processRecord
~~~~~~~~~~~~~

ProcessRecord is a lexicon with process objects assigned with 
their keys being their PIDs. The record is periodically cleared 
of inactive processes by the garbage collector, which is why it 
is not a list.


Queues
~~~~~~

ProcessManager hold three lists: the process queue (one-off tasks), 
the daemon queue (repeated tasks), and the listener queue (conditional 
tasks). Each list consists of four queues at the index of their priority, 
with 3 being the most important and first executed. The internal queues 
are sorted first-in, first-out (FIFO). The order of execution of processes 
is sorted in the following order:

priority > queue (listeners, daemons, processes) > order added (FIFO)

The listener queue gets executed first. Listener-type processes have 
a function that tests a condition and returns an output. The execution 
of listeners is designed to be low overhead, high throughput. Listeners 
typically skip most of the process loading steps and just test the 
condition, only loading the full process when the condition is met. 
Best practice is to not put long computations into listener processes, 
which slows the whole queue, but instead spawn a process or daemon once 
the condition is met.

The daemon queue is executed next. Daemon-type processes run at a set 
interval (for example one in five update ticks) and are staggered randomly 
when spawned, preventing large numbers of daemons spawned in the same tick 
from piling up overhead. If a daemon is not run during its scheduled tick, 
it will not be run in the next tick and must instead wait for another 
scheduled tick. Daemons are great for any code that must be run repeatedly, 
no matter if they need to run often or infrequently. Daemons are especially 
useful for repeated calculations or control updates if locks are not an option.

The process queue is the final queue to be executed in each priority step. 
Processes in this context are one-off tasks that will be run and then removed 
from the queue. Processes will be run in the next available tick, and will be 
be postponed by one if there is no more execution time left in the tick. They 
are great for initial calculations, setup, and anything else that runs once.


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