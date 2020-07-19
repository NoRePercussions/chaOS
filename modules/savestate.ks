// savestate.ks

global function savestate {

local savefolder is "1:/chaos/savedata/".

function saveCurrentState {
	writejson(chaOSConfig, savefolder + "config.dat").
	writejson(compileProcesses(), savefolder + "processrecord.dat").
	local queuelist is list(processqueue, daemonqueue, listenerqueue).
	writejson(queuelist, savefolder + "queues.dat").
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

function loadSavedState {
	chaOSConfig:clear. set chaOSConfig to readjson(savefolder + "config.dat").
	local queuelist is readjson(savefolder + "queues.dat").
	print queuelist.
	processqueue:clear(). set processqueue to queuelist[0].
	daemonqueue:clear(). set daemonqueue to queuelist[1].
	listenerqueue:clear(). set listenerqueue to queuelist[2].
	local preprocessrecord is readjson(savefolder + "processrecord.dat").
	processrecord:clear(). set processrecord to restoreProcesses(preprocessrecord).
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

		if prepr[PID]:ptype = "listener" and prepr[PID]:haskey("listenersource") {
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

local self is lexicon(
	"saveCurrentState", saveCurrentState@,
	"loadSavedState", loadSavedState@
).

return self.

}

global loadingmodule is savestate@.