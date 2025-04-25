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
Command: ${term.green('vssg')} ${term.yellow('sync')} [option] [-dry]

The sync command performs a synchronization between locale and remote directories:
Source is defined with the env var ${term.yellow(cst.blog_root)}  (set to: ${util.get_blog_root() or {
		term.red('Not set')
	}})
Destination is defined with the env var ${term.yellow(cst.remote_url)}  (set to: ${util.get_remote_url() or {
		term.red('Not set')
	}})
rsync command is used for this: ${cst.rsync_cmd_opt}${term.gray('[option]')} SRC DST
Options are appended to the command line:
${term.green('vssg')} ${term.yellow('sync')} abc with append abc to the default list of command.
${term.green('vssg')} ${term.yellow('sync')} " --delete --Xxxxx" will add detached options.

The ${term.gray('-dry')} option prevents command execution, and only prints the rsync command.

Permanent option can be set using environment variable ${term.yellow(cst.rsync_permanent_option)} e.g.  "-e \'ssh -p 2223\'" to specify
a different SSH port with rsync under sync command.
'
}

// sync command feature are implemented here. The parameters number has been checked before call.
// This operation is related to current directory in the blog. On blog's root, the full blog will be sync.
// From within a directory, only this subdirectory and recursive will be synced.
fn sync(p []string) ! {
	dry := '-dry' in p
	mut options := ''

	if p.len == 2 {
		if '-dry' !in p {
			return error('Malformed option "${term.gray(p[0])}". Multi options must contain -dry and the other option. ')
		}

		// 2 param determine which is rsync opt (not -dry)
		opt_ind := if p[0] == '-dry' { 1 } else { 0 }
		options = if p[opt_ind].starts_with('-') {
			' ' + p[opt_ind]
		} else {
			return error('Malformed option "${term.gray(p[opt_ind])}". Additional sync option must start with   "-". ')
		}
	}
	if p.len == 1 {
		if !dry {
			options = if p[0].starts_with('-') {
				' ' + p[0]
			} else {
				return error('Malformed option "${term.gray(p[0])}". Additional sync option must start with   "-". ')
			}
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

	// add n for dry run. On source, trailing '/' is required to sync the whole directory.
	cmd := '${cst.rsync_cmd_opt} ${options} ${permanent_opt} ${cwd}${os.path_separator} ${url}${sub_dir}' //
	println('${term.bright_yellow(cst.rsync_cmd_opt)} ${term.gray(options)} ${term.blue(permanent_opt)} ${cwd}${os.path_separator} ${url}${sub_dir}')
	if !dry {
		run_sync_cmd(cmd)!
	} else {
		println('Command skipped (-dry) option.')
	}
	println('${msg} : Done.')
}

fn Sync.sync_file(src string, dst string) ! {
	permanent_opt := util.get_sync_opt() or { '' }
	cmd := cst.rsync_single_file + ' ${permanent_opt} ${src} ${dst}'
	util.exec(cmd, true)!
}

// run_sync_cmd Launch the rsync command
fn run_sync_cmd(cmd string) ! {
	util.exec(cmd, true)!
}
