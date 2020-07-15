// modulemanager.ks
// chaOS module manager

runoncepath("1:/chaos/modules/processmanager").
global processmanager is processmanager().

// Module processer
// Modules are intended as extensions of the OS
cd("1:/chaos/modules").

local modulelist is list().
list files in modulelist.
for opmodule in modulelist {
	if opmodule <> "modulemanager.ks" and opmodule <> "modulemanager.ksm" {
		local truncmodule is opmodule:name:split(".ks")[0].
		runoncepath(truncmodule).
		local modlex is loadingmodule().
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
	local liblex is { return runoncepath(trunclibrary). }.
	library:add(trunclibrary, liblex).
}

cd("1:/chaos/").