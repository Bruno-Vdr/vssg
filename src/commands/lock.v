module commands

import util
import structures { Blog, Topic }
import term
import constants as cst
import os

// Lock structure, implementing Command interface.
struct Lock implements Command {
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

// new builds a Lock Command.
pub fn Lock.new() Command {
	return Lock{
		kind:       .command
		validity:   .blog_dir
		run_locked: false
		name:       'lock'
		desc:       'Locks/Freezes a complete topic, so it is read-only.'
		help:       Lock.help()
		arg_min:    1
		arg_max:    1
		exec:       lock_it
	}
}

// lock give a complete description of the command, including parameters.
fn Lock.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('lock')} ${term.blue('topic_title')}

${term.rgb(255,
		165, 0, 'Warning:')} This command must be launched from within blog directory.

The lock command mark a given topic as locked, meaning its read only. Then the topic cannot be modified
anymore, and is protected against erroneous commands.  All topic files and directory authorisation will
be read-only. It is not possible to remove lock with a command. It could be done manually by running the
shell command "chmod -r 755 TopicDir" with Topic directory and changing [locked=true] in ${cst.blog_file}
file and alse changing locked="true" in ${cst.topic_file} file.
'
}

// lock_it lock command feature are implemented here. The parameters number has been checked before call.
fn lock_it(p []string, run_locked bool) ! {
	title := p[0]
	mut blog := Blog.load() or { return error('Unable to load_blog_file: ${err}. ${@LOCATION}') }

	l := blog.is_locked(title) or {
		return error(' The topic "${title}" does not exist in ${cst.blog_file} file.')
	}

	if l {
		return error(' The topic "${title}" is already locked.')
	}

	blog.lock_topic(title)!
	blog.save()!

	// Now update .topic file name/directory section.
	os.chdir(util.obfuscate(title)) or {
		return error('Cannot change current working directory to "${title}": ${err}. ${@LOCATION}')
	}

	topic := Topic.load()!
	// Create new Topic struct with new name and directory, with the SAME posts.
	nt := Topic.build(title, true, topic.get_posts())
	nt.save('./') or {
		return error('Cannot update ${util.obfuscate(title)}${os.path_separator}${cst.topic_file}: ${err}. ${@LOCATION}')
	}

	os.chdir('..') or { return error('Cannot go back to parent directory: ${err}. ${@LOCATION}') }

	// Now run chmod -R ugo+rX-w ./directory : Set right for all files, X means keep dir executable (browsable).
	cmd := 'chmod -R ugo+rX-w ${util.obfuscate(title)}'
	util.exec(cmd, true, false)!
}
