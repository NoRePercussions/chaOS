// chaosinit.ks
clearscreen.
cd("1:/chaos/").
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
	copypath("0:/chaos/modules/", "1:/chaos/").
	copypath("0:/chaos/libraries/", "1:/chaos/").

	global processrecord is lexicon().

	global processqueue is list(queue(), queue(), queue(), queue()). // 0-3 by priority
	global daemonqueue is list(queue(), queue(), queue(), queue()).
	global listenerqueue is list(queue(), queue(), queue(), queue()).
	global module is lexicon().
	global library is lexicon().

	runoncepath("1:/chaos/modules/modulemanager").
	test().
}

function POST {
	print "This is a test message".
	return "This is a test return".
}

function test {
	local processPID is processmanager:spawnProcess(POST@, 1, list("test")):PID.
	local testprint is module:utilities:textToRef("print 'Test of string-to-func execution'.").
	testprint().
	processmanager:iterateOverQueues().
	processmanager:removeProcess(processPID).
	processmanager:garbageCollector().
	print processrecord.
	print module.
	print "Done!".
}