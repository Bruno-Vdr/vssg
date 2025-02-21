module commands

import term
import util
import constants as cst
import os

// Bend structure, implementing Command interface.
struct Bend implements Command {
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
		name:    'bend'
		desc:    'redirects blog to given URL, usually on last push.'
		help:    Bend.help()
		arg_min: 1
		arg_max: 2
		exec:    bend
	}
}

// help give a complete description of the command, including parameters.
fn Bend.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('bend')} ${term.blue('URL')} [-f]

${term.rgb(255,165,0,'Warning:')} This URL parameter must be relative to Blog\'s root directory.

Adding the ${term.red('-f')} option, completely discards destination check. Use this to
redirect on exterior URL.

The bend command creates an ${cst.blog_entry_filename} file on the blog\'s root, containing HTML redirection
to the provided ${term.blue('URL')}. It\'s usually done to bend blog\'s entry to the last push. It can be used to redirect
to any other ${term.blue('URL')}, in case of unavailability for example.

    e.g. ${term.green('vssg')} ${term.yellow('bend')} ${term.red('-f')} ${term.blue('https://duckduckgo.com/')} will redirect to duckduckgo site.
'
}

// bend command feature are implemented here. The parameters number has been checked before call.
fn bend(p []string) ! {
	if p.len == 1 && p[0] == '-f' {
		return error('Missing URL parameter.')
	}

	mut url := p[0]
	mut force := false

	if p.len == 2 {
		if '-f' in p {
			force = true
			url = if p[0] == '-f' { p[1] } else { p[0] }
		} else {
			return error('Unknown option "${p[1]}"')
		}
	}

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

	html := '
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="refresh" content="0; url=\'${url}\'"/>
    </head>
    <body>
    </body>
</html>'

	os.write_file(f, html) or { return error('Cannot write "${f}" file : ${err}. ${@LOCATION}') }
	println('Generated HTML file "${f}" redirecting to URL: "${term.blue(url)}')
	println('Don\'t forget to do "${term.green('vssg')} ${term.yellow('sync')}" from blog\'s root directory to publish.')
}
