local topics = {}

topics['help'] = [[help ( topic )
Displays help for a particular topic, or lists all available topics.
]]

topics['usage'] = [[
Command-Line Interface (CLI)

Basic Usage:
    - Press enter to gain focus on the CLI.
    - Type in some Lua and press enter to run it.
    - Press escape to lose focus.
    - Press home and end to navigate input history.
    - Use the "help" function for help.

Persisting Environment:
    - Use the pattern `foo = bar` to add a value to the persisting environment.
        - This will add the entire input to a list that will be evaluated each time the CLI initializes.
        - This also sets "foo" as a variable as usual.
    - Use the pattern `foo = nil` to remove the value from the persisting environment.
        - Must be "nil" exactly, not just a value that happens to be nil.
    - Use `recall('foo')` to recall the input of "foo".
    - A table of these variables and their inputs is available in `cli.init`.
]]

topics['recall'] = [[recall ( name )
Recalls the input of 'name' in the persisting environment.
If 'name' is not given, then all existing variables will be listed.
]]

topics['cli'] = [[cli
A table containing values directly related to the CLI.
]]

topics['cli.version'] = [[version
A string representing the current version of the CLI.
]]

topics['cli.init'] = [[init
A table containing values stored in the persisting environment.
]]

topics['cli.history'] = [[history
A table containing the current input history.
]]

topics['cli.settings'] = [[settings
Settings for the CLI.
]]

topics['settings.autoHide'] = [[autoHide
Sets whether the CLI will hide itself when not in use.
Defaults to true.
]]

topics['settings.historySave'] = [[historySave
Sets whether input history will save between sessions.
Defaults to false.
]]

topics['settings.historySize'] = [[historySize
Sets the amount of inputs that will be saved in the input history.
Defaults to 32.
]]

topics['settings.keybind'] = [[keybind
A table of key bindings.
]]

topics['settings.keybind.focus'] = [[focus
The key used to bring focus to the CLI.
Defaults to the enter key.
]]

topics['settings.keybind.previous'] = [[previous
The key used to move to the previous item in the command history.
Defaults to the home key.
]]

topics['settings.keybind.next'] = [[next
The key used to move to the next item in the command history.
Defaults to the end key.
]]

return function(topic)
	if topics[topic] then
		print(topics[topic])
	else
		print('Help Topics:')
		local sorted = {}
		for k in pairs(topics) do
			sorted[#sorted+1] = k
		end
		table.sort(sorted)
		for i = 1,#sorted do
			print('  - `' .. tostring(sorted[i]) .. '`')
		end
	end
end
