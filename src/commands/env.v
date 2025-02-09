module commands

import term
import util
import constants as cst

// Env structure, implementing Command interface.
struct Env implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Env Command.
pub fn Env.new() Command {
	return Env{
		name:    'env'
		desc:    'Displays environment variables used by vssg.'
		help:    Env.help()
		arg_min: 0
		arg_max: 0
		exec:    env
	}
}

// help give a complete description of the command, including parameters.
fn Env.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('env')}

The env command displays the environment variables used by vssg:

    ${term.bright_yellow(cst.img_src_env)} : Path to grab pushed images from.
    ${term.bright_yellow(cst.remote_url)} : Remote blog\'s URL (used by sync command).
    ${term.bright_yellow(cst.blog_root)} : Local blog\' location (used by sync command).
    ${term.bright_yellow(cst.rsync_permanent_option)} : Permanent customizable rsync option e.g. "-e \'ssh -p 2223\'".
'
}

// env command feature are implemented here. The parameters number has been checked before call.
fn env(p []string) ! {
	println("vssg's environement variables:\n")
	print(term.bright_yellow(cst.img_src_env) + ' = ')
	if img_post := util.get_img_post_dir() {
		println('"' + img_post + '"')
	} else {
		println(term.red('Not set'))
	}

	print(term.bright_yellow(cst.remote_url) +  ' = ')
	if url := util.get_remote_url() {
		println('"' +url+ '"')
	} else {
		println(term.red('Not set'))
	}

	print(term.bright_yellow(cst.blog_root) + ' = ')
	if url := util.get_blog_root() {
		println('"' + url +'"')
	} else {
		println(term.red('Not set'))
	}

	print(term.bright_yellow(cst.rsync_permanent_option) + ' = ')
	if url := util.get_sync_opt() {
		println('"'+ url + '"')
	} else {
		println(term.red('Not set'))
	}

	println('')
}
