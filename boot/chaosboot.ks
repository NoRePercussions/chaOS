// chaosboot.ks

wait 5.
createdir("1:/chaos/").
cd("1:/chaos/").
createdir("1:/chaos/modules/").
createdir("1:/chaos/libraries/").
createdir("1:/chaos/programs/").

copypath("0:/chaos/chaosinit", "1:/chaos/chaosinit").
copypath("0:/chaos/chaosinit", "1:/boot/").


local loaded is makeStartupGUI().
copyModules(loaded[0]).
copyLibraries(loaded[1]).

cd("1:/chaos/").
set core:bootfilename to "chaosinit.ks".
wait 0.
run chaosinit.


function makeStartupGUI {
	local gui is gui(500).
	gui:show().

	local continue is false.

	local header is gui:addhlayout().
	header:addlabel("<size=30><b>chaOS</b></size>").
	local cancel is header:addbutton("Cancel").
	set cancel:onclick to { gui:dispose(). reboot.}.
	local continuebtn is header:addbutton("Next >").
	set continuebtn:onclick to { set continue to true. }.

	local body is gui:addvbox().

	body:addlabel("Select modules").
	local modulelistbox is body:addvbox().
	local modulebuttons is list().

	for module in getModuleNames {
		local currentCheckBox is modulelistbox:addcheckbox(module:name, true).
		if module:protected set currentCheckBox:enabled to false.
		modulebuttons:add(currentCheckBox).

	}

	body:addlabel("Select libraries").
	local librarylistbox is body:addvbox().
	local librarybuttons is list().

	for library in getLibraryNames {
		local currentCheckBox is librarylistbox:addcheckbox(library:name, true).
		if library:protected set currentCheckBox:enabled to false.
		librarybuttons:add(currentCheckBox).

	}

	wait until continue.

	local modules is lexicon().
	for opmodule in modulebuttons {
		modules:add(opmodule:text, opmodule:pressed).
	}
	print  modules.

	local libraries is lexicon().
	for library in librarybuttons {
		libraries:add(library:text, library:pressed).
	}

	gui:dispose().

	return list(modules,libraries).

}



function getModuleNames {
local modulelist is list().
local modules is list().
cd("0:/chaos/modules/").
list files in modulelist.
for opmodule in modulelist {
	local truncmodule is opmodule:name:split(".ks")[0].
	local protected is false.
	if list("modulemanager", "processmanager", "utilities", "ui"):contains(truncmodule) {
		set protected to true.
	}
	modules:add(lexicon("name", truncmodule, "protected", protected)).
	}
cd("0:/chaos/boot/").
return modules.
}


function copyModules {
parameter modlist.
local modulelist is list().
cd("0:/chaos/modules/").
list files in modulelist.
for opmodule in modulelist {
	local truncmodule is opmodule:name:split(".ks")[0].
		if modlist[truncmodule] {
		copypath("0:/chaos/modules/"+truncmodule, "1:/chaos/modules/").
	}
	}
cd("0:/chaos/boot/").
}


function getLibraryNames {
local librarylist is list().
local libraries is list().
cd("0:/chaos/libraries/").
list files in modulelist.
for oplibrary in modulelist {
	local trunclibrary is oplibrary:name:split(".ks")[0].
	local protected is false.
	if list():contains(trunclibrary) {
		set protected to true.
	}
	libraries:add(lexicon("name", trunclibrary, "protected", protected)).
	}
cd("0:/chaos/boot/").
return libraries.
}


function copyLibraries {
parameter liblist.
local librarylist is list().
cd("0:/chaos/libraries/").
list files in librarylist.
for oplibrary in librarylist {
	local trunclibrary is oplibrary:name:split(".ks")[0].
		if liblist[trunclibrary] {
		copypath("0:/chaos/libraries/"+trunclibrary, "1:/chaos/libraries/").
	}
	}
cd("0:/chaos/boot/").
}