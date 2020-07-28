// chaosboot.ks

if not exists("1:/chaos/") createdir("1:/chaos/").
cd("1:/chaos/").
if not exists("1:/chaos/modules/") createdir("1:/chaos/modules/").
if not exists("1:/chaos/libraries/") createdir("1:/chaos/libraries/").
if not exists("1:/chaos/programs/") createdir("1:/chaos/programs/").

local sourcedir is "0:/chaos/".
local loaded is makeStartupGUI().
copyModules(loaded[0]).
copyLibraries(loaded[1]).

copypath(sourcedir + "chaosinit", "1:/chaos/chaosinit").
copypath(sourcedir + "chaosinit", "1:/boot/").

cd("1:/chaos/").
set core:bootfilename to "chaos/chaosinit.ks".
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

	local modebody is gui:addvbox().
		local useUncompiledBox is modebody:addradiobutton("Uncompiled (larger but editable)", true).
		local useCompiledBox is modebody:addradiobutton("Compiled (smaller but uneditable)", false).

	if not exists("0:/chaos/") {
		useUncompiledBox:hide().
	}

	if not exists("0:/chaos_compiled/") {
		useCompiledBox:hide().
	}

	local selectbody is gui:addvbox().

	selectbody:addlabel("Select modules").
	local ucmodulelistbox is selectbody:addvbox().
	local ucmodulebuttons is list().

	for module in getUCModuleNames {
		local currentCheckBox is ucmodulelistbox:addcheckbox(module:name, true).
		if module:protected set currentCheckBox:enabled to false.
		ucmodulebuttons:add(currentCheckBox).

	}
	local cmodulelistbox is selectbody:addvbox().
	local cmodulebuttons is list().
	cmodulelistbox:hide().

	for module in getCModuleNames {
		local currentCheckBox is cmodulelistbox:addcheckbox(module:name, true).
		if module:protected set currentCheckBox:enabled to false.
		cmodulebuttons:add(currentCheckBox).

	}

	selectbody:addlabel("Select libraries").
	local uclibrarylistbox is selectbody:addvbox().
	local uclibrarybuttons is list().

	for library in getUCLibraryNames {
		local currentCheckBox is uclibrarylistbox:addcheckbox(library:name, true).
		if library:protected set currentCheckBox:enabled to false.
		uclibrarybuttons:add(currentCheckBox).

	}
	local clibrarylistbox is selectbody:addvbox().
	local clibrarybuttons is list().
	clibrarylistbox:hide().

	for library in getCLibraryNames {
		local currentCheckBox is clibrarylistbox:addcheckbox(library:name, true).
		if library:protected set currentCheckBox:enabled to false.
		clibrarybuttons:add(currentCheckBox).

	}

	set useCompiledBox:ontoggle to {
		parameter state.
		if state { ucmodulelistbox:hide(). uclibrarylistbox:hide().
			cmodulelistbox:show(). clibrarylistbox:show().}.}.

	set useUncompiledBox:ontoggle to {
		parameter state.
		if state { cmodulelistbox:hide(). clibrarylistbox:hide().
			ucmodulelistbox:show(). uclibrarylistbox:show().}.}.

	wait until continue.

	if useCompiledBox:pressed {
		set sourcedir to "0:/chaos_compiled/".
	}

	local modules is lexicon().
	local libraries is lexicon().

	if useCompiledBox:pressed {
	for opmodule in cmodulebuttons {
		modules:add(opmodule:text, opmodule:pressed).
	}
	print  modules.

	for library in clibrarybuttons {
		libraries:add(library:text, library:pressed).
	}
	} else {
	for opmodule in ucmodulebuttons {
		modules:add(opmodule:text, opmodule:pressed).
	}
	print  modules.

	for library in uclibrarybuttons {
		libraries:add(library:text, library:pressed).
	}
	}

	gui:dispose().

	return list(modules,libraries).

}



function getUCModuleNames {
local modulelist is list().
local modules is list().
if not exists("0:/chaos/modules/") return list().
cd("0:/chaos/modules/").
list files in modulelist.
for opmodule in modulelist {
	local truncmodule is opmodule:name:split(".ks")[0].
	local protected is false.
	if list("modulemanager", "processmanager", "utilities", "ui", "savestate", "commandline", "control")
		:contains(truncmodule) {
		set protected to true.
	}
	modules:add(lexicon("name", truncmodule, "protected", protected)).
	}
return modules.
}

function getCModuleNames {
local modulelist is list().
local modules is list().
if not exists("0:/chaos_compiled/modules/") return list().
cd("0:/chaos_compiled/modules/").
list files in modulelist.
for opmodule in modulelist {
	local truncmodule is opmodule:name:split(".ks")[0].
	local protected is false.
	if list("modulemanager", "processmanager", "utilities", "ui", "savestate", "commandline", "control")
		:contains(truncmodule) {
		set protected to true.
	}
	modules:add(lexicon("name", truncmodule, "protected", protected)).
	}
return modules.
}


function copyModules {
parameter modlist.
local modulelist is list().
cd(sourcedir + "modules/").
list files in modulelist.
for opmodule in modulelist {
	local truncmodule is opmodule:name:split(".ks")[0].
		if modlist[truncmodule] {
		copypath(sourcedir + "modules/"+truncmodule, "1:/chaos/modules/").
	}
	}
cd(sourcedir + "boot/").
}


function getUCLibraryNames {
local librarylist is list().
local libraries is list().
if not exists("0:/chaos/libraries/") return list().
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
return libraries.
}

function getCLibraryNames {
local librarylist is list().
local libraries is list().
if not exists("0:/chaos_compiled/libraries/") return list().
cd("0:/chaos_compiled/libraries/").
list files in modulelist.
for oplibrary in modulelist {
	local trunclibrary is oplibrary:name:split(".ks")[0].
	local protected is false.
	if list():contains(trunclibrary) {
		set protected to true.
	}
	libraries:add(lexicon("name", trunclibrary, "protected", protected)).
	}
return libraries.
}


function copyLibraries {
parameter liblist.
local librarylist is list().
cd(sourcedir + "libraries/").
list files in librarylist.
for oplibrary in librarylist {
	local trunclibrary is oplibrary:name:split(".ks")[0].
		if liblist[trunclibrary] {
		copypath(sourcedir + "libraries/"+trunclibrary, "1:/chaos/libraries/").
	}
	}
cd(sourcedir + "boot/").
}