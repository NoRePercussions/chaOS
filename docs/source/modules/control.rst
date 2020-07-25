.. _control:

The Control Module
==================

.. contents::
	:local:
	:depth: 2


What is the Control Module?
---------------------------

This module handles all ship controls and allows for 
them to be saved by chaOS. It also allows you to set 
reference paths and strings for steering control and
throttle, as well as the usual functions, directions 
and numbers.


Public control functions
------------------------

setSteering
~~~~~~~~~~~

Parameters:

steeringTarget - the direction to steer to. Can be many types (see below)

Locks the steering to a direction specified by the value or return value 
of the specified target. This input can be any of the following:

* Direction (rotation, heading, quaternion, etc)
* Vector
* Function delegate that returns a direction or vector*
* Reference path that returns a direction or vector
* String copy of a function that returns a direction or vector
* Executable object that returns a direction or vector

.. Note::
	
	Delegates cannot be saved by chaOS


releaseSteering
~~~~~~~~~~~~~~~

Releases the current lock on steering.


setThrottle
~~~~~~~~~~~

Parameters:

throttleTarget - the value to throttle to. Can be many types (see below)

Locks the steering to a direction specified by the value or return value 
of the specified target. This input can be any of the following:

* Scalar
* Function delegate that returns a scalar*
* Reference path that returns a scalar
* String copy of a function that returns a scalar
* Executable object that returns a scalar

.. Note::
	
	Delegates cannot be saved by chaOS


releaseThrottle
~~~~~~~~~~~~~~~

Releases the current lock on steering.