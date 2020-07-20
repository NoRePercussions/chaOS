.. _index:

chaOS: Operating System and Microkernel for kOS
===============================================

Making kOS more advanced
------------------------

**chaOS** is an operating system built over kOS. 
It features a unix-style terminal, a better 
in-game file editor, easy configuration of 
chaOS and kOS settings, and advanced program 
design through modules, libraries, and advanced 
task scheduling. The best part - **chaOS** is 
fault tolerant, so if your game crashes, you 
switch away, or reload the vessel, your program 
will pick up right where it left off!

About task scheduling
---------------------

Task scheduling lets you run parts of programs 
at different times to ensure everything gets run. 
chaOS features a priority- then first in-first out 
based scheduler through the processmanager module. 
You can create one-off tasks, daemons that run 
every set amount of time, or low-overhead listeners 
that wait for a condition to be satisfied.

Fault-tolerance
---------------

Every physics update, chaOS will save its current 
state into a set of files. If it detects a restart, 
it will reload from these files. They are local to 
each processor, so each core will only remember its 
own state. The main limitation is that delegates cannot 
be saved, but chaOS's reference path and text function 
types can be quickly implemented and will not fail.

Installation
------------

Place the **chaos** folder into your Ships/Script folder 
and move chaos/boot/chaosboot.ks to the Ships/Script/boot 
folder. When you launch a vessel, set chaosboot as the boot 
file to select modules and libraries to copy.