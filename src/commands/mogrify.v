module commands

import term
import util
import constants as cst
import os

// Mogrify structure, implementing Command interface.
struct Mogrify implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Mogrify Command.
pub fn Mogrify.new() Command {
	return Mogrify{
		kind:    .helper
		name:    'mogrify'
		desc:    "Transforms images to Blog format's image size."
		help:    Mogrify.help()
		arg_min: 0
		arg_max: 1
		exec:    mogrify
	}
}

// help give a complete description of the command, including parameters.
fn Mogrify.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('mogrify')} ${term.gray('[-o]')}

The mogrify command convert all .jpg images contained in directory pointed by VSSG_IMG_PUSH_DIR
(now: ${util.get_img_push_dir() or {
		'"Not set"'
	}}) to Blog\'s defined standard. The command relies on ImageMagik package, to run.
Executed command is the following:

${cst.mogrify_cmd}

If no -o option is added, the output file will be the source file, prefixed by r_  (resized).

The ${term.gray('-o')} option will overwrite source file.
'
}

// mogrify command feature are implemented here. The parameters number has been checked before call.
fn mogrify(p []string) ! {
	overwrite := '-o' in p

	if !overwrite && p.len > 0 {
		return error('Unknown option "${p[0]}". Only the "-o" is known on this command.')
	}

	path := util.get_img_push_dir() or {
		return error('Unable to get ${cst.img_src_env}. Is the env variable set ?')
	}

	entries := os.ls(path) or { [] }
	for entry in entries {
		if !os.is_dir(os.join_path(os.home_dir(), entry)) {
			if entry.ends_with('.JPG') || entry.ends_with('.jpg') {
				src_name := path + entry
				dst_name := if !overwrite {
					path + 'r_' + entry
				} else {
					src_name
				}

				// Generate image magick command line.
				mut cmd := cst.mogrify_cmd.replace('@IFILE', src_name)
				cmd = cmd.replace('@OFILE', dst_name)
				println(cmd)

				util.exec(cmd, true, false) or { println('${term.red('Error:')} ${err}') }
			}
		}
	}
}
