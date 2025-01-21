module main

import term
import commands { Command }
import os

enum Param {
	exe
	command
	param1
	param2
	param3
}

fn main() {
	mut cmds := Command.get()

	if os.args.len == 1 { // case: No parameters given
		usage(cmds)
		return
	}

	if os.args[Param.command] == 'help' {
		if os.args.len == 3 {
			cm := cmds[os.args[Param.param1]] or {
				eprintln('${term.red('Error')}: Unknown command "${os.args[Param.param1]}".')
				return
			}

			help(cm) // Show help of the given command
			return
		} else {
			// Wrong parameter number for help command
			eprintln('${term.red('Error')}: help command expects 1 parameter (${os.args.len - 2} provided).')
			return
		}
	}

	cm := cmds[os.args[1]] or {
		eprintln('${term.red('Error')}: Unknown command "${os.args[Param.command]}".')
		return
	}

	// We have a valid command here, check it's parameter number.
	params := os.args.len - 2

	if params < cm.arg_min || params > cm.arg_max {
		eprintln('${term.red('Error')}: Wrong argument number for  ${term.yellow(cm.name)}.')
		println('Launch "vssg help ${cm.name}" for more details.')
		return
	}

	// All basic checks are done, command is known, with a correct number of arguments.
	cm.exec(os.args[2..]) or {
		eprintln('${term.red('Error')}: ${err}')
		exit(-1)
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
