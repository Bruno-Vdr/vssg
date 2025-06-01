module commands

import term
import structures { Blog, Topic }
import util
import constants as cst
import os

// Show structure, implementing Command interface.
struct Show implements Command {
	kind       CommandType
	validity   RunFrom
	run_locked bool
	name       string
	desc       string
	help       string
	arg_min    int
	arg_max    int
	exec       fn (s []string, rl bool) ! @[required]
}

// new builds a Show Command.
pub fn Show.new() Command {
	return Show{
		kind:       .command
		validity:   .blog_or_topic_dir
		run_locked: true
		name:       'show'
		desc:       'Shows entries of blog or topic.'
		help:       Show.help()
		arg_min:    0
		arg_max:    1
		exec:       show
	}
}

// help give a complete description of the command, including parameters.
fn Show.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('show')} ${term.gray('[-a]')}

The show command displays information depending current working directory:
    In the blog root directory (containing ${cst.blog_file} it displays:
    -topic list.

    With the ${term.gray('-a')} option, topic\'s push are also displayed.

    In a topic directory (containing ${cst.topic_file} it displays:
    -push list.
'
}

// show command feature are implemented here. The parameters number has been checked before call.
fn show(param []string, run_locked bool) ! {
	mut show_all := false
	if param.len == 1 {
		if '-a' in param {
			show_all = true
		} else {
			return error('Unknown option ${term.red(param[0])}')
		}
	}

	if util.where_am_i() == .blog_dir {
		blog := Blog.load()!
		println('Blog "' + term.blue('${blog.name}') + '"\n' +
			'Contains ${blog.get_topics_number()} ${term.bright_green('topic(s)')}:')
		for i in 0 .. blog.get_topics_number() {
			topic_item := blog.get_topic(i) or {
				return error('Unable to perform blob.get_topic(). ${err}. ${@LOCATION}')
			}

			// Date is stored as milliseconds since epoq
			str_date := util.to_blog_date(topic_item.date)

			locked_str := if topic_item.locked {
				term.red('[Locked  ]')
			} else {
				term.green('[Unlocked]')
			}

			println('    Topic ${i}: ' + term.bright_yellow('"${topic_item.title}"') +
				' [${str_date}] ${locked_str} : Stored in sub-dir. -> ' +
				term.bright_blue('.${os.path_separator}${util.obfuscate(topic_item.title)}'))

			// Dump topic if -a option present.
			if show_all {
				os.chdir(util.obfuscate(topic_item.title))!
				list_topic(false)!
				os.chdir('..')!
			}
		}
	} else { // .topic_dir
		list_topic(true)!
	}
}

fn list_topic(header bool) ! {
	topic := Topic.load()!
	if header {
		locked_str := if topic.locked {
			term.red(' [Locked  ]')
		} else {
			term.green(' [Unlocked]')
		}
		println('Topic "' + term.blue('${topic.title}' ) + locked_str +
			'" contains ${topic.get_posts_number()} ${term.bright_green('push(s)')}:')
	}

	pst := topic.get_posts()
	for _, p in pst {
		mut str := 'Push id: ${p.id} ${term.bright_yellow('"' + p.title + '"')} [${util.to_blog_date(p.date)}] ${term.bright_blue(p.dir)}'
		if header {
			str = '    ' + str
		} else {
			str = '        *' + str
		}
		println(str)
	}
}
