module commands

import util

pub enum CommandType {
	command
	helper
}

pub enum RunFrom {
	outside_blog
	blog_dir
	topic_dir
	blog_or_topic_dir
	anywhere
}

pub fn (r RunFrom) str() string {
	return match r {
		.outside_blog { 'outside blog directory' }
		.blog_dir { 'blog directory' }
		.topic_dir { 'topic directory' }
		.blog_or_topic_dir { 'blog or topic directory' }
		.anywhere { 'anywhere' }
	}
}

pub interface Command {
	kind       CommandType       // Command type
	validity   RunFrom           // Valid execution location
	run_locked bool              // Can the command run on locked topic ?
	name       string            // Command name as used on CLI
	desc       string            // Single line description
	help       string            // Detailed and formated description
	arg_min    int               // Minimal argument number expected
	arg_max    int               // Maximal argument number expected
	exec       fn (s []string) ! // Command callback.
}

// get is the main command access. It returns a complete list of all available commands
// in map to allow random or sequential access. All commands must be added in the map,
// in this static method.
pub fn Command.get() map[string]Command {
	mut c := map[string]Command{}

	init := Init.new()
	c[init.name] = init

	add := Add.new()
	c[add.name] = add

	push := Push.new()
	c[push.name] = push

	env := Env.new()
	c[env.name] = env

	show := Show.new()
	c[show.name] = show

	modify := Modify.new()
	c[modify.name] = modify

	remove := Remove.new()
	c[remove.name] = remove

	update := Update.new()
	c[update.name] = update

	rename := Rename.new()
	c[rename.name] = rename

	help := Help.new()
	c[help.name] = help

	drop := Drop.new()
	c[drop.name] = drop

	sync := Sync.new()
	c[sync.name] = sync

	bend := Bend.new()
	c[bend.name] = bend

	pull := Pull.new()
	c[pull.name] = pull

	chain := Chain.new()
	c[chain.name] = chain

	backup := Backup.new()
	c[backup.name] = backup

	lock_it := Lock.new()
	c[lock_it.name] = lock_it

	obfuscate := Obfuscate.new()
	c[obfuscate.name] = obfuscate

	base64 := Base64.new()
	c[base64.name] = base64

	deploy := Deploy.new()
	c[deploy.name] = deploy

	doc := Doc.new()
	c[doc.name] = doc

	convert := Convert.new()
	c[convert.name] = convert

	return c
}

// check_validity verifies that c command is launched from where it should.
pub fn (c Command) check_validity() ! {
	wd := util.where_am_i()

	match c.validity {
		.outside_blog {
			if wd != .outside {
				return error("This command must be run from outside blog's directory.")
			}
			return
		}
		.blog_dir {
			if wd != .blog_dir {
				return error("This command must be run from blog's directory.")
			}
			return
		}
		.topic_dir {
			if wd != .topic_dir {
				return error('This command must be run from a topic directory.')
			}
			return
		}
		.blog_or_topic_dir {
			if wd != .topic_dir && wd != .blog_dir {
				return error('This command must be run from blog or topic directory.')
			}
			return
		}
		.anywhere {
			return
		}
	}
}
