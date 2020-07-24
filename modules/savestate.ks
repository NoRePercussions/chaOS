// savestate.ks

global function savestate {

local savefolder is "1:/chaos/savedata/".

function saveCurrentState {
	writejson(chaOSConfig, savefolder + "config.dat").
	writejson(compileProcesses(), savefolder + "processrecord.dat").
	local queuelist is list(newprocessqueue, newdaemonqueue, newlistenerqueue,
		processqueue, daemonqueue, listenerqueue).
	writejson(queuelist, savefolder + "queues.dat").
	writejson(compileControls(), savefolder + "controls.dat").
}

function compileProcesses {
	local compiled is lexicon().
	for PID in processrecord:keys {
		local process is processrecord[PID]:copy().
		process:remove("func").
		process:remove("remove").
		if process:haskey("listenerref") {
			process:remove("listenerref").
		}
		compiled:add(PID, process).
	}
	return compiled.
}

function compileControls {
	local compiled is lexicon().
	if throtsource:typename = "List" { compiled:add("throttle", throtsource:remove("delegate")). }
		else if throtsource:typename <> "UserDelegate" { compiled:add("throttle", throtsource). }.
	if stsource:typename = "List" { compiled:add("steering", stsource:remove("delegate")). }
		else if stsource:typename <> "UserDelegate" { compiled:add("steering", stsource). }.
	return compiled.
}

function loadSavedState {
	chaOSConfig:clear. set chaOSConfig to readjson(savefolder + "config.dat").

	local queuelist is readjson(savefolder + "queues.dat").
	newprocessqueue:clear(). set newprocessqueue to queuelist[0].
	newdaemonqueue:clear(). set newdaemonqueue to queuelist[1].
	newlistenerqueue:clear(). set newlistenerqueue to queuelist[2].
	processqueue:clear(). set processqueue to queuelist[3].
	daemonqueue:clear(). set daemonqueue to queuelist[4].
	listenerqueue:clear(). set listenerqueue to queuelist[5].

	local preprocessrecord is readjson(savefolder + "processrecord.dat").
	processrecord:clear(). set processrecord to restoreProcesses(preprocessrecord).

	restoreSteering(readjson(savefolder + "controls.dat")).
}

function restoreProcesses {
	parameter prepr.
	for PID in prepr:keys {
		if prepr[PID]:reftype = "delegate" {
			prepr:remove(PID).
		} else if prepr[PID]:reftype = "stringFunction" {
			set prepr[PID]:func to module:utilities:stringFunction(prepr[PID]:source):delegate@.
		} else if prepr[PID]:reftype = "reference" {
			set prepr[PID]:func to module:utilities:reference(prepr[PID]:source):delegate@.
		}

		if prepr[PID]:ptype = "l" and prepr[PID]:haskey("listenersource") {
			if prepr[PID]:listenertype = "delegate" {
				prepr:remove(PID).
			} else if prepr[PID]:listenertype = "stringFunction" {
				set prepr[PID]:listenerref to module:utilities:stringFunction(prepr[PID]:listenersource):delegate@.
			} else if prepr[PID]:listenertype = "reference" {
				set prepr[PID]:listenerref to module:utilities:reference(prepr[PID]:listenersource):delegate@.
			}
		}
	}
	return prepr.
}

function restoreSteering {
	parameter controls.

	if controls:haskey("throttle") {
		local cthrottle is controls:throttle.
		if cthrottle:typename = "List" {
			if cthrottle:reftype = "delegate" {
				// No data to go based on, so no reference made
			} else if cthrottle:reftype = "stringFunction" {
				set throtsource to module:utilities:stringFunction(cthrottle:source).
				lock throtval to throtsource:delegate().
				lock throttle to throtval.
			} else if cthrottle:reftype = "reference" {
				set throtsource to module:utilities:reference(cthrottle:source).
				lock throtval to throtsource:delegate().
				lock throttle to throtval.

			}
		} else {
			set throtsource to cthrottle.
			lock throtval to cthrottle.
			lock throttle to throtval.
		}
	}

	if controls:haskey("steering") {
		local csteering is controls:steering.
		if csteering:typename = "List" {
			if csteering:reftype = "delegate" {
				// No data to go based on, so no reference made
			} else if csteering:reftype = "stringFunction" {
				set stsource to module:utilities:stringFunction(csteering:source).
				lock stval to stsource:delegate().
				lock steering to stval.
			} else if csteering:reftype = "reference" {
				set stsource to module:utilities:reference(csteering:source).
				lock stval to stsource:delegate().
				lock steering to stval.

			}
		} else {
			set stsource to csteering.
			lock stval to csteering.
			lock steering to stval.
		}
	}
}

local self is lexicon(
	"saveCurrentState", saveCurrentState@,
	"loadSavedState", loadSavedState@
).

return self.

}

global loadingmodule is savestate@.