// modulemanager.ks
// chaOS module manager

global loadingmodule is {}.

global module is lexicon().
global library is lexicon().

// Module processer
// Modules are intended as extensions of the OS
cd("1:/chaos/modules").

set loadinglibrary to lexicon().

local loadqueue is queue(mmonload@).

local modulelist is list().
list files in modulelist.
for m in range(modulelist:length) {
	if modulelist[m] <> "modulemanager.ks" and modulelist[m] <> "modulemanager.ksm" {
		local truncmodule is modulelist[m]:name:split(".ks")[0].
		if modulelist:contains(truncmodule) = false {
			runoncepath(truncmodule).
			local modlex is loadingmodule().
			if modlex:haskey("onload") { loadqueue:push(modlex:onload@). }.
			module:add(truncmodule, modlex).
			set modulelist[m] to truncmodule.
		} else set modulelist[m] to "".
	}
}


// Library processer
// Libraries are addons of code snippets that do not directly relate to chaOS
cd("1:/chaos/libraries").

local liblist is list().
list files in liblist.
for l in range(liblist:length) {
	local trunclibrary is liblist[l]:name:split(".ks")[0].
	if liblist:contains(trunclibrary) = false {
		runoncepath(trunclibrary).
		local liblex is loadinglibrary.
		if liblex:haskey("onload") { loadqueue:push(modlex:onload@). }.
		library:add(trunclibrary, liblex).
		set liblist[l] to trunclibrary.
	} else set liblist[l] to "".
}

cd("1:/chaos/").

for loadscript in loadqueue {
	loadscript().
}

function mmonload {
	module:ui:addConfigWidget({
		parameter body. local reloadswitch is body:addbutton("Reload Modules").
	}).
}