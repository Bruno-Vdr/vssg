module commands

import term

// Help structure, implementing Command interface.
struct Help implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Help Command.
pub fn Help.new() Command {
	return Help{
		kind:    .command
		name:    'help'
		desc:    'Displays help on a specific command.'
		help:    Help.help()
		arg_min: 1
		arg_max: 1
		exec:    help
	}
}

// help give a complete description of the command, including parameters.
fn Help.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('help')} command

The help command displays detailled information about a specific commad.
'
}

// help command feature are implemented here. The parameters number has been checked before call.
fn help(p []string) ! {
	mut cmds := Command.get()
	cmd_name := p[0]
	cm := cmds[cmd_name] or { return error('Cannot get help for unknown command "${cmd_name}".') }
	println('${cm.help}')
}
