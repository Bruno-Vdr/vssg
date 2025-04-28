module commands

import term
import util
import constants as cst
import os

// Bend structure, implementing Command interface.
struct Bend implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Bend Command.
pub fn Bend.new() Command {
	return Bend{
		kind:    .command
		name:    'bend'
		desc:    "Redirects blog's root page to given URL (usually on last push)."
		help:    Bend.help()
		arg_min: 1
		arg_max: 3 // File [-f] [-u]
		exec:    bend
	}
}

// help give a complete description of the command, including parameters.
fn Bend.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('bend')} ${term.blue('URL')} [-f] [-u]

${term.rgb(255,
		165, 0, 'Warning:')} This URL parameter must be relative to your location when the
the command is run, unless -f option is used.

Adding the ${term.gray('-f')} option, discards destination presence check. Use this to redirect on exterior URL.
Adding the ${term.gray('-u')} option will sync/send the redirection file to the remote blog.

The bend command creates an ${cst.blog_entry_filename} file on the blog\'s root, containing HTML redirection
to the provided ${term.blue('URL')}. It\'s usually done to bend blog\'s entry to the last push. It can be used to redirect
to any other ${term.blue('URL')}, in case of unavailability for example.

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

	if args.len != 1 {
		return error('Too many parameters or unknown options in "${args}"')
	}

	mut url := args[0]

	mut f := util.get_blog_root() or {
		return error('Cannot bend blog to URL, ${term.bright_yellow(cst.blog_root)} is not set. ${err}. ${@LOCATION}')
	}

	f = f + os.path_separator + cst.blog_entry_filename

	if !force {
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
				cwd := os.getwd()
				mut brd := util.get_blog_root() or {
					return error('Unable to get Blog root env.${err}. ${@LOCATION}')
				}

				brd = brd + os.path_separator
				url = cwd.replace(brd, '') + os.path_separator + url
				println('URL prefixed with topic directory: ${url}')
			}
			.outside {
				return error("This command cannot be executed from outside blog's directory. Use -f option to force bend without check.")
			}
		}
	}

	// Build redirection file
	generate_redir_file(f, url)!

	if sync == true {
		sync_redir_file()!
	} else {
		local := "blog's root directory" // Bug workaround https://github.com/vlang/v/issues/24198
		println('Don\'t forget to do "${term.green('vssg')} ${term.yellow('sync')}" from ${term.blue(local)} to publish.')
	}
}

// generate_redir_file writes redirection file on blog's root dir.
fn generate_redir_file(filename string, url string) ! {
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

// sync_redir_file upload to remote blog the redirection file.
fn sync_redir_file() ! {
	// perform rsync on the redirect_html file
	dst := util.get_remote_url() or {
		return error('${cst.remote_url} environment variable not set, redirection file not synced.')
	}

	mut src := util.get_blog_root() or {
		return error('${cst.blog_root} environment variable not set, redirection file not synced.')
	}

	println(term.yellow('updating redirection file.'))
	src = src + os.path_separator + cst.blog_entry_filename
	Sync.sync_file(src, dst, false)!
}
