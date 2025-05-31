module commands

import term
import os
import constants as cst
import structures

// Init structure, implementing Command interface.
struct Init implements Command {
	kind     CommandType
	validity RunFrom
	name     string
	desc     string
	help     string
	arg_min  int
	arg_max  int
	exec     fn (s []string) ! @[required]
}

// new builds a Init Command.
pub fn Init.new() Command {
	return Init{
		kind:     .command
		validity: .outside_blog
		name:     'init'
		desc:     'Initializes a new blog.'
		help:     Init.help()
		arg_min:  1
		arg_max:  1
		exec:     init
	}
}

// help give a complete description of the command, including parameters.
fn Init.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('init')} ${term.blue('blog_name')}

The init command initializes a new blog:
    -Creates a directory with the given ${term.blue('blog_name')}.
    -Creates a ${cst.blog_file} config file inside this directory.
    -Generates a default ${cst.style_file} to be used by local HTML.
    -Generates a default ${cst.topics_list_template_file} topic list template file.
'
}

// init command feature are implemented here. The parameters number has been checked before call.
fn init(p []string) ! {
	path := p[0]
	println('Initialising blog ' + term.blue('${path}'))

	if os.exists('${path}') {
		return error('creating ${path} : The directory "${path}" already exists.')
	}

	os.mkdir('./${path}', os.MkdirParams{0o755}) or {
		return error('mkdir fails: ${err}. ${@LOCATION}')
	}

	if os.exists('${path}${os.path_separator}${cst.blog_file}') {
		return error('creating ${cst.blog_file} : The file already exists.')
	}

	blog := structures.Blog.new(path)
	blog.create()!

	deploy_blog_templates(path)! // in deploy.v

	println('You can now customize your ' +
		term.blue('${path}${os.path_separator}${cst.style_file}') + ' and ' +
		term.blue('${path}${os.path_separator}${cst.topics_list_template_file}') + '.')

	println('\nYou should also add to your profile file : \n' + 'export ' +
		term.bright_yellow('${cst.blog_root}') + '="' + term.blue(os.getwd() + os.path_separator +
		path + os.path_separator) + '"')
}
