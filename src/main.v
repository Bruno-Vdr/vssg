module main

import term
import commands { Command }
import os
import maps
import strings

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
		println('\nvssg compiled on ${@BUILD_DATE} ${@BUILD_TIME}')
		return
	}

	cm := cmds[os.args[1]] or {
		eprintln('${term.red('Error')}: Unknown command "${os.args[Param.command]}".')

		cmds_names := maps.to_array(cmds, fn (key string, val Command) string {
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

	// We have a valid command here, check it's parameter number.
	params := os.args.len - 2

	if params < cm.arg_min || params > cm.arg_max {
		eprintln('${term.red('Error')}: Wrong argument number for  ${term.yellow(cm.name)}.')
		println('Launch "vssg help ${cm.name}" for more details.')
		return
	}

	// Check if command is launch from its valid location.
	cm.check_validity() or {
		eprintln('${term.red('Error')}: ${err}')
		exit(-1)
	}

	// All basic checks are done, command is known, with a correct number of (unchecked) arguments.
	cm.exec(os.args[2..]) or {
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
