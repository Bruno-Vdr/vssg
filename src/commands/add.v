module commands

import term
import util
import structures { Blog }
import constants as cst
import os

// Add structure, implementing Command interface.
struct Add implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Init Command.
pub fn Add.new() Command {
	return Add{
		name:    'add'
		desc:    'Creates a new topic (launch from inside the blog directory).'
		help:    Add.help()
		arg_min: 1
		arg_max: 1
		exec:    add
	}
}

// help return the complete description of the command.
fn Add.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('add')} ${term.blue('topic')}

Warning: This command must be launched from within blog directory.

The add command creates a new topic inside the blog:
    -Create a directory based on hashed(${term.blue('topic')}).

'
}

// add command feature are implemented here. The parameters number has been checked before call.
fn add(p []string) ! {
	title := p[0]
	mut blog := Blog.load() or { return error('Unable to load_blog_file: ${err}, ${@FILE_LINE}') }

	if title in blog.topics {
		return error(' The topic already exists in ${cst.blog_file} file. ${@FILE_LINE}')
	}

	dir := util.obfuscate(title)
	println('Creating topic: "' + term.yellow(title) + '" in ' + term.blue(dir) +
	' directory.')

	// Create destination directory.
	if os.exists('${dir}') {
		return error('unable to create ${dir} : The directory already exists.  ${@FILE_LINE}')
	}
	os.mkdir('./${dir}', os.MkdirParams{0o755}) or { return error('mkdir ${dir} failed: ${err},  ${@FILE_LINE}') }

	blog.add_topic(title)


	return
}
