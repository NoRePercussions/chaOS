// ui.ks

global function ui {

	local fulldebug is list().
	local nodebug is list().
	local logupdated is true.

	local configwidgets is list().

	local guimode is "boot".
	local gui is gui(500, 750).
	gui:hide().

	chaOSconfig:add("debug", true).

	function debug {
		parameter text, posttext is "".
		local recordtext is "".
		set logupdated to true.
		if posttext:length = 0 { set recordtext to time:clock + ": " + text. }
		else { set recordtext to text + time:clock + ": " +  posttext. }.
		fulldebug:add(recordtext).
		print text.
	}

	function record {
		parameter text, posttext is "".
		local recordtext is "".
		set logupdated to true.
		if posttext:length = 0 { set recordtext to time:clock + ": " + text. }
		else { set recordtext to text + time:clock + ": " +  posttext. }.
		fulldebug:add(recordtext).
		nodebug:add(recordtext).
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
		//set textfield:style:width to 440.
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
			module:commandline:addCommandToQueue(cmd).
			set commandbox:text to "".
		}.


		gui:show().
	}

	function updateActiveGUI {
		if logupdated and guimode = "active" {
			set gui:widgets[1]:widgets[1]:widgets[0]:text to logToConsole().
			set logupdated to false.
			set gui:widgets[1]:widgets[0]:widgets[1]:pressed to chaOSconfig:debug.
			gui:widgets[1]:widgets[0]:widgets[1]:show().
		}
	}

	function enterEditMode {
		parameter filename.
		set opfile to open(filename).

		set guimode to "edit".

		set gui:widgets[1]:widgets[1]:widgets[0]:text to opfile:readall():string.
		set gui:widgets[1]:widgets[1]:widgets[0]:enabled to true.

		gui:widgets[1]:widgets[0]:widgets[1]:hide(). // Hide debug checklist
		gui:widgets[1]:widgets[2]:dispose(). // Remove command box

		local editsettings is gui:widgets[1]:addhlayout().
		local save is editsettings:addbutton("Save").
		local quit is editsettings:addbutton("Quit").

		set save:onclick to { opfile:clear. opfile:write(gui:widgets[1]:widgets[1]:widgets[0]:text). }.
		set quit:onclick to {
			local confirmgui is gui(200). confirmgui:show().
			local savelabel is confirmgui:addlabel("Save file?").
			local savebtn is confirmgui:addbutton("Save").
			set savebtn:onclick to { opfile:clear. opfile:write(gui:widgets[1]:widgets[1]:widgets[0]:text).
				confirmgui:dispose(). makeActiveGUI(). }.
			local nosavebtn is confirmgui:addbutton("Don't Save").
			set nosavebtn:onclick to { confirmgui:dispose(). makeActiveGUI(). }.
			local cancelbtn is confirmgui:addbutton("Cancel").
			set cancelbtn:onclick to { confirmgui:dispose(). }.
		}.
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
			for line in fulldebug:copy {
				set out to out + truncateConsoleText(line) + char(10).
			}
		} else {
			for line in nodebug:copy {
				set out to out + truncateConsoleText(line) + char(10).
			}
		}
		return out.
	}

	function truncateConsoleText {
		parameter text.
		local lines is text:split(char(10)).
		local out is list().
		for line in lines {
			local lineout is list().
			until line:length = 0 {
				lineout:add(line:substring(0, min(line:length, 70))).
				set line to line:remove(0, min(line:length, 70)).
			}
			out:add(lineout:join(char(10))).
		}

		return out:join(char(10)).
	}

	function onload {
		module:processmanager:spawndaemon(module:utilities:reference("module:ui:updateActiveGUI"), 3, list(), 1/5).
	}

	return lexicon(
		"fulldebug", fulldebug,
		"nodebug", nodebug,
		"gui", gui,
		"debug", debug@,
		"record", record@,
		"makeActiveGUI", makeActiveGUI@,
		"updateActiveGUI", updateActiveGUI@,
		"addConfigWidget", addConfigWidget@,
		"enterEditMode", enterEditMode@,
		"onload", onload@
	).
}

global loadingmodule is ui@.