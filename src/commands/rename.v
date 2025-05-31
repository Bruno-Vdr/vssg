module commands

import term
import util
import structures { Blog, Topic }
import constants as cst
import os

// Rename structure, implementing Command interface.
struct Rename implements Command {
	kind     CommandType
	validity RunFrom
	name     string
	desc     string
	help     string
	arg_min  int
	arg_max  int
	exec     fn (s []string) ! @[required]
}

// new builds a Rename Command.
pub fn Rename.new() Command {
	return Rename{
		kind:     .command
		validity: .blog_dir
		name:     'rename'
		desc:     'Renames (change title) of an existing topic.'
		help:     Rename.help()
		arg_min:  2
		arg_max:  2
		exec:     rename
	}
}

// help give a complete description of the command, including parameters.
fn Rename.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('rename')} title new_title

${term.rgb(255,
		165, 0, 'Warning:')} This command must be launched from within blog directory.

The rename command changes the title and directory of an already existing TOPIC:
    -Patch the topic title/comment into ${cst.blog_file} file, containing topic(s) list.
    -Rename original topic directory with hash("new_title").
    -Update topic\'s ${cst.topic_file} with new name and directory, keeping posts untouched.
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
	mut blog := Blog.load() or { return error('Unable to load_blog_file: ${err}. ${@LOCATION}') }

	if !blog.exists(title) {
		return error('Unable to rename ${title}, it does not exist.')
	}

	if blog.exists(new_title) {
		return error('Error: Cannot rename ${title} to ${new_title} because ${new_title} already exists.')
	}

	blog.rename(title, new_title)!
	blog.save() or { return error('Unable to save updated ${cst.blog_file}. ${err}. ${@LOCATION}') }

	// Now rename old old directory to new (obfuscated) directory.
	os.rename_dir(util.obfuscate(title), util.obfuscate(new_title)) or {
		return error('failed to rename ${util.obfuscate(title)} to ${util.obfuscate(new_title)} : ${err}. ${@LOCATION}')
	}
	println('Successfully renamed directory ${util.obfuscate(title)} to ${util.obfuscate(new_title)}')

	blog.generate_topics_list_html() or {
		return error('failed (re)generate_topic_index : ${err}. ${@LOCATION}')
	}
	println('Rebuilt topic list HTML page ${cst.topics_list_filename}.')

	// Now update .topic file name/directory section.
	os.chdir(util.obfuscate(new_title)) or {
		return error('Cannot change current working directory to "${new_title}": ${err}. ${@LOCATION}')
	}

	tf := Topic.load() or { return error('Cannot load ${cst.topic_file}: ${err}. ${@LOCATION}') }

	// Create new Topic struct with new name and directory, with the SAME posts.
	nt := Topic.build(new_title, tf.locked, tf.get_posts())
	nt.save('./') or {
		return error('Cannot update ${util.obfuscate(new_title)}${os.path_separator}${cst.topic_file}: ${err}. ${@LOCATION}')
	}

	// Re-generate push list, Topic name is changed, and might be displayed on push list page !
	nt.generate_pushes_list_html()!

	os.chdir('..') or {
		return error('Cannot change current working directory to "${new_title}": ${err}. ${@LOCATION}')
	}

	println('You can now use "${term.green('vssg')} ${term.yellow('sync')}" to publish.')
}
