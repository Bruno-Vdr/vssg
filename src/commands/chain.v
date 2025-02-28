module commands

import term
import util
import constants as cst

// Chain structure, implementing Command interface.
struct Chain implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Chain Command.
pub fn Chain.new() Command {
	return Chain{
		kind:    .command
		name:    'chain'
		desc:    'Chains different pushes of a same topic together with previous and next links.'
		help:    Chain.help()
		arg_min: 0
		arg_max: 0
		exec:    chain
	}
}

// help give a complete description of the command, including parameters.
fn Chain.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('chain')} string

${term.rgb(255,
		165, 0, 'Warning:')} This command must be launched from within topic directory.

This command will open all pushe from the current topics, and insert (if any) a link to previous and
next push. Its done by patching custom HTML tag in template "${cst.lnk_next_tag}" and "${cst.lnk_prev_tag}".
Order is given by order of push in .topic file.
'
}

// chain command feature are implemented here. The parameters number has been checked before call.
fn chain(p []string) ! {
	if util.where_am_i() in [.blog_dir, .outside] {
		return error('This command must be run from a topic directory.')
	}
}
