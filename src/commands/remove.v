module commands

import term
import structures { Topic }
import constants as cst
import strconv
import os

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
		desc:    'Removes an entry/push from a topic.'
		help:    Remove.help()
		arg_min: 1
		arg_max: 2
		exec:    remove
	}
}

// help give a complete description of the command, including parameters.
fn Remove.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('remove')} ${term.magenta('id')} [-f]

${term.red('Warning:')} This command must be launched from within topic directory.
To get the push\'s ${term.magenta('id')}, just do "${term.green('vssg')} ${term.yellow('show')}"
The remove command deletes a push from a topic:
	-Removes push description from ${cst.topic_file}
	-Regenerates ${cst.pushs_list_filename} with links to push.
	-Print out command to delete remaining directories.

Note: the remove commands only remove push from ${cst.topic_file}. Directory ${cst.push_dir_prefix} is
      not delete neither its contained files, subdirectory and images, its suffixed with ${cst.dir_removed_suffix}
      UNLESS ${term.red('-f')} is passed on the command line.
'
}

// remove command feature are implemented here. The parameters number has been checked before call.
fn remove(param []string) ! {
	mut force_delete := false
	id := strconv.parse_uint(param[0], 10, 64) or {
		return error('Cannot convert "${param[0]}" to unsigned ID.')
	} // int

	if param.len == 2 {
		if param[1] == '-f' {
			force_delete = true
		} else {
			return error('Unknown parameter "${param[1]}".')
		}
	}

	// Load .topic
	mut topics := Topic.load()!
	if v := topics.posts[id] {
		println('Deleting push ${id} "${v.title}."')
		dir := v.dir
		topics.posts.delete(id)
		topics.save('./')!

		if force_delete {
			os.rmdir_all(dir) or { return error('Unable to rmdir ${dir}. ${err}. ${@LOCATION}.') }
			println('Removed ${term.blue(dir)} directory.')
		} else {
			// Move push directory to __directory
			os.mv(dir, '${dir}${cst.dir_removed_suffix}') or {
				return error('Unable to mv ${dir} to ${dir}${cst.dir_removed_suffix}. ${err}. ${@LOCATION}.')
			}
			println('renaming push directory ${term.blue('${dir}')} to ${term.blue('${dir}${cst.dir_removed_suffix}')}')
			println('You can remove all attached push data by doing "rm -rf ${dir}${cst.dir_removed_suffix}"}')
		}

		// Rebuilt HTML topic list
		topics.generate_pushes_list_html()!
		println('Re-generated pushes links in (${cst.pushs_list_filename}).')
	} else {
		return error('Push with id=${id} was not found. Entry NOT deleted.')
	}
}
