module commands

import term

struct Init implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
}

pub fn Init.new() Command {
	return Init{
		name:    'init'
		desc:    'short desc'
		help:    Init.help()
		arg_min: 1
		arg_max: 1
	}
}

// help give a complete description of the command, including parameters.
fn Init.help() string {
	return '
	The ${term.yellow('init')} command initializes a new blog.
	It can span multiple lines.'
}
