// processmanager.ks


chaOSConfig:add("nextPID", 1).

global function processmanager {

global processrecord is lexicon().

global newtaskqueue is list(queue(), queue(), queue(), queue()). // 0-3 by priority
global newdaemonqueue is list(queue(), queue(), queue(), queue()).
global newlistenerqueue is list(queue(), queue(), queue(), queue()).

global taskqueue is list(queue(), queue(), queue(), queue()). // 0-3 by priority
global daemonqueue is list(queue(), queue(), queue(), queue()).
global listenerqueue is list(queue(), queue(), queue(), queue()).

global updatecycle is 0.
local processorcycle is 0.

function makeProcess {
	parameter func, ptype is "t",
	priority is 0, state is list(),
	reftype is "delegate", source is "",
	frequencyratio is 1,
	listener is false, listenerref is 0,
	listenertype is "", listenersource is "",
	alive is true, retain is false, parent is -1.

	local children is list().

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

function spawnTask {
	parameter func, priority is 0, state is list().
	local source is "".
	local funcobject is module:utilities:smartType(func).
	if funcobject:type = "reference" { set source to funcobject:reference. }.
	if funcobject:type = "stringFunction" { set source to funcobject:string. }.
	if funcobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local newtask is makeprocess(funcobject:delegate@, "t",
		priority, state, funcobject:type, source).
	newtaskqueue[priority]:push(newtask:PID).

	return newtask.
}

function spawnDaemon {
	parameter func, priority is 0, state is list(), frequencyratio is 1.
	local source is "".
	local funcobject is module:utilities:smartType(func).
	if funcobject:type = "reference" { set source to funcobject:reference. }.
	if funcobject:type = "stringFunction" { set source to funcobject:string. }.
	if funcobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local newprocess is makeprocess(funcobject:delegate@, "d",
		priority, state, funcobject:type, source, frequencyratio).
	newdaemonqueue[priority]:push(newprocess:PID).

	return newprocess.
}

function spawnListener {
	parameter listenerfunc, func, priority is 0, state is list(), retain is false.
	local source is "".
	local listenerobject is module:utilities:smartType(listenerfunc).
	local funcobject is module:utilities:smartType(func).
	if funcobject:type = "reference" { set source to funcobject:reference. }.
	if funcobject:type = "stringFunction" { set source to funcobject:string. }.
	if funcobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local listenersource is "".
	if listenerobject:type = "reference" { set listenersource to listenerobject:reference. }.
	if listenerobject:type = "stringFunction" { set listenersource to listenerobject:string. }.
	if listenerobject:type = "delegate" { module:utilities:raiseWarning("Delegates cannot be saved and will be discarded on restart"). }.

	local newprocess is makeprocess(funcobject:delegate@, "l",
		priority, state, funcobject:type, source, 0,
		true, listenerobject:delegate@, listenerobject:type, listenersource, true, retain).
	newlistenerqueue[priority]:push(newprocess:PID).

	return newprocess.
}

global function await {
	parameter waittime, func, priority is 0, state is list().

	return spawnListener(
		"return time:seconds >= " + time:seconds + waittime	+ ".",
		func, priority, state ).
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
				set self to processrecord[listener].
				set processrecord[listener]
				:returnValue to executeProcessByPID(listener).
				if processrecord[listener]:retain { listenerqueue[priority]:push(listener). }
				else removeProcess(listener).
			} else if processrecord[listener]:alive { listenerqueue[priority]:push(listener). }.
		}

		until newdaemonqueue[priority]:empty daemonqueue[priority]:push(newdaemonqueue[priority]:pop()).

		for d in range(daemonqueue[priority]:length) {
			if time:seconds <> startTime { break. }.
			local daemon is daemonqueue[priority]:pop().
			if mod(processorcycle + processrecord[daemon]:frequencyoffset, 1/processrecord[daemon]:frequencyratio) >= 1 
			and processrecord[daemon]:alive {
				local PIDToExecute is daemon.
				set self to processrecord[daemon].
				set processrecord[PIDToExecute]
				:returnValue to executeProcessByPID(PIDToExecute)().
			}
			if processrecord[daemon]:alive { daemonqueue[priority]:push(daemon). }.
		}

		until newtaskqueue[priority]:empty taskqueue[priority]:push(newtaskqueue[priority]:pop()).

		until taskqueue[priority]:empty() or time:seconds <> startTime {
			local PIDToExecute is taskqueue[priority]:pop().
			if processrecord[PIDToExecute]:alive {
				set self to processrecord[PIDToExecute].
				set processrecord[PIDToExecute]
				:returnValue to executeProcessByPID(PIDToExecute)().
				removeProcess(PIDToExecute).
			}
		}
	}
}

function garbageCollector {
	for oldProcessKey in processrecord:keys {
		if processrecord[oldProcessKey]:alive = false {
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

return lexicon(
	"makeProcess", makeProcess@,
	"spawnTask", spawnTask@,
	"spawnDaemon", spawnDaemon@,
	"spawnListener", spawnListener@,
	"await", await@,
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