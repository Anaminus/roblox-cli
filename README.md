# Command-Line Interface (CLI)

Creates an enhanced command-line interface for the ROBLOX Studio.

## Usage

Basic usage:

- Press enter to gain focus on the CLI.
- Type in some Lua and press enter to run it.
- Press escape to lose focus.
- Press home and end to navigate input history.
- Use the "help" function for further help.

### Persisting Environment

- Use the pattern `foo = bar` to add a value to the persisting environment.
	- This will add the entire input to a list that will be evaluated each
      time the CLI initializes.
	- This also sets "foo" as a variable as usual.
- Use the pattern `foo = nil` to remove the value from the persisting
  environment.
	- Must be "nil" exactly, not just a value that happens to be nil.
- Use `recall('foo')` to recall the input of "foo".
- A table of these variables and their inputs is available in `cli.init`.

## Installation

To build this plugin from source, do the following:

- Download or install [rbxplugin](https://github.com/Anaminus/rbxplugin)
- In the roblox-cli directory, run `rbxplugin --build -i plugin -o cli.rbxm`
