// ui.ks

global function ui {

	local fulldebug is list().
	local nodebug is list().
	local commandqueue is queue().
	local logupdated is true.

	local configwidgets is list().

	local guimode is "boot".
	local gui is gui(500, 750).
	gui:hide().

	chaOSconfig:add("debug", true).

	function debug {
		parameter text.
		set logupdated to true.
		fulldebug:add(list(time:clock, text)).
		print text.
	}

	function record {
		parameter text.
		set logupdated to true.
		fulldebug:add(list(time:clock, text)).
		nodebug:add(list(time:clock, text)).
		print text.
	}

	function makeActiveGUI {
		gui:clear().

		set guimode to "active".

		local header is gui:addhlayout().
		header:addlabel("<size=30><b>chaOS</b></size>").
		local quit is header:addbutton("Quit").
		set quit:onclick to { gui:dispose(). set chaOSconfig:quit to true. }.

		local body is gui:addvbox().
		local bodysettings is body:addhlayout().
		local configbtn is bodysettings:addbutton("Config").
		set configbtn:style:width to 100.
		set configbtn:onclick to { makeConfigGUI(). }.
		local debugswitch is bodysettings:addcheckbox("Debug", chaOSconfig:debug).
		set debugswitch:ontoggle to { parameter state. set chaOSconfig:debug to state. set logupdated to true. }.

		local textcontainer is body:addscrollbox().
		local textfield is textcontainer:addtextfield(logToConsole()).
		set textfield:style:width to 440.
		set textfield:enabled to false.

		//for i in range(40) {textcontainer:addlabel("test label").}.

		local commandbox is body:addtextfield("").
		set commandbox:tooltip to "Type a command here...".
		// :onconfirm runs on any gui interaction, so onchange is used.
		set nextdebouncetime to time:seconds + 0.2.
		set commandbox:onconfirm to {
			parameter cmd.
			if cmd:length = 0 or time:seconds < nextdebouncetime return.
			set nextdebouncetime to time:seconds + 0.2.
			commandqueue:push(cmd).
			set commandbox:text to "".
			module:utilities:raiseWarning("Commands are not yet supported").
		}.


		gui:show().
	}

	function updateActiveGUI {
		if logupdated and guimode = "active" {
			set gui:widgets[1]:widgets[1]:widgets[0]:text to logToConsole().
			set logupdated to false.
			set gui:widgets[1]:widgets[0]:widgets[1]:pressed to chaOSconfig:debug.
		}
	}

	function makeConfigGUI {
		gui:clear().

		set guimode to "config".

		local header is gui:addhlayout().
		header:addlabel("<size=30><b>chaOS Config</b></size>").
		local back is header:addbutton("Back").
		set back:onclick to { makeActiveGUI(). }.

		local body is gui:addvbox().

		local debugswitch is body:addcheckbox("Debug Mode", chaOSconfig:debug).
		set debugswitch:ontoggle to { parameter state. set chaOSconfig:debug to state. set logupdated to true. }.


		for widget in configwidgets {
			widget(body).
		}
	}

	function addConfigWidget {
		parameter widget.
		configwidgets:add(widget@).
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
		module:processmanager:spawndaemon(module:utilities:reference("module:ui:updateActiveGUI"), 3, list(), 1/5).
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
		"addConfigWidget", addConfigWidget@,
		"onload", onload@
	).
}

global loadingmodule is ui@.