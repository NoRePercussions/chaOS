// processmanager.ks


chaOSConfig:add("nextPID", 1).

global function processmanager {

global processrecord is lexicon().

global newprocessqueue is list(queue(), queue(), queue(), queue()). // 0-3 by priority
global newdaemonqueue is list(queue(), queue(), queue(), queue()).
global newlistenerqueue is list(queue(), queue(), queue(), queue()).

global processqueue is list(queue(), queue(), queue(), queue()). // 0-3 by priority
global daemonqueue is list(queue(), queue(), queue(), queue()).
global listenerqueue is list(queue(), queue(), queue(), queue()).

global updatecycle is 0.
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

	if name = 0 { set name to chaOSConfig:nextPID. }.

	local newprocess is lexicon().
	newprocess:add("func", func).
	newprocess:add("ptype", ptype).
	newprocess:add("PID", chaOSConfig:nextPID).
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
	newprocess:add("remove", removeprocess@:bind(chaOSConfig:nextPID)).
	newprocess:add("listener", listener).

	newprocess:add("returnValue", "None").

	if listener {
		newprocess:add("listenerref", listenerref@).
		newprocess:add("listenertype", listenertype).
		newprocess:add("listenersource", listenersource).
	}.

	processrecord:add(chaOSConfig:nextPID, newprocess).
	set chaOSConfig:nextPID to chaOSConfig:nextPID + 1.

	return newprocess.
}

function spawnProcess {
	parameter func, priority is 0, state is list().
	local source is "".
	local funcobject is smartType(func).
	if funcobject:type = "reference" { set source to funcobject:reference. }.
	if funcobject:type = "stringFunction" { set source to funcobject:string. }.
	if funcobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local newprocess is makeprocess(funcobject:delegate@, "p",
		priority, state, funcobject:type, source).
	newprocessqueue[priority]:push(newprocess:PID).

	return newprocess.
}

function spawnDaemon {
	parameter func, priority is 0, state is list(), frequencyratio is 1.
	local source is "".
	local funcobject is smartType(func).
	if funcobject:type = "reference" { set source to funcobject:reference. }.
	if funcobject:type = "stringFunction" { set source to funcobject:string. }.
	if funcobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local newprocess is makeprocess(funcobject:delegate@, "d",
		priority, state, funcobject:type, source, frequencyratio).
	newdaemonqueue[priority]:push(newprocess:PID).

	return newprocess.
}

function spawnListener {
	parameter listenerfunc, func, priority is 0, state is list().
	local source is "".
	local listenerobject is smartType(listenerfunc).
	local funcobject is smartType(func).
	if funcobject:type = "reference" { set source to funcobject:reference. }.
	if funcobject:type = "stringFunction" { set source to funcobject:string. }.
	if funcobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local listenersource is "".
	if listenerobject:type = "reference" { set listenersource to listenerobject:reference. }.
	if listenerobject:type = "stringFunction" { set listenersource to listenerobject:string. }.
	if listenerobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local newprocess is makeprocess(funcobject:delegate@, "l",
		priority, state, funcobject:type, source, 0,
		true, listenerobject:delegate@, listenerobject:type, listenersource).
	newlistenerqueue[priority]:push(newprocess:PID).

	return newprocess.
}

function smartType {
	parameter unknown.

	if unknown:typename = "List" {
		return unknown.
	} else if unknown:typename = "UserDelegate" {
		return module:utilities:delegate(unknown).
	} else if unknown:typename = "string" {
		if unknown:contains(".") {
			return module:utilities:stringFunction(unknown).
		} else {
			return module:utilities:reference(unknown).
		}
	}

	return unknown.
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

		until newlistenerqueue[priority]:empty listenerqueue[priority]:push(newlistenerqueue[priority]:pop()).

		for l in range(listenerqueue[priority]:length) {
			if time:seconds <> startTime { break. }.
			local listener is listenerqueue[priority]:pop().
			if processrecord[listener]:listenerref:call() and processrecord[listener]:alive {
				print "executing listener".
				set processrecord[listener]
				:returnValue to executeProcessByPID(listener).
				self:removeProcess(listener).
			} else if processrecord[listener]:alive { listenerqueue[priority]:push(listener). }.
		}

		until newdaemonqueue[priority]:empty daemonqueue[priority]:push(newdaemonqueue[priority]:pop()).

		for d in range(daemonqueue[priority]:length) {
			if time:seconds <> startTime { break. }.
			local daemon is daemonqueue[priority]:pop().
			if mod(processorcycle + processrecord[daemon]:frequencyoffset, 1/processrecord[daemon]:frequencyratio) >= 1 {
				local PIDToExecute is daemon.
				set processrecord[PIDToExecute]
				:returnValue to executeProcessByPID(PIDToExecute)().
			}
			if processrecord[daemon]:alive { daemonqueue[priority]:push(daemon). }.
		}

		until newprocessqueue[priority]:empty processqueue[priority]:push(newprocessqueue[priority]:pop()).

		until processqueue[priority]:empty() or time:seconds <> startTime {
			local PIDToExecute is processqueue[priority]:pop().
			if processrecord[PIDToExecute]:alive {
				set processrecord[PIDToExecute]
				:returnValue to executeProcessByPID(PIDToExecute)().
				removeProcess(PIDToExecute).
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

function onload {
	chaOSconfig:add("ups", 50).
	module:ui:addConfigWidget(configWidget@).
	module:processmanager:spawndaemon(module:utilities:reference("module:processmanager:garbageCollector"), 3, list(), 1/500).
}

function configWidget {
	parameter body.
	local speedlabel is body:addlabel("Instructions/update (50-2000) and Updates/second (1-50)").
	set speedlabel:style:align to "CENTER".
	set speedlabel:style:hstretch to true.

	local speedbox is body:addhlayout().

	set nextdebouncetime to time:seconds + 0.2.
	local ipubox is speedbox:addtextfield(config:ipu:tostring).
	set ipubox:onconfirm to {
		parameter newipu.
		if newipu:length = 0 or time:seconds < nextdebouncetime return.
		set nextdebouncetime to time:seconds + 0.2.
		set config:ipu to newipu:toscalar. set ipubox:text to config:ipu:tostring.
		module:ui:debug("New IPU: " + config:ipu:tostring).
	}.
	local ipulabel is speedbox:addlabel("IPU").
	local upsbox is speedbox:addtextfield(chaOSconfig:ups:tostring).
	set upsbox:onconfirm to {
		parameter newups.
		if newups:length = 0 or time:seconds < nextdebouncetime return.
		set nextdebouncetime to time:seconds + 0.2.
		set chaOSconfig:ups to max(min(newups:toscalar,50),1). set upsbox:text to chaOSconfig:ups:tostring.
		module:ui:debug("New UPS: " + chaOSconfig:ups:tostring).
	}.
	local upslabel is speedbox:addlabel("UPS").
}

local self is lexicon(
	"makeProcess", makeProcess@,
	"spawnProcess", spawnProcess@,
	"spawnDaemon", spawnDaemon@,
	"spawnListener", spawnListener@,
	"respawnProcess", respawnProcess@,
	"removeProcess", removeProcess@,
	"executeProcessByPID", executeProcessByPID@,
	"smartType", smartType@.
	"iterateOverQueues", iterateOverQueues@,
	"garbageCollector", garbageCollector@,
	"unpackListToParams", unpackListToParams@,
	"onload", onload@
).

return self.

}

global loadingmodule is processmanager@.