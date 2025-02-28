module commands

import term
import util

// Obfuscate structure, implementing Command interface.
struct Obfuscate implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Obfuscate Command.
pub fn Obfuscate.new() Command {
	return Obfuscate{
		kind:    .helper
		name:    'obfuscate'
		desc:    'Obfuscate (hash) the given string.'
		help:    Obfuscate.help()
		arg_min: 1
		arg_max: 1
		exec:    obfuscate
	}
}

// help give a complete description of the command, including parameters.
fn Obfuscate.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('obfuscate')} string

The obfuscate command applies obfuscation function (hash) over the given string. It allows
to retrieve topics mangled named.
e.g. ${term.green('vssg')} ${term.yellow('obfuscate')} vssg will return "${util.obfuscate('vssg')}"
'
}

// obfuscate command feature are implemented here. The parameters number has been checked before call.
fn obfuscate(p []string) ! {
	println('Obfuscated "${term.yellow(p[0])}"  is "${term.bright_blue(util.obfuscate(p[0]))}".')
}
