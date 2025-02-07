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
		arg_max: 1
		exec:    bend
	}
}

// help give a complete description of the command, including parameters.
fn Bend.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('bend')} ${term.blue('URL')}

${term.red('Warning:')} This URL parameter must be relative to Blog\'s root directory.

The bend command creates an ${cst.blog_entry_filename} file on the blog\'s root, containing HTML redirection
to the provided ${term.blue('URL')}. It\'s usually done to bend blog\'s entry to the last push. It can be used to redirect
to any other ${term.blue('URL')}, in case of unavailability for example.

    e.g. ${term.green('vssg')} ${term.yellow('bend')} ${term.blue('https://duckduckgo.com/')} will redirect to duckduckgo site.
'
}

// bend command feature are implemented here. The parameters number has been checked before call.
fn bend(p []string) ! {



	mut f := util.get_blog_root() or {
		return error('Cannot bend blog to URL, ${term.bright_yellow(cst.blog_root)} is not set.')
	}

	f = f + os.path_separator + cst.blog_entry_filename

	html := '
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="refresh" content="0; url=\'${p[0]}\'"/>
    </head>
    <body>
    </body>
</html>'

	os.write_file(f, html) or {
		return error('Cannot write "${f}" file : ${err}.')
	}

}
