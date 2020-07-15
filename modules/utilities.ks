// utility.ks
// utility library for chaOS

global function utilities {

function textToRef {
	parameter plaintextfunction.
	log "global function execfunc { " + plaintextfunction:replace("'", char(34)) + " }." to "1:/chaos/savedata/temp.ks".
	print open("1:/chaos/savedata/temp.ks"):readall:string.
	runpath("1:/chaos/savedata/temp.ks").
	local out is execfunc@.
	deletepath("1:/chaos/savedata/temp.ks").
	return out@.
}


return lexicon(
	"textToRef", textToRef@
).

}

global loadingmodule is utilities@.