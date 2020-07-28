.. processes:

Process Theory
==============

.. contents::
	:local:
	:depth: 2
	
	
What are Processes?
-------------------

Processes are chunks of code that is executed 
together. Processes are used in all major operating 
systems to separate tasks and make it easy to add and 
run new bits of code.


Types of Processes in chaOS
---------------------------

chaOS uses 3 types of processes in its task scheduler

* Processes (same name) - Tasks that run once
* Daemons - Tasks that run repeatedly
* Listeners - Tasks that run when a condition is satisfied

Processes run one time and are then removed 
from the execution queue. They can be assigned 
a priority and initial state along with the function 
to be executed. They can be created with executable-
-type objects or any of their constructors.

Daemons run repeatedly at a set frequency and are 
never automatically removed from the queue. They 
can be assigned a priority, initial state, and 
a fraction of update ticks to run during.

Listeners run when a condition is met. Until the 
condition is satisfied, they skip the steps of 
loading a process, resulting in less overhead than 
a daemon with an if statement. They can be removed or 
preserved once the condition has been satisfied.


Process Execution
-----------------

Processes are executed according to the :ref:`Task Scheduler<taskscheduler>`. 
See the theory page for more information.


Working with Processes
----------------------

Processes are handled by the :ref:`Process Manager<processmanager>` module. 
See its module page for more information.

Processes **can** be spawned inside other functions. 
chaOS will catch new processes and add them to the operating 
queues after execution is done, preventing conflicts.