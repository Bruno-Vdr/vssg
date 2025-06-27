module commands

import term
import os
import util
import constants as cst

// Psync structure, implementing Command interface.
struct PSync implements Command {
	kind       CommandType
	validity   RunFrom
	run_locked bool
	name       string
	desc       string
	help       string
	arg_min    int
	arg_max    int
	exec       fn (s []string, rl bool) ! @[required]
}

// new builds a Psync Command.
pub fn PSync.new() Command {
	return PSync{
		kind:       .command
		validity:   .blog_or_topic_dir
		run_locked: true
		name:       'psync'
		desc:       'Partial synchronization of the local files or specific directory.'
		help:       PSync.help()
		arg_min:    0
		arg_max:    2
		exec:       psync
	}
}

// psync give a complete description of the command, including parameters.
fn PSync.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('psync')} [${term.gray('-dry')}] [${term.blue('directory')}] command

The psync performs a partial synchronization. This command allow to sync specific file or directory unlike sync
command, that sync everything. This command is usefull when blog size becomes high, and performs blog update only
on the modified part, avoiding change checks of all topics/pushes.

Without directory specification, only the files in the current directory are synchronized (no directory).
If a directory is specified, then only this directory is recursively synchronized (no local files).

The ${term.gray('-dry')} option prevents command execution, and only prints the rsync command.

To manually add a Topic, from Blog root\'s directory:

-Do: ${term.green('vssg')} ${term.yellow('add')} Topic
-Do: ${term.green('vssg')} ${term.yellow('psync')}
-Do: ${term.green('vssg')} ${term.yellow('psync')} Topic_dir  (obfuscated name !)

To get obfuscated name of topic just do: ${term.green('vssg')} ${term.yellow('obfuscate')} Topic_name

To manually push a Push, from the topic directory:

-Do: ${term.green('vssg')} ${term.yellow('push')} ${term.blue('Push.txt')}
-Do: ${term.green('vssg')} ${term.yellow('psync')}
-Do: ${term.green('vssg')} ${term.yellow('psync')} push_X (with X the push ID)

${term.rgb(255,
		165, 0, 'Warning:')} Don\'t forget that chain command acts on several directories. using psync on the last push_x dir
could lead to not beeing chained from the push_(X-1). A solution could be to perform psync on last 2 push directories.
If more articles are unchained, just perform a sync or psync on all push_X directories.

'
}

// psync command feature are implemented here. The parameters number has been checked before call.
fn psync(p []string, run_locked bool) ! {
	mut dir := ''
	// location := util.where_am_i()

	// Check command parameters.
	dry := '-dry' in p
	if p.len == 2 {
		if dry == false {
			return error('Wrong command parameters: The 2 params must be -dry and a directory name.')
		} else {
			// the other param should be a directory
			dir = if p[0] == '-dry' { p[1] } else { p[0] }

			// Check that dir is really a directory
			if !os.is_dir(dir) {
				return error('"${dir}" is not a directory.')
			}
		}
	}

	if p.len == 1 && !dry {
		// Check that dir is really a directory
		dir = p[0]
		if !os.is_dir(dir) {
			return error('"${dir}" is not a directory.')
		}
	}

	// Now do the work !
	cwd := os.getwd() + os.path_separator
	abs_path := util.get_blog_root() or {
		return error('${cst.blog_root} environment variable not set.')
	}
	permanent_opt := util.get_sync_opt() or { '' }
	url := util.get_remote_url() or {
		return error('${cst.remote_url} environment variable not set.')
	}

	if dir.len == 0 {
		// No directory specified, sync the files only.
		sub_dir := if cwd.len > abs_path.len {
			cwd.substr(abs_path.len, cwd.len)
		} else {
			''
		}
		cmd := '${cst.rsync_files_only} ${permanent_opt} ${cwd} ${url}${sub_dir}'
		println('Syncing all files from current directory, excluding directories.')

		if dry {
			println('Dry-run: ${term.yellow(cmd)}')
		} else {
			util.exec(cmd, true, false)!
		}
	} else {
		// source dir should NOT ends with '/' for rsync command.
		if dir.ends_with('/') {
			dir = dir.substr(0, dir.len - 1)
		}
		sub_dir := if cwd.len > abs_path.len {
			cwd.substr(abs_path.len, cwd.len)
		} else {
			''
		}
		cmd := '${cst.rsync_specific_dir_only} ${permanent_opt} ${cwd}${dir} ${url}${sub_dir}'
		println('Syncing specific directory:${cwd}${dir}')

		// Directory is specified, sync the directory only.
		if dry {
			println('Dry-run: ${term.yellow(cmd)}')
		} else {
			util.exec(cmd, true, false)!
		}
	}
}
