module commands

import term
import util
import structures { Blog }
import constants as cst
import os

// Rename structure, implementing Command interface.
struct Rename implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Rename Command.
pub fn Rename.new() Command {
	return Rename{
		name:    'rename'
		desc:    'Rename (change title) of an existing topic.'
		help:    Rename.help()
		arg_min: 2
		arg_max: 2
		exec:    rename
	}
}

// help give a complete description of the command, including parameters.
fn Rename.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('rename')} title new_title

${term.red('Warning:')} This command must be launched from within blog directory.

The rename command changes the title and directory of an already existing TOPIC:
	-Patch the topic title into ${cst.blog_file} fiole, containing topic(s) list.
	-Rebuild HTML topic list page "${cst.topics_list_filename}".
'
}

// rename command feature are implemented here. The parameters number has been checked before call.
fn rename(p []string) ! {
	title := p[0]
	new_title := p[1]

	if title == new_title {
		return error('Title and new title are identical. Nothing to do.')
	}
	mut blog := Blog.load() or { return error('Unable to load_blog_file: ${err}') }

	mut found := false
	for item in blog.topics {
		if item.title == title {
			found = true
			break
		}
	}

	if found == false {
		return error('Unable to rename ${title}, it does not exist.')
	}

	for item in blog.topics {
		if item.title == new_title {
			return error('Error: Cannot rename ${title} to ${new_title} because ${new_title} already exists.')
		}
	}

	for mut topic in blog.topics {
		if title != topic.title {
			continue
		}

		topic.title = new_title
		blog.save() or { return error('Unable to save updated ${cst.blog_file}') }

		// Now rename old old directory to new (obfuscated) directory.
		os.rename_dir(util.obfuscate(title), util.obfuscate(new_title)) or {
			return error('failed to rename ${util.obfuscate(title)} to ${util.obfuscate(new_title)} : ${err}')
		}
		println('Successfully renamed directory ${util.obfuscate(title)} to ${util.obfuscate(new_title)}')

		blog.generate_topics_list_html() or {
			return error('failed (re)generate_topic_index : ${err}')
		}
		println('Rebuilt topic list HTML page ${cst.topics_list_filename}.')
		return
	}
}
