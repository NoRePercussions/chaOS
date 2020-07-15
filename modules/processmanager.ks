// processmanager.ks

// modulemanager.ks

global nextPID is 1.

global function processmanager {

function makeProcess {
	parameter func, type is "p",
	priority is 0, state is list(),
	alive is true, name is 0,
	parent is -1, retain is false.

	local children is list().

	if name = 0 { set name to nextPID. }.

	local newprocess is lexicon().
	newprocess:add("func", func).
	newprocess:add("type", type).
	newprocess:add("PID", nextPID).
	newprocess:add("alive", alive).
	newprocess:add("state", state).
	newprocess:add("priority", priority).
	newprocess:add("name", name).
	newprocess:add("parent", parent).
	newprocess:add("children", children).
	newprocess:add("retain", retain).
	newprocess:add("remove", removeprocess@:bind(nextPID)).

	processrecord:add(nextPID, newprocess).
	set nextPID to nextPID + 1.

	return newprocess.
}

function spawnProcess {
	parameter func, priority is 0, state is list().

	local newprocess is makeprocess(func@, "p", priority, state).
	processqueue[priority]:push(newprocess:PID).

	return newprocess.
}

function spawnDaemon {
	parameter func, priority is 0, state is list().

	local newprocess is makeprocess(func@, "d", priority, state).
	processqueue[priority]:push(newprocess:PID).

	return newprocess.
}

function executeProcessByPID {
	parameter PID.
	if processrecord:haskey(PID) {
		local initstate is processrecord[PID]:state.
		return processrecord[PID]:func().
	}
	return "Error".
}

function respawnProcess {
	parameter PID.
	if processrecord:haskey(PID) {set processrecord[PID]:alive to true. return true.}.
	return false.
}

function removeProcess {
	parameter PID.
	if processrecord:haskey(PID) {set processrecord[PID]:alive to false. return true.}.
	return false.
}

function iterateOverQueues {
	local startTime is time:seconds.
	for priority in range(3, 0-1) {
		if time:seconds <> startTime { break. }.
		for pQueue in list(processqueue, daemonqueue)  {//also listenerqueue??
			if time:seconds <> startTime { break. }.
			until pQueue[priority]:empty() {
				if time:seconds <> startTime { break. }.
				local PIDToExecute is pQueue[priority]:pop().
				local pType is processrecord[PIDToExecute]:type.
				local returnValue is processmanager:executeProcessByPID(PIDToExecute).
				print returnValue.
				if pType = "d" { daemonqueue:push(PIDToExecute). }.
				if pType = "p" { processmanager:removeProcess(PIDToExecute). }.
			}
		}
	}
}

function garbageCollector {
	for oldProcessKey in processrecord:keys {
		if processrecord[oldProcessKey]:retain = false and processrecord[oldProcessKey]:alive = false {
			processrecord:remove(oldProcessKey). 
		}
	}
}

function unpackListToParams {
	parameter func, paramList is list().
	local bindingfunction is func@.
	for param in paramList {
		set bindingfunction to bindingfunction:bind(param).
	}
	return bindingfunction@.
}

return lexicon(
	"makeProcess", makeProcess@,
	"spawnProcess", spawnProcess@,
	"spawnDaemon", spawnDaemon@,
	"respawnProcess", respawnProcess@,
	"removeProcess", removeProcess@,
	"executeProcessByPID", executeProcessByPID@,
	"iterateOverQueues", iterateOverQueues@,
	"garbageCollector", garbageCollector@,
	"unpackListToParams", unpackListToParams@
).

}

global loadingmodule is processmanager@.