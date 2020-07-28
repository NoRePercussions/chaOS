.. taskscheduler:

Task Scheduling
===============

.. contents::
	:local:
	:depth: 2
	
	
What is Task Scheduling?
------------------------

Task scheduling sorts and executes processes 
according to various rules. All major operating 
systems use some form of task scheduling.


How does chaOS Schedule Tasks?
------------------------------

chaOS works on 3 main queues, one for each type 
of process (processes, daemons, and listeners) 
and works according to 3 main sorting rules.
Sorting is done by the following priority:

1. Assigned priority (0 to 3, set on process creation)
2. Process type (Listeners, daemons, then processes)
3. Order added (First In, First Out)


Executing Processes
-------------------

chaOS follows 4 steps when executing processes:

1. Pop next process from queue
2. Test if process should be run
3. Load process state and run
4. Capture return and remove process (if needed)


