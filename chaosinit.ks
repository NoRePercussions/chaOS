// chaosinit.ks
clearscreen.
cd("1:/chaos/").

global chaOSconfig is lexicon("startTime", time:seconds, "quit", false).

init().

if exists("1:/chaos/savedata/config.txt") = false {
	firstruninit().
}
if exists("1:/chaos/savedata/queues.dat") {
	revertfromsave().
}
startup().

function firstruninit {
	print "Beginning first setup".
	copypath("0:/chaos/savedata/", "1:/chaos/savedata/").
}

function init {
	runoncepath("1:/chaos/modules/modulemanager").
	
	module:ui:makeActiveGUI().

	test().
}

function startup {

	until chaOSconfig:quit {
		module:processmanager:iterateOverQueues(). 
		module:savestate:saveCurrentState().
		wait 0.
	}.

	module:ui:gui:dispose().
	cd("1:/chaos/").
}

function POST {
	parameter testval.
	module:ui:debug("This is a " + testval + " message").
	return "This is a test return".
}

function test {
	local processPID is module:processmanager:spawnProcess(
		module:utilities:delegate(POST@), 1, list("test")):PID.
	module:processmanager:spawnListener(
		module:utilities:stringFunction("if time:seconds >=  10 + " + time:seconds + " return true. return false."),
		module:utilities:stringFunction("module:ui:debug('Listener has fired!')."),
		0, list()).
	module:ui:debug("Done!").
}

function revertfromsave {
	module:savestate:loadSavedState().
}