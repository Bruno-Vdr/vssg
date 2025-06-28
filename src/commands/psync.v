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
Command: ${term.green('vssg')} ${term.yellow('psync')} [${term.gray('-dry')}] [${term.blue('directory | file')}] command

The psync performs a partial synchronization. This command allow to sync specific file or directory unlike sync
command, that sync everything. This command is useful when blog size becomes high; it performs blog transfer only
on the specified part, avoiding modification checks (local/remote) of all topics/pushes.

Transfer rules:

  -Without directory specification, all files in the current directory are sent (no directory).
  -If a directory is specified, then only this directory is recursively synchronized (no local files).
  -If a file is specified, then only this file is sent.

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
	mut fname := ''
	mut ptype := util.FileType.neither

	// Check command parameters.
	dry := '-dry' in p
	if p.len == 2 {
		if dry == false {
			return error('Wrong command parameters: The 2 params must be -dry and a directory name.')
		} else {
			// the other param should be a directory
			fname = if p[0] == '-dry' { p[1] } else { p[0] }
			ptype = util.check_type(fname)
			if ptype == .neither {
				return error('"${fname}" is not a directory nor a file.')
			}
		}
	}

	if p.len == 1 && !dry {
		// p[0] should be a dir or file name.
		fname = p[0]
		ptype = util.check_type(fname)
		if ptype == .neither {
			return error('"${fname}" is not a directory nor a file.')
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

	if fname.len == 0 {
		// No directory specified, sync the local files only.
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
		// Directory or a file was specified. sync the directory or file only.
		mut cmd := ''
		sub_dir := if cwd.len > abs_path.len {
			cwd.substr(abs_path.len, cwd.len)
		} else {
			''
		}

		// Remove trailing / on directory name.
		if fname.ends_with('/') {
			fname = fname.substr(0, fname.len - 1)
		}

		// Check that no subdir are specified !
		if fname.contains('/') {
			return error('The "${fname}" parameter cannot contain "${os.path_separator}". Only local file or directory can be used with psync.')
		}

		if ptype == .file {
			cmd = '${cst.rsync_single_file} ${permanent_opt} ${cwd}${fname} ${url}${sub_dir}'
			println('Syncing specific file:${cwd}${fname}')
		} else {
			// source dir should NOT ends with '/' for rsync command.

			cmd = '${cst.rsync_specific_dir_only} ${permanent_opt} ${cwd}${fname} ${url}${sub_dir}'
			println('Syncing specific directory:${cwd}${fname}')
		}

		if dry {
			println('Dry-run: ${term.yellow(cmd)}')
		} else {
			util.exec(cmd, true, false)!
		}
	}
}
