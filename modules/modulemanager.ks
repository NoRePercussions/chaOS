// modulemanager.ks
// chaOS module manager

runoncepath("1:/chaos/modules/processmanager").
global processmanager is processmanager().

// Module processer
// Modules are intended as extensions of the OS
cd("1:/chaos/modules").

set loadinglibrary to {return lexicon().}.

local loadqueue is queue(mm_onload@).

local modulelist is list().
list files in modulelist.
for opmodule in modulelist {
	if opmodule <> "modulemanager.ks" and opmodule <> "modulemanager.ksm" {
		local truncmodule is opmodule:name:split(".ks")[0].
		runoncepath(truncmodule).
		local modlex is loadingmodule().
		if modlex:haskey("onload") { loadqueue:push(modlex:onload@). }.
		module:add(truncmodule, modlex).
	}
}

// Library processer
// Libraries are addons of code snippets that do not directly relate to chaOS
cd("1:/chaos/libraries").

local liblist is list().
list files in liblist.
for lib in liblist {
	local trunclibrary is lib:name:split(".ks")[0].
	runoncepath(trunclibrary).
	local liblex is loadinglibrary().
	if liblex:haskey("onload") { loadqueue:push(modlex:onload@). }.
	library:add(trunclibrary, liblex).
}

cd("1:/chaos/").

for loadscript in loadqueue {
	loadscript().
}

function mm_onload {
	module:ui:addConfigWidget({
		parameter body. local reloadswitch is body:addbutton("Reload Modules").
	}).
}