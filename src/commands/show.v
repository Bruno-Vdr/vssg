module commands

import term
import structures { Blog, Topic }
import util
import constants as cst
import os

// Show structure, implementing Command interface.
struct Show implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Show Command.
pub fn Show.new() Command {
	return Show{
		name:    'show'
		desc:    'Shows entries of blog or topic.'
		help:    Show.help()
		arg_min: 0
		arg_max: 0
		exec:    show
	}
}

// help give a complete description of the command, including parameters.
fn Show.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('show')}

The show command displays information depending current working directory:
    In the blog root directory (containing ${cst.blog_file} it displays:
    -topic list.

    In a topic directory (containing ${cst.topic_file} it displays:
    -push list.

'
}

// show command feature are implemented here. The parameters number has been checked before call.
fn show(param []string) ! {
	if blog := Blog.load() {
		println('Blog "' + term.blue('${blog.name}') + '"\n' +
			'Contains ${blog.topics.len} ${term.bright_green('topic(s)')}:')
		for i in 0 .. blog.topics.len {
			topic, date := blog.get_topic(i) or {
				return error('Unable to perform blob.get_topic() !')
			}

			// Date is stored as milliseconds since epoq
			str_date := util.to_blog_date(date)
			println('    Topic ${i}: ' + term.bright_yellow('"${topic}"') +
				' [${str_date}] in sub-dir. -> ' +
				term.bright_blue('.${os.path_separator}${util.obfuscate(topic)}'))
		}
		return
	}

	if topic := Topic.load() {
		println('Topic "' + term.blue('${topic.title}') +
			'" contains ${topic.posts.len} ${term.bright_green('push(s)')}:')
		for p in topic.posts {
			println('    Push id: ${p.id} ${term.bright_yellow('"' + p.title + '"')} [${util.to_blog_date(p.date)}] ${term.bright_blue(p.dir)}')
		}
		return
	}

	// We didn't  find topic_file or conf_file.
	return error('Error, unable to load ${cst.blog_file} or ${cst.topic_file}. Are you in blog or topic directory ?')
}
