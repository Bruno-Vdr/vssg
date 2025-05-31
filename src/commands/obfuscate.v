module commands

import term
import util

// Obfuscate structure, implementing Command interface.
struct Obfuscate implements Command {
	kind    CommandType
	validity RunFrom
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
		validity: .anywhere
		name:    'obfuscate'
		desc:    'Obfuscates (hash) the given string.'
		help:    Obfuscate.help()
		arg_min: 1
		arg_max: 2
		exec:    obfuscate
	}
}

// help give a complete description of the command, including parameters.
fn Obfuscate.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('obfuscate')} ${term.gray('-s')} string

The obfuscate command applies obfuscation function (hash) over the given string. It allows
to retrieve topics mangled named.
e.g. ${term.green('vssg')} ${term.yellow('obfuscate')} vssg will return "${util.obfuscate('vssg')}"
The ${term.gray('-s')} option (silence) will force output to be the Hash only.
'
}

// obfuscate command feature are implemented here. The parameters number has been checked before call.
fn obfuscate(p []string) ! {
	mut s := p[0]
	silence := '-s' in p
	if p.len == 2 {
		if '-s' !in p {
			return error('Wrong option used. Only -s is allowed with obfuscate command.')
		}

		if p[0] == '-s' {
			s = p[1]
		}
	}
	if silence {
		println(util.obfuscate(s))
	} else {
		println('Obfuscated "${term.yellow(s)}"  is "${term.bright_blue(util.obfuscate(s))}".')
	}
}
