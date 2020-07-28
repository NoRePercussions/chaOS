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
	if stsource:typename = "Lexicon" { lock stval to stsource:delegate(). }
		else if stsource:typename = "UserDelegate" { lock stval to stsource(). }
		else lock stval to stsource.
	lock steering to stval.
}

function releaseSteering { unlock steering. }

function setThrottle {
	parameter throtvar.
	set throtsource to module:utilities:smartType(throtvar).
	if throtsource:typename = "Lexicon" { lock throtval to throtsource:delegate(). }
		else if throtsource:typename = "UserDelegate" { lock throtval to throtsource(). }
		else lock throtval to throtsource.
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