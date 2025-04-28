module commands

import term
import util
import constants as cst
import os

// Sync structure, implementing Command interface.
struct Sync implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Sync Command.
pub fn Sync.new() Command {
	return Sync{
		kind:    .command
		name:    'sync'
		desc:    'Synchronizes the local blog with the remote blog. It means publish the blog.'
		help:    Sync.help()
		arg_min: 0
		arg_max: 2
		exec:    sync
	}
}

// help give a complete description of the command, including parameters.
fn Sync.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('sync')} [-bend] [-dry]

The sync command performs a synchronization between local and remote directories:
Source is defined with the env var ${term.yellow(cst.blog_root)}  (set to: ${util.get_blog_root() or {
		term.red('Not set')
	}})
Destination is defined with the env var ${term.yellow(cst.remote_url)}  (set to: ${util.get_remote_url() or {
		term.red('Not set')
	}})

The ${term.gray('-dry')} option prevents command execution, and only prints the rsync command(s).
The ${term.gray('-bend')} option also synchronizes the redirection file ${term.blue(cst.blog_entry_filename)} in blog root\'s directory, updated by ${term.yellow('bend')} command.

Permanent or additional option(s) can be set using environment variable ${term.yellow(cst.rsync_permanent_option)} e.g.  "-e \'ssh -p 2223\'" to specify
a different SSH port with rsync under sync command.
'
}

// sync command feature are implemented here. The parameters number has been checked before call.
// This operation is related to current directory in the blog. On blog's root, the full blog will be sync.
// From within a directory, only this subdirectory and recursive will be synced.
fn sync(p []string) ! {
	dry := '-dry' in p
	sync_bend := '-bend' in p

	if p.len == 2 {
		if !dry || !sync_bend {
			return error('Malformed option: only "-bend" and "-dry" are allowed.')
		}
	}

	if p.len == 1 {
		if !dry && !sync_bend {
			return error('Malformed option: only "-bend" and "-dry" are allowed.')
		}
	}

	url := util.get_remote_url() or {
		return error('${cst.remote_url} environment variable not set.')
	}
	abs_path := util.get_blog_root() or {
		return error('${cst.blog_root} environment variable not set.')
	}
	cwd := os.getwd() // get current working directory.

	if !cwd.starts_with(abs_path) {
		return error("Trying to sync blog from outside blog's directories.")
	}

	sub_dir, msg := if cwd.len > abs_path.len {
		cwd.substr(abs_path.len, cwd.len), 'Operation: ${term.green('Syncing sub-directory.')}'
	} else {
		'', 'Operation: ${term.green('Syncing complete blog.')}'
	}
	println('${msg}')

	permanent_opt := util.get_sync_opt() or { '' }

	// Trailing '/' is required to sync the whole directory.
	cmd := '${cst.rsync_cmd_opt}  ${permanent_opt} ${cwd}${os.path_separator} ${url}${sub_dir}' //
	run_sync_cmd(cmd, dry)!
	if sync_bend {
		// Also synchronize blog entrance  redirection.
		Sync.sync_file(abs_path + '/' + cst.blog_entry_filename, url, dry)!
	}
	println('${msg} : Done.')
}

fn Sync.sync_file(src string, dst string, dry bool) ! {
	permanent_opt := util.get_sync_opt() or { '' }
	cmd := cst.rsync_single_file + ' ${permanent_opt} ${src} ${dst}'
	util.exec(cmd, true, dry)!
}

// run_sync_cmd Launch the rsync command
fn run_sync_cmd(cmd string, dry bool) ! {
	util.exec(cmd, true, dry)!
}
