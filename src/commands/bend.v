module commands

import os
import term
import util
import constants as cst
import structures { Topic }

// Bend structure, implementing Command interface.
struct Bend implements Command {
	kind       CommandType
	validity   RunFrom
	run_locked bool
	name       string
	desc       string
	help       string
	arg_min    int
	arg_max    int
	exec       fn (s []string) ! @[required]
}

// new builds a Bend Command.
pub fn Bend.new() Command {
	return Bend{
		kind:       .command
		validity:   .anywhere
		run_locked: true
		name:       'bend'
		desc:       "Redirects blog's root page to given URL (usually on last push)."
		help:       Bend.help()
		arg_min:    0
		arg_max:    3 // [url] [-f] [-u]
		exec:       bend
	}
}

// help give a complete description of the command, including parameters.
fn Bend.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('bend')} [${term.blue('URL')}] [-f] [-u]

Launched from a topic directory, the bend command creates a blog redirection to its last push.

If an optional ${term.blue('URL')} is provided, it will be used instead of last topic. This optional URL
must be relative to your location when the the command is run, ${term.rgb(255,
		165, 0, 'unless -f option is used')} .

Adding the ${term.gray('-f')} option, discards destination presence check. Use this to redirect on exterior URL.
Adding the ${term.gray('-u')} option will sync/send the redirection file to the remote blog.

This command si usually used to bend blog\'s entry to the last push. It can be used to redirect to any other ${term.blue('URL')},
in case of unavailability for example.

    e.g. ${term.green('vssg')} ${term.yellow('bend')} ${term.gray('-u')} will redirect to the last push in topic and sync the redirection.
    e.g. ${term.green('vssg')} ${term.yellow('bend')} ${term.red('-f')} ${term.blue('https://duckduckgo.com/')} will redirect to duckduckgo site.
'
}

// bend command feature are implemented here. The parameters number has been checked before call.
fn bend(p []string) ! {
	mut force := false
	mut sync := false
	mut args := []string{}

	for param in p {
		if param == '-f' {
			force = true
		} else {
			if param == '-u' {
				sync = true
			} else {
				args << param
			}
		}
	}

	if args.len > 1 {
		return error('Too many parameters or unknown options in "${args}"')
	}

	mut url := ''
	location := util.where_am_i()
	if args.len == 0 {
		// No URL, redirect to the last push.
		if location != .topic_dir {
			return error('The bend command must be launched from topic directory when used without URL.')
		}

		topic := Topic.load()!
		ps := topic.get_last_post_summary() or {
			return error('No push to bend to in the topic "${topic.title}".')
		}

		println('Bending to "Push id: ${ps.id} ${term.yellow(ps.title)}" [${util.to_blog_date(ps.date)}] in ${term.blue(ps.dir)} ')

		url = cst.push_dir_prefix + ps.id.str() + os.path_separator + cst.push_filename
		url = make_relative_to_root(url)!
	} else {
		// An URL was specified
		url = args[0]
		if !force {
			validate_url(url)!

			// This adjustment must be done after presence check !
			if location == .topic_dir {
				url = make_relative_to_root(url)!
			}
		}
	}

	// Build redirection filename
	mut redir_file := util.get_blog_root() or {
		return error('Cannot bend blog to URL, ${term.bright_yellow(cst.blog_root)} is not set. ${err}. ${@LOCATION}')
	}
	redir_file = redir_file + cst.blog_entry_filename

	// Build redirection file
	generate_redirection_file(redir_file, url)!

	if sync == true {
		sync_redirection_file()!
	} else {
		local := "blog's root directory" // Bug workaround https://github.com/vlang/v/issues/24198
		println('Don\'t forget to do "${term.green('vssg')} ${term.yellow('sync')}" from ${term.blue(local)} to publish.')
	}
}

// generate_redirection_file writes redirection file on blog's root dir.
fn generate_redirection_file(filename string, url string) ! {
	redirect_html := '
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="refresh" content="0; url=\'${url}\'"/>
    </head>
    <body>
    </body>
</html>'

	os.write_file(filename, redirect_html) or {
		return error('Cannot write "${filename}" file : ${err}. ${@LOCATION}')
	}
	println('Generated HTML file "${filename}" redirecting to URL: "${term.blue(url)}"')
}

// sync_redirection_file upload to remote blog the redirection file.
fn sync_redirection_file() ! {
	// perform rsync on the redirect_html file
	dst := util.get_remote_url() or {
		return error('${cst.remote_url} environment variable not set, redirection file not synced.')
	}

	mut src := util.get_blog_root() or {
		return error('${cst.blog_root} environment variable not set, redirection file not synced.')
	}

	println(term.yellow('updating redirection file.'))
	src = src + cst.blog_entry_filename
	Sync.sync_file(src, dst, false)!
}

// validate_url checks that URL is valid from the location the command is launched from.
fn validate_url(url string) ! {
	// Check that target exists
	match util.where_am_i() {
		.blog_dir {
			if !os.exists(url) {
				return error("The target file (URL) doesn't exist. Use -f option to force.")
			}
		}
		.topic_dir {
			// Here, file must contains it's path relative to blog.
			if !os.exists(url) {
				return error("The target file (URL) doesn't exist. Use -f option to force.")
			}
		}
		.outside {
			return error("This command cannot be executed from outside blog's directory. Use -f option to force bend without check.")
		}
	}
}

// make_relative_to_root return url from u, relative to blog's root directory. This is done by
// removing blog_root directory from current working directory.
fn make_relative_to_root(u string) !string {
	mut url := u
	cwd := os.getwd()
	mut brd := util.get_blog_root() or {
		return error('Unable to get Blog root env.${err}. ${@LOCATION}')
	}
	url = cwd.replace(brd, '') + os.path_separator + url
	return url
}
