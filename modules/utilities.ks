// utility.ks
// utility library for chaOS

global function utilities {

function textToRef {
	parameter plaintextfunction.
	log "global function execfunc { "
	+ plaintextfunction:replace("'", char(34))
	+ " }." to "1:/chaos/savedata/temp.ks".
	runpath("1:/chaos/savedata/temp.ks").
	local out is execfunc@.
	deletepath("1:/chaos/savedata/temp.ks").
	return out@.
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