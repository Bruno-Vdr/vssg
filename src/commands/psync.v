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
		desc:       'Partial synchronization of the blog.'
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

The psync performs a partial synchronization.

Without directory specification, only the files in the current directory are synchronized (no directory).
If a directory is specified, then only this directory is recursively synchronized (no local files).

The ${term.gray('-dry')} option prevents command execution, and only prints the rsync command(s).
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
		// Directory is specified, sync the directory only.
		if dry {
			println('Dry-run: ${term.yellow(cmd)}')
		} else {
			util.exec(cmd, true, false)!
		}
	}
}
