// chaosinit.ks
clearscreen.
if exists("1:/chaos/savedata/persist.dat") {
	// revertfromsave().
} else {
	if exists("1:/chaos/savedata/config.txt") {
			startup().
		} else {
			firstruninit().
		}
}

function firstruninit {
	print "Beginning first setup".
	copypath("0:/chaos/savedata/", "1:/chaos/savedata/").
}

function startup {
	copypath("0:/chaos/modules/", "1:/chaos/modules/").
	copypath("0:/chaos/libraries/", "1:/chaos/libraries/").

	global processrecord is lexicon().

	global processqueue is list(queue(), queue(), queue(), queue()). // 0-3 by priorit
	global daemonqueue is list(queue(), queue(), queue(), queue()).
	global listenerqueue is list(queue(), queue(), queue(), queue()).

	runoncepath("1:/chaos/modules/modulemanager").
	global processmanager is processmanager().
	test().
}

function POST {
	print "This is a test message".
	return "This is a test return".
}

function test {
	local processPID is processmanager:spawnProcess(POST@, 1, list("test")):PID.
	processmanager:iterateOverQueues().
	processmanager:removeProcess(processPID).
	processmanager:garbageCollector().
	print processrecord.
	print "Done!".
}