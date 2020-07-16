// ui.ks

global function ui {

	local fulldebug is list().
	local nodebug is list().
	local commandqueue is queue().

	local gui is gui(500, 900).
	gui:hide().

	chaOSconfig:add("debug", true).

	function debug {
		parameter text.
		fulldebug:add(list(time:clock, text)).
		print text.
	}

	function record {
		parameter text.
		fulldebug:add(list(time:clock, text)).
		nodebug:add(list(time:clock, text)).
		print text.
	}

	function makeActiveGUI {
		gui:clear().

		local header is gui:addhlayout().
		header:addlabel("<size=30><b>chaOS</b></size>").
		local quit is header:addbutton("Quit").
		set quit:onclick to { gui:dispose(). set chaOSconfig:quit to true. }.

		local body is gui:addvbox().
		local bodysettings is body:addhlayout().
		local configbtn is bodysettings:addbutton("Config").
		set configbtn:style:width to 100.
		set configbtn:onclick to { module:utilities:raiseWarning("Configuration settings are not available"). }.
		local debugswitch is bodysettings:addcheckbox("Debug", chaOSconfig:debug).
		set debugswitch:ontoggle to { parameter state. set chaOSconfig:debug to state. }.

		local textcontainer is body:addscrollbox().
		set textcontainer:style:height to 650.
		set textcontainer:valways to true.
		local textfield is textcontainer:addtextfield(logToConsole()).
		set textfield:style:width to 440.
		set textfield:enabled to false.


		local commandbox is body:addtextfield("").
		set commandbox:tooltip to "Type a command here...".
		// :onconfirm runs on any gui interaction, so onchange is used.
		set commandbox:onchange to {
			parameter cmd.
			commandqueue:push(cmd).
			set commandbox:text to "".
			module:utilities:raiseWarning("Commands are not yet supported").
		}.


		gui:show().
	}

	function updateActiveGUI {
		set gui:widgets[1]:widgets[1]:widgets[0]:text to logToConsole().
		set gui:widgets[1]:widgets[0]:widgets[1]:pressed to chaOSconfig:debug.
	}

	function logToConsole {
		local out is "".
		if chaOSconfig:debug {
			for i in fulldebug:copy {
				set out to out + i:join(": ") + char(10).
			}
		} else {
			for i in nodebug:copy {
				set out to out + i:join(": ") + char(10).
			}
		}
		return out.
	}

	function onload {
		module:processmanager:spawndaemon(module:utilities:reference("module:ui:updateActiveGUI"), 3).
	}

	return lexicon(
		"fulldebug", fulldebug,
		"nodebug", nodebug,
		"commandqueue", commandqueue,
		"gui", gui,
		"debug", debug@,
		"record", record@,
		"makeActiveGUI", makeActiveGUI@,
		"updateActiveGUI", updateActiveGUI@,
		"onload", onload@
	).
}

global loadingmodule is ui@.