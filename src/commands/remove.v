module commands

import term
import structures { Topic }
import constants as cst
import strconv
import os

// Remove structure, implementing Command interface.
struct Remove implements Command {
	kind       CommandType
	validity   RunFrom
	run_locked bool
	name       string
	desc       string
	help       string
	arg_min    int
	arg_max    int
	exec       fn (s []string) ! @[required]
}

// new builds a Remove Command.
pub fn Remove.new() Command {
	return Remove{
		kind:       .command
		validity:   .topic_dir
		run_locked: false
		name:       'remove'
		desc:       'Removes an entry/push from a topic.'
		help:       Remove.help()
		arg_min:    1
		arg_max:    2
		exec:       remove
	}
}

// help give a complete description of the command, including parameters.
fn Remove.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('remove')} ${term.magenta('id')} [-f]

${term.rgb(255,
		165, 0, 'Warning:')} This command must be launched from within topic directory.
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
	mut id_str := ''

	if param.len == 2 {
		if '-f' in param {
			force_delete = true
		} else {
			return error('Unknown parameter "${param[0]}" or "${param[1]}".')
		}
		id_str = if param[0] == '-f' { param[1] } else { param[0] }
	} else { // param.len is 2
		id_str = param[0]
	}

	id := strconv.atou64(id_str) or { return error('Cannot convert "${id_str}" to unsigned ID.') }

	// Load .topic
	mut topics := Topic.load()!
	if v := topics.get_post(id) {
		println('Deleting push ${id} "${v.title}."')
		dir := v.dir
		topics.delete(id)!
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
		println('You can now use "${term.green('vssg')} ${term.yellow('sync')}" to publish or "${term.green('vssg')} ${term.yellow('chain')}" to updates links.')
		println('Please also considere using "${term.green('vssg')} ${term.yellow('bend')}" to a valid URL (drop might break bend).')
	} else {
		return error('Push with id=${id} was not found. Entry NOT deleted.')
	}
}
