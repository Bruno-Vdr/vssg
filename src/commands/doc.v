module commands

import term

// Doc structure, implementing Command interface.
struct Doc implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Doc Command.
pub fn Doc.new() Command {
	return Doc{
		kind:    .helper
		name:    'doc'
		desc:    'Displays the whole vssg documentation (all commands).'
		help:    Doc.help()
		arg_min: 0
		arg_max: 0
		exec:    doc
	}
}

// help give a complete description of the command, including parameters.
fn Doc.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('doc')}

The doc command displays all commands documentation.
'
}

// doc command feature are implemented here. The parameters number has been checked before call.
fn doc(p []string) ! {
	println("vssg's commands documentation:\n")

	mut cmds := Command.get()
	for _, c in cmds {
		println(c.help)
		println('________________________________________________________________________________')
	}
}
