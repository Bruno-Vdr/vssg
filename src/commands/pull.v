module commands

import term
import util
import constants as cst
import os

// Pull structure, implementing Command interface.
struct Pull implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Pull Command.
pub fn Pull.new() Command {
	return Pull{
		kind:    .command
		name:    'pull'
		desc:    'Pull, download the full remote blog to local the directory.'
		help:    Pull.help()
		arg_min: 1
		arg_max: 2
		exec:    pull
	}
}

// help give a complete description of the command, including parameters.
fn Pull.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('pull')} ${term.blue('destination_dir')}  ${term.gray('-f')}

${term.rgb(255,
		165, 0, 'Warning:')} This command must be launched from outside blog directory.

The ${term.gray('-f')} option, allows to continue if destination directory already exists. It\'s
useful to resume interrupted earlier pull command.

The pull command downloads the full remote blog to local the directory. This is useful
if the local blog is lost. This command is potentially dangerous, and must be run from
outside blog directory.
'
}

// pull command feature are implemented here. The parameters number has been checked before call.
fn pull(p []string) ! {
	mut force := false
	mut url := ''

	if p.len > 1 {
		if '-f' in p {
			force = true
			url = if p[0] == '-f' { p[1] } else { p[0] }
		} else {
			return error('Unknown option in parameters ${term.yellow(p.str())}')
		}
	} else {
		url = p[0]
	}

	match util.where_am_i() {
		.outside {
			do_pull(url, force)!
		}
		else {
			println('The ${term.yellow('pull')} command cannot be launched from inside blog\'s directory.')
		}
	}
}

fn do_pull(dst string, forced bool) ! {
	url := util.get_remote_url() or {
		return error('${cst.remote_url} environment variable not set.')
	}

	// The destination directory should not exist and can be created, excepted if forced.
	if !forced && os.exists('${dst}') {
		return error('creating ${dst} : The directory "${dst}" already exists.')
	}
	os.mkdir('./${dst}', os.MkdirParams{0o755}) or {
		if !forced {
			return error('mkdir fails: ${err}. ${@LOCATION}')
		}
	}

	// Permanent option is env variable.
	permanent_opt := util.get_sync_opt() or { '' }
	cmd := '${cst.rsync_pull_opt} ${permanent_opt} ${url}/ ${dst}'
	println('rsync command: ${cmd}')

	// Call sync.v run_sync_cmd
	run_sync_cmd(cmd, false)!
	println('Don\'t forget to update your ${term.yellow(cst.blog_root)} environment variable if you intend to use')
	println('this pulled directory as new blog\'s root. You should also adapt field "name" from ${term.blue('${dst}${os.path_separator}${cst.blog_file}')}')
}
