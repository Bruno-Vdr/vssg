module commands

import term
import util
import constants as cst
import os

// Sync structure, implementing Command interface.
struct Sync implements Command {
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
'
}

// sync command feature are implemented here. The parameters number has been checked before call.
fn sync(p []string) ! {
	options := if p.len == 1 {
		p[0]
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

	println('${cwd}  ${abs_path}')
	if !cwd.starts_with(abs_path) {
		return error("Trying to sync blog from outside blog's directories.")
	}

	to_sync := if cwd.len > abs_path.len {
		println('Syncing directory... ')
		cwd.substr(abs_path.len, cwd.len)
	} else {
		println('Syncing the whole blog...')
		''
	}

	// add n for dry run. Source trailing '/' is required to sync the whole directory.
	cmd_opt := cst.rsync_cmd_opt + options //+ 'n'
	cmd := '${cmd_opt} ${cwd}${os.path_separator} ${url}${to_sync}' //
	println(term.bright_yellow('${cmd}'))

	ret := os.execute(cmd)
	// now check that rsync is installed on the system.
	if ret.exit_code < 0 {
		return error('${ret.output} : error code =  ${ret.exit_code}. ${@LOCATION}')
	} else {
		if ret.exit_code == 127 {
			return error('rsync command not found. Is rsync installed and in your \$PATH ? ${@FILE_LINE}')
		} else {
			if ret.exit_code == 0 {
				println('rsync command successful.')
				println(term.bright_green('${ret.output}'))
			} else {
				// An error occurs´
				return error('rsync returns ${ret.exit_code} -> ' + ret.output +
					'\nCheck rsync return code for more information. ${@FILE_LINE}')
			}
		}
	}
}
