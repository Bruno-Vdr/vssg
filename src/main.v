module main

import term
import commands { Command }
import os
// import maps   // Until bugfix: https://github.com/vlang/v/issues/26567
import strings
import util

enum Param {
	exe
	command
	param1
	param2
	param3
}

// Work around found by StunxFS
// Until bugfix: https://github.com/vlang/v/issues/26567
pub fn to_array[K, V, I](m map[K]V, f fn (key K, val V) I) []I {
	mut a := []I{cap: m.len}

	for k, v in m {
		a << f(k, unsafe { v })
	}

	return a
}

fn main() {
	mut cmds := Command.get()

	if os.args.len == 1 { // case: No parameters given
		usage(cmds)

		if b := util.get_blog_root() {
			i := b.split_any(os.path_separator)
			println('[Target blog: ${term.blue(i.last())}]')
		}
		println('\nvssg compiled on ${@BUILD_DATE} ${@BUILD_TIME}')
		return
	}

	cm := cmds[os.args[1]] or {
		eprintln('${term.red('Error')}: Unknown command "${os.args[Param.command]}".')

		cmds_names := to_array(cmds, fn (key string, val Command) string {
			return key
		})

		mut dice := f32(0)
		mut suggestion := ''
		for s in cmds_names {
			d := strings.dice_coefficient(os.args[1], s)
			if d > dice {
				dice = d
				suggestion = s
			}
		}

		if dice > 0 {
			println('Did you mean ' + term.yellow(suggestion) + ' ?')
		}
		return
	}

	// Check if command is launched from its valid location.
	cm.check_validity() or {
		eprintln('${term.red('Error')}: ${err}')
		exit(-1)
	}

	// Check that command run from Topic dir is allowed to do so.
	cm.check_lock_for_run_from_topic() or {
		eprintln('${term.red('Error')}: ${err}')
		exit(-1)
	}

	// We have a valid command here, check it's parameter number.
	params := os.args.len - 2

	if params < cm.arg_min || params > cm.arg_max {
		eprintln('${term.red('Error')}: Wrong argument number for  ${term.yellow(cm.name)}.')
		println('Launch "vssg help ${cm.name}" for more details.')
		return
	}

	// All basic checks are done, command is known, with a correct number of (unchecked) arguments.
	cm.exec(os.args[2..], cm.run_locked) or {
		eprintln('${term.red('Error')}: ${err}')
		exit(-1)
	}
}

// usage shows all vssg's commands usage.
fn usage(cmds map[string]Command) {
	println('vssg usage: ${term.green('vssg')} ${term.yellow('command')} [parameters]\n')
	for _, c in cmds {
		match c.kind {
			.command { println('    ${term.green('vssg')} ${term.yellow(c.name)} : ${c.desc}') }
			.helper { println('    ${term.gray('[helper]')} ${term.green('vssg')} ${term.yellow(c.name)} : ${c.desc}') }
		}
	}
	println('\nRun  "vssg help ${term.yellow('command')}" to get more detailled help on command.')
}
