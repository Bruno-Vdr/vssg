module commands

import term
import structures { Blog }
import util
import constants as cst
import os

// Drop structure, implementing Command interface.
struct Drop implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Drop Command.
pub fn Drop.new() Command {
	return Drop{
		name:    'drop'
		desc:    'Drop a complete topic with its pushes (if any).'
		help:    Drop.help()
		arg_min: 1
		arg_max: 1
		exec:    drop
	}
}

// drop give a complete description of the command, including parameters.
fn Drop.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('drop')} topic_title

${term.red('Warning:')} This command must be launched from within blog directory.

The drop command deletes a complete topic will all of its pushes, if any.
	-It also updates ${cst.blog_file} accordingly.
	-Rebuilt the HTML links to topic page, "${cst.topics_list_filename}".

To get a list of topics, run "vssg show" from blog\'s root directory."
'
}

// drop command feature are implemented here. The parameters number has been checked before call.
fn drop(p []string) ! {
	title := p[0]
	mut blog := Blog.load() or { return error('Unable to load_blog_file: ${err}') }

	if title !in blog.topics {
		return error('Unable to drop topic  "${title}", it does not exist in ${cst.blog_file}.')
	}




}
