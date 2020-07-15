// ui.ks

global function ui {

	local fulldebug is list().
	local nodebug is list().

	function debug {
		parameter text.
		fulldebug:add(text).
		print text.
	}

	function record {
		parameter text.
		fulldebug:add(text).
		nodebug:add(text).
		print text.
	}

	return lexicon(
		"fulldebug", fulldebug,
		"nodebug", nodebug,
		"debug", debug@,
		"record", record@
	).
}

global loadingmodule is ui@.