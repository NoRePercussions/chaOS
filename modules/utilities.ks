// utility.ks
// utility library for chaOS

global function utilities {

global currentFunc is {print "ERROR". }.
local counter is 1.
local abc is "abcdefghij".

// Does not create new funtions unless both 
// the file name and creation function name 
// are unique. Dunno why, but now it works.
function textToRef {
	parameter plaintextfunction.
	local endText is appendText().
	log "global function execfunc" + endText + " { "
		+ plaintextfunction:replace("'", char(34))
		+ " }. set currentFunc to execfunc" + endText + "@." 
		to "1:/chaos/savedata/temp" + endText + ".ks".
	runpath("1:/chaos/savedata/temp" + endText + ".ks").
	local out is currentFunc@.
	deletepath("1:/chaos/savedata/temp" + endText + ".ks").
	return out@.
}

function appendText {
	local l10 is ceiling(log10(counter)).
	local operating is counter.
	set counter to counter + 1.
	local out is "".

	for i in range(l10) {
		local m10 is mod(operating, 10).
		set operating to (operating-m10)/10.
		set out to out + abc[m10].
	}

	return out.
}

function raiseWarning {
	parameter warningtext.
	module:ui:record("Warning @ ", warningtext). // Will be improved in text library
}

function raiseError {
	parameter warningtext.
	module:ui:record("Error @ ", warningtext). // Will be improved in text library
}

function delegate {
	parameter func.
	local object is lexicon(
		"delegate", func@,
		"type", "delegate").
	return object.
}

function reference {
	parameter ref.
	local path is ref:split(":").
	local func is 0.
	if path[0] = "module" {
		local pos is module. path:remove(0).
		for p in path:sublist(0, path:length-1) {
			set pos to pos[p].
		}.
		set func to pos[path[path:length-1]].
	}
	if path[0] = "library" {
		local pos is library. path:remove(0).
		for p in path:sublist(0, path:length-1) {
			set pos to pos[p].
		}.
		set func to pos[path[path:length-1]].
	}
	local object is lexicon(
		"delegate", func@,
		"reference", ref,
		"type", "reference").
	return object.
}


function stringFunction {
	parameter stringtext.
	local func is textToRef(stringtext).
	local object is lexicon(
		"delegate", func@,
		"string", stringtext,
		"type", "stringFunction").
	return object.
}


return lexicon(
	"textToRef", textToRef@,
	"raiseWarning", raiseWarning@,
	"throwWarning", raiseWarning@,
	"raiseError", raiseError@,
	"throwError", raiseError@,
	"delegate", delegate@,
	"reference", reference@,
	"stringFunction", stringFunction@
).

}

global loadingmodule is utilities@.