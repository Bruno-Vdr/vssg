module commands

import term
import os
import constants as cst
import structures {Blog, Topic, Post}
import util

// Init structure, implementing Command interface.
struct Push implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Init Command.
pub fn Push.new() Command {
	return Push{
		name:    'push'
		desc:    'Push a new article into topic (run from inside the topic directory).'
		help:    Push.help()
		arg_min: 1
		arg_max: 1
		exec:    push
	}
}

// help give a complete description of the command, including parameters.
fn Push.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('push')} ${term.blue('path_to_post_file')}

The push command creates a new post in the current topic:

'
}

// post command feature are implemented here. The parameters number has been checked before call.
fn push(p []string) ! {
	post_file := p[0]

	// First, check post_file.
	if !os.exists('${post_file}') {
		return error('Error loading "${post_file}" : The file does not exist. ${@FILE_LINE}.')
	}

	mut post := Post.load(post_file)!

	// mut topics := Topic.load()!
	// id := topics.get_next_post_id()
	// post.set_id(id)
}
