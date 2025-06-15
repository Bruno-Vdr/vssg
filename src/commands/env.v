module commands

import term
import util
import constants as cst

// Env structure, implementing Command interface.
struct Env implements Command {
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

// new builds a Env Command.
pub fn Env.new() Command {
	return Env{
		kind:       .command
		validity:   .anywhere
		run_locked: true
		name:       'env'
		desc:       'Displays environment variables used by vssg.'
		help:       Env.help()
		arg_min:    0
		arg_max:    1
		exec:       env
	}
}

// help give a complete description of the command, including parameters.
fn Env.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('env')} ${term.gray('-e')}

The env command displays the environment variables used by vssg:

    ${term.bright_yellow(cst.default_push_dir)} : Default directory to get push files from.
    ${term.bright_yellow(cst.img_src_env)} : Path to grab pushed images from.
    ${term.bright_yellow(cst.default_tmpl_dir)} : Path to grab blog\'s templates from.
    ${term.bright_yellow(cst.remote_url)} : Remote blog\'s URL (used by sync command).
    ${term.bright_yellow(cst.blog_root)} : Local blog\' location (used by sync command).
    ${term.bright_yellow(cst.rsync_permanent_option)} : Permanent customizable rsync option e.g. "-e \'ssh -p 2223\'".

Adding the  ${term.gray('-e')} option will emit a set of shell commands that exports these variables. Its can
be used to generate a shell file that one can run, to switch from blog to another.
'
}

// env command feature are implemented here. The parameters number has been checked before call.
fn env(p []string, run_locked bool) ! {
	mut export := false
	println("# vssg's environment variables:\n")
	if p.len == 1 && p[0] != '-e' {
		return error('Unknown option "${p[0]}" for the env command.')
	} else {
		export = p.len == 1
	}

	print_std(export, cst.blog_root, util.get_blog_root())
	print_std(export, cst.default_tmpl_dir, util.get_default_template_dir())
	print_std(export, cst.default_push_dir, util.get_default_push_dir())
	print_std(export, cst.img_src_env, util.get_img_push_dir())
	print_std(export, cst.remote_url, util.get_remote_url())
	print_std(export, cst.rsync_permanent_option, util.get_sync_opt())
	println('')
}

// print_std emits on stdout variables value, colored or not based on export value.
fn print_std(export bool, var string, val ?string) {
	if export {
		value := if val == none {'Not set'} else {val}
		println('export ${var}="${value}"')
	} else {
		if val != none {
			println('${term.bright_yellow(var)}="${val}"')
		} else {
			println('${term.bright_yellow(var)}=${term.red('Not set')}')
		}
	}
}
