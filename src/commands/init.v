module commands

import term
import os

struct Init implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

pub fn Init.new() Command {
	return Init{
		name:    'init'
		desc:    'short desc'
		help:    Init.help()
		arg_min: 1
		arg_max: 1
		exec:    init
	}
}

// help give a complete description of the command, including parameters.
fn Init.help() string {
	return '
	Command: ${term.green('vssg')} ${term.yellow('init')} ${term.blue ('blog_name')}

	The init command initializes a new blog:
	-It creates a directory with the given ${term.blue ('blog_name')}
'
}

// init command feature are implemented here.
fn init(p []string) ! {
	path := p[0]
	println('Initialising blog ' + term.blue('${path}'))

	if os.exists('${path}') {
		return error('creating ${path} : The directory already "${path}" exists. Command init, ${@FILE_LINE}')
	}
	os.mkdir('./${path}', os.MkdirParams{0o755}) or { return error('mkdir fails: ${err}. Command init, ${@FILE_LINE}') }

	//if os.exists('${path}${os.path_separator}${conf_file}') {
	//	return error('Error creating ${conf_file} : The file already exists.')
	//}


	return
}
