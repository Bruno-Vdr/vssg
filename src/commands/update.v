module commands

import term
import util
import structures { Blog, Topic }
import constants as cst

// Update structure, implementing Command interface.
struct Update implements Command {
	kind     CommandType
	validity RunFrom
	name     string
	desc     string
	help     string
	arg_min  int
	arg_max  int
	exec     fn (s []string) ! @[required]
}

// new builds a Update Command.
pub fn Update.new() Command {
	return Update{
		kind:     .command
		validity: .blog_or_topic_dir
		name:     'update'
		desc:     'Updates HTML link page of Topic or Push.'
		help:     Update.help()
		arg_min:  0
		arg_max:  0
		exec:     update
	}
}

// help give a complete description of the command, including parameters.
fn Update.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('update')}

    The update command force generation of links page (topic list or push list) depending
    on the current directory. This command is usefull when modifying local template_list
    model.

    In the blog root directory (containing ${cst.blog_file}) it rebuilds topic list.
    In a topic directory (containing ${cst.topic_file}) it rebuilds push list.
'
}

// update command feature are implemented here. The parameters number has been checked before call.
fn update(p []string) ! {
	r := util.where_am_i()
	if r == .blog_dir {
		b := Blog.load()!
		println('Blog root, rebuilding topic list file: "${term.blue(cst.topics_list_filename)}".')
		b.generate_topics_list_html()!
		println('Rebuilding of topic list was successful.')
	} else { // we are in .topic_dir
		t := Topic.load()!
		println('Topic directory, rebuilding push list file: "${term.blue(cst.pushs_list_filename)}".')
		t.generate_pushes_list_html()!
		println('Rebuilding of push list was successful.')
	}
	println('You can now use "${term.green('vssg')} ${term.yellow('sync')}" to publish.')
}
