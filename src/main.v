module main

import term
import commands { Command }
import os

fn main() {
	mut cmds := Command.get()
	// mut b := Blog{}

	if os.args.len == 1 {
		usage(cmds)
		return
	}

	if os.args[1] == 'help' {
		if os.args.len == 3 {
			cm := cmds[os.args[2]] or {
				eprintln('${term.red('Error')}: Unknown command "${os.args[2]}".')
				return
			}

			help(cm) // Show help of the given command
		} else {
			// Wrong parameter number for help command
			eprintln('${term.red('Error')}: help command expects 1 parameter (${os.args.len - 2} provided).')
			return
		}
	}
}

// usage shows all vssg's commands usage.
fn usage(cmds map[string]Command) {
	println('vssg usage: ${term.green('vssg')} ${term.yellow('command')} [parameters]')
	for _, c in cmds {
		println('    ${term.green('vssg')} ${term.yellow(c.name)} : ${c.desc}')
	}
}

// help output full given command description.
fn help(cmd Command) {
	println('    ${term.green('vssg')} ${term.yellow(cmd.name)} : ${cmd.help}')
}
