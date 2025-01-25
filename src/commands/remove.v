module commands

import term
import util
	import structures {Topic}
import constants as cst

// Remove structure, implementing Command interface.
struct Remove implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Remove Command.
pub fn Remove.new() Command {
	return Remove{
		name:    'remove'
		desc:    'Remove an entry/push from a topic.'
		help:    Remove.help()
		arg_min: 1
		arg_max: 1
		exec:    remove
	}
}

// help give a complete description of the command, including parameters.
fn Remove.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('remove')} ${term.magenta('id')}

${term.red('Warning:')} This command must be launched from within topic directory.
To get the push\'s ${term.magenta('id')}, just do "${term.green('vssg')} ${term.yellow('show')}"
The remove command deletes a push from a topic:
	-Removes push description from ${cst.topic_file}
	-Regenerates ${cst.pushs_list_filename} with links to push.
	-Print out command to delete remaining directories.

Note: the remove commands only remove push from ${cst.topic_file}. Directory ${cst.push_dir_prefix}xx is
      not delete neither its contained files, subdirectory and images.
'
}

// remove command feature are implemented here. The parameters number has been checked before call.
fn remove(p []string) ! {
	// Load .topic
	mut topics := Topic.load()!
}
