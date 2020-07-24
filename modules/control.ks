// control.ks
// Throttle and Steering control handler

function control {

global stsource is up:vector.
local stval is stsource.
global throtsource is 0.
local throtval is throtsource.

function setSteering {
	parameter stvar.
	set stsource to module:utilities:smartType(stvar).
	if stvar:typename = "Lexicon" { lock stval to stvar:delegate(). }
		else if stvar:typename = "UserDelegate" { lock stval to stvar(). }
		else lock stval to stvar.
	lock steering to stval.
}

function releaseSteering { unlock steering. }

function setThrottle {
	parameter throtvar.
	set throtsource to module:utilities:smartType(throtvar).
	if throtvar:typename = "Lexicon" { lock throtval to throtvar:delegate(). }
		else if throtvar:typename = "UserDelegate" { lock throtval to throtvar(). }
		else lock throtval to throtvar.
	lock throttle to throtval.
}

function releaseThrottle { unlock throttle. }

local self is lexicon (
	"setSteering", setSteering@,
	"releaseSteering", releaseSteering@,
	"setThrottle", setThrottle@,
	"releaseThrottle", releaseThrottle@
).

return self.

}

set loadingmodule to control@.