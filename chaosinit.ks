// chaosinit.ks
clearscreen.
cd("1:/chaos/").

global chaOSconfig is lexicon("startTime", time:seconds, "quit", false).

if exists("1:/chaos/savedata/persist.dat") {
	// revertfromsave().
} else {
	if exists("1:/chaos/savedata/config.txt") {
			startup().
		} else {
			firstruninit().
			startup().
		}
}

function firstruninit {
	print "Beginning first setup".
	copypath("0:/chaos/savedata/", "1:/chaos/savedata/").
}

function startup {
	copypath("0:/chaos/modules/", "1:/chaos/").
	copypath("0:/chaos/libraries/", "1:/chaos/").

	global processrecord is lexicon().

	global processqueue is list(queue(), queue(), queue(), queue()). // 0-3 by priority
	global daemonqueue is list(queue(), queue(), queue(), queue()).
	global listenerqueue is list(queue(), queue(), queue(), queue()).
	global module is lexicon().
	global library is lexicon().

	runoncepath("1:/chaos/modules/modulemanager").

	module:ui:makeActiveGUI().

	test().

	until chaOSconfig:quit {
		module:processmanager:iterateOverQueues(). wait 0.
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
	module:utilities:textToRef("module:ui:debug('Test of string-to-func execution').")().
	module:processmanager:iterateOverQueues().
	module:processmanager:removeProcess(processPID).
	module:processmanager:garbageCollector().
	module:ui:debug("Done!").
}