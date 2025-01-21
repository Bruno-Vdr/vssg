module commands

import term

struct Add implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
}

pub fn Add.new() Command {
	return Add{
		name:    'add'
		desc:    'add short desc'
		help:    Add.help()
		arg_min: 8
		arg_max: 8
	}
}

fn Add.help() string {
	return '
	The ${term.yellow('Add')} command creates a new topic in the blog.
	It can span multiple lines.'
}
