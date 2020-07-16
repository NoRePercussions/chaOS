// processmanager.ks

// modulemanager.ks

global nextPID is 1.

global function processmanager {

local updatecycle is 0.
local processorcycle is 0.

function makeProcess {
	parameter func, ptype is "p",
	priority is 0, state is list(),
	reftype is "delegate", source is "",
	frequencyratio is 1,
	listener is false, listenerref is 0,
	listenertype is "", listenersource is "",
	alive is true, name is 0,
	parent is -1, retain is false.

	local children is list().

	if name = 0 { set name to nextPID. }.

	local newprocess is lexicon().
	newprocess:add("func", func).
	newprocess:add("ptype", ptype).
	newprocess:add("PID", nextPID).
	newprocess:add("alive", alive).
	newprocess:add("state", state).
	newprocess:add("reftype", reftype).
	newprocess:add("source", source).
	newprocess:add("frequencyratio", frequencyratio).
	newprocess:add("frequencyoffset", floor(random()*25)).
	newprocess:add("priority", priority).
	newprocess:add("name", name).
	newprocess:add("parent", parent).
	newprocess:add("children", children).
	newprocess:add("retain", retain).
	newprocess:add("remove", removeprocess@:bind(nextPID)).
	newprocess:add("listener", listener).

	newprocess:add("returnValue", "None").

	if listener {
		newprocess:add("listenerref", listenerref@).
		newprocess:add("listenertype", listenertype).
		newprocess:add("listenersource", listenersource).
	}.

	processrecord:add(nextPID, newprocess).
	set nextPID to nextPID + 1.

	return newprocess.
}

function spawnProcess {
	parameter funcobject, priority is 0, state is list().
	local source is "".
	if funcobject:type = "reference" { set source to funcobject:reference. }.
	if funcobject:type = "stringFunction" { set source to funcobject:string. }.
	if funcobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local newprocess is makeprocess(funcobject:delegate@, "p",
		priority, state, funcobject:type, source).
	processqueue[priority]:push(newprocess:PID).

	return newprocess.
}

function spawnDaemon {
	parameter funcobject, priority is 0, state is list(), frequencyratio is 1.
	local source is "".
	if funcobject:type = "reference" { set source to funcobject:reference. }.
	if funcobject:type = "stringFunction" { set source to funcobject:string. }.
	if funcobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local newprocess is makeprocess(funcobject:delegate@, "d",
		priority, state, funcobject:type, source, frequencyratio).
	daemonqueue[priority]:push(newprocess:PID).

	return newprocess.
}

function spawnListener {
	parameter listenerobject, funcobject, priority is 0, state is list().
	local source is "".
	if funcobject:type = "reference" { set source to funcobject:reference. }.
	if funcobject:type = "stringFunction" { set source to funcobject:string. }.
	if funcobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local listenersource is "".
	if listenerobject:type = "reference" { set source to listenerobject:reference. }.
	if listenerobject:type = "stringFunction" { set source to listenerobject:string. }.
	if listenerobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local newprocess is makeprocess(funcobject:delegate@, "l",
		priority, state, funcobject:type, source,
		true, listenerobject:delegate@, listenerobject:type, listenersource).
	listenerqueue[priority]:push(newprocess:PID).

	return newprocess.
}

function executeProcessByPID {
	parameter PID.
	if processrecord:haskey(PID) {
		local initstate is processrecord[PID]:state.
		return unpackListToParams(processrecord[PID]:func@, initstate):call().
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
	set updatecycle to updatecycle + 1.
	// Appears to run at 50 update ticks per second ??
	if mod(updatecycle, 50/chaOSconfig:ups) >= 1  { return. }.
	set processorcycle to processorcycle + 1.
	local startTime is time:seconds.
	for priority in range(3, 0-1) {
		if time:seconds <> startTime { break. }.

		for l in range(listenerqueue[priority]:length) {
			if time:seconds <> startTime { break. }.
			local listener is listenerqueue[priority]:pop().
			if processrecord[listener]:listenerref:call() {
				local PIDToExecute is listener.
				processrecord[PIDToExecute]
				:add("returnValue", processmanager:executeProcessByPID(PIDToExecute)).
				processmanager:removeProcess(PIDToExecute).
			} else { listenerqueue:push(listener). }.
		}

		for daemon in daemonqueue[priority] {
			if time:seconds <> startTime { break. }.
			if mod(processorcycle + processrecord[daemon]:frequencyoffset, 1/processrecord[daemon]:frequencyratio) >= 1 {
				local PIDToExecute is daemon.
				set processrecord[PIDToExecute]
				:returnValue to processmanager:executeProcessByPID(PIDToExecute)().
			}
		}

		until processqueue[priority]:empty() or time:seconds <> startTime {
			local PIDToExecute is processqueue[priority]:pop().
			set processrecord[PIDToExecute]
			:returnValue to processmanager:executeProcessByPID(PIDToExecute)().
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

function onload {
	chaOSconfig:add("ups", 50).
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
	"unpackListToParams", unpackListToParams@,
	"onload", onload@
).

}

global loadingmodule is processmanager@.