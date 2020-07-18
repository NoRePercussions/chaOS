// commandline.ks

global function commandline {

local commandqueue is queue().

local commandDatabase is lexicon(
	"ls", lexicon("func", ls@, "minparams", 0, "maxparams", 1),
	"touch", lexicon("func", touch@, "minparams", 1, "maxparams", 1),
	"whereami", lexicon("func", whereami@, "minparams", 0, "maxparams", 0),
	"cd", lexicon("func", clcd@, "minparams", 1, "maxparams", 1),
	"mkdir", lexicon("func", mkdir@, "minparams", 1, "maxparams", 1),
	"exit", lexicon("func", exit@, "minparams", 0, "maxparams", 0),
	"help", lexicon("func", help@, "minparams", 0, "maxparams", 0)
).

function ls {
	parameter dirpath is "".

	if exists(dirpath) {

	local currentpath is path().
	cd(dirpath).
	print "dirpath " + dirpath.

	local filelist is "".
	list files in filelist.

	cd(currentpath).

	module:ui:record(filelist).

	} else {
		module:utilities:raiseError("'" + dirpath + "' is not a valid path").
	}
}

function touch {
	parameter filepath.

	if exists(filepath) {
		module:utilities:raiseError("'" + filepath + "' already exists or is not a valid path").
	} else {
		create(filepath).
	}
}

function whereami {
	module:ui:record(path()).
}

function clcd {
	parameter dirpath.

	if exists(dirpath) {
		cd(dirpath).
	} else {
		module:utilities:raiseError("'" + dirpath + "' is not a valid path").
	}
}

function mkdir {
	parameter dirpath.

	if exists(dirpath) {
		module:utilities:raiseError("'" + dirpath + "' already exists or is not a valid path").
	} else {
		createdir(dirpath).
	}
}

function exit {
	set chaOSConfig:quit to true.
}

function help {
	module:ui:record(commandDatabase:keys).
}

function parseFunction {
	parameter fullcall.
	module:ui:record("$ " + fullcall).

	local parameters is fullcall:split(" ").
	local functionname is parameters[0]. parameters:remove(0).

	if commandDatabase:haskey(functionname) = false {
		module:utilities:raiseError("Function name is not recognized").
	} else if commandDatabase[functionname]:minparams <= parameters:length
	and parameters:length <= commandDatabase[functionname]:maxparams {
		module:processmanager:unpackListToParams(
			commandDatabase[functionname]:func@, parameters)().
	} else {
		module:utilities:raiseError("The number of parameters passed is wrong").
	}
}

function parseAllCommands {
	until commandqueue:empty() {
		parseFunction(commandqueue:pop()).
	}
}

function addCommandToQueue {
	parameter command.

	commandqueue:push(command).
}

function onload {
	module:ui:record("Run 'help' for a list of commands").
	module:processmanager:spawnDaemon(
		module:utilities:reference("module:commandline:parseAllCommands"), 3, list(), 1/5).
}

return lexicon(
	"parseAllCommands", parseAllCommands@,
	"addCommandToQueue", addCommandToQueue@,
	"onload", onload@
).

}

global loadingmodule is commandline@.