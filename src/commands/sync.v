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
		arg_max: 1
		exec:    sync
	}
}

// help give a complete description of the command, including parameters.
fn Sync.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('sync')} [option]

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

Permanent option can be set using environment variable ${term.yellow(cst.rsync_permanent_option)} e.g.  "-e \'ssh -p 2223\'" to specify
a different SSH port with rsync under sync command.
'
}

// sync command feature are implemented here. The parameters number has been checked before call.
// This operation is related to current directory in the blog. On blog's root, the full blog will be sync.
// From within a directory, only this subdirectory and recursive will be synced.
fn sync(p []string) ! {
	options := if p.len == 1 {
		if p[0].starts_with('-') {
			' ' + p[0]
		} else {
			return error('Malformed option "${term.gray(p[0])}". Additional sync option must start with   "-". ')
		}
	} else {
		''
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
	run_sync_cmd(cmd)!
	println('${msg} : Done.')
}

fn Sync.sync_file(src string, dst string) ! {
	permanent_opt := util.get_sync_opt() or { '' }
	cmd := cst.rsync_single_file + ' ${permanent_opt} ${src} ${dst}'
	println('${cmd}')
	return run_sync_cmd(cmd)
}

// run_sync_cmd Launch the rsync command
fn run_sync_cmd(cmd string) ! {
	ret := os.execute(cmd)
	// now check that rsync is installed on the system.
	if ret.exit_code < 0 {
		return error('${ret.output} : error code =  ${ret.exit_code}. ${@LOCATION}')
	} else {
		if ret.exit_code == 127 { // Command not found
			return error('rsync command not found. Is rsync installed and in your \$PATH ? ${@FILE_LINE}')
		} else {
			if ret.exit_code == 0 {
				println('rsync command successful:')
				println(term.bright_green('${ret.output}'))
			} else {
				// An error occurs´
				return error('rsync returns ${ret.exit_code} :\n' + term.red(ret.output) +
					'\nCheck rsync return code for more information. ${@FILE_LINE}')
			}
		}
	}
}
