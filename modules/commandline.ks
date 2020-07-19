// commandline.ks

global function commandline {

local commandqueue is queue().
local inEdit is false.

local commandDatabase is lexicon(
	"ls", lexicon("func", ls@, "minparams", 0, "maxparams", 1, "man", "ls [directorypath] - List files in selected directory, or current if none is supplied"),
	"touch", lexicon("func", touch@, "minparams", 1, "maxparams", 1, "man", "touch {filepath} - Creates an empty file at the path"),
	"whereami", lexicon("func", whereami@, "minparams", 0, "maxparams", 0, "man", "whereami - Print current directory path"),
	"cd", lexicon("func", clcd@, "minparams", 1, "maxparams", 1, "man", "cd {directorypath} - Changes directory to the one specified"),
	"mkdir", lexicon("func", mkdir@, "minparams", 1, "maxparams", 1, "man", "mkdir {directorypath} - Created a directory at the path"),
	"edit", lexicon("func", editfile@, "minparams", 1, "maxparams", 1, "man", "edit {filepath} - Opens the file in the chaOS editor"),
	"rm", lexicon("func", rm@, "minparams", 1, "maxparams", 1, "man", "rm {filepath} - Removes the file at the path"),
	"rmdir", lexicon("func", rm@, "minparams", 1, "maxparams", 1, "man", "rmdir {directorypath} - Removes the directory at the path"),
	"cp", lexicon("func", copy@, "minparams", 1, "maxparams", 2, "man", "cp {frompath} [topath] - copies a file or directory from the frompath to topath (or else current path)"),
	"mv", lexicon("func", move@, "minparams", 1, "maxparams", 2, "man", "mv {frompath} [topath] - moves a file or directory from the frompath to topath (or else current path)"),
	"man", lexicon("func", man@, "minparams", 1, "maxparams", 1, "man", "man {command} - Shows information about the command"),
	"exit", lexicon("func", exit@, "minparams", 0, "maxparams", 0, "man", "exit - Exits chaOS"),
	"help", lexicon("func", help@, "minparams", 0, "maxparams", 0, "man", "help - Returns a list of CLI commands")
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

	module:ui:record("Items in " + path() + ":" + char(10) + filelist:join(char(10))).

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

function rm {
	parameter filepath.
	deletepath(filepath).
}

function copy {
	parameter oldpath, newpath is path().
	copypath(oldpath, newpath).
}

function move {
	parameter oldpath, newpath is path().
	movepath(oldpath, newpath).
}

function man {
	parameter command.
	if commandDatabase:haskey(command) = false {
		module:utilities:raiseError("Function name is not recognized").
	} else {
		module:ui:record(commandDatabase[command]:man).
	}
}

function editfile {
	parameter filepath.

	module:ui:enterEditMode(filepath).
}

function exit {
	set chaOSConfig:quit to true.
}

function help {
	module:ui:record("Run man {command} for more information" + char(10) + commandDatabase:keys:join(char(10))).
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