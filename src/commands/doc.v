module commands

import term
import constants as cst
import util

// Doc structure, implementing Command interface.
struct Doc implements Command {
	kind    CommandType
	validity RunFrom
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Doc Command.
pub fn Doc.new() Command {
	return Doc{
		kind:    .helper
		validity: .anywhere
		name:    'doc'
		desc:    'Displays the whole vssg documentation (all commands).'
		help:    Doc.help()
		arg_min: 0
		arg_max: 1
		exec:    doc
	}
}

// help give a complete description of the command, including parameters.
fn Doc.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('doc')} ${term.gray('[-html]')}

The doc command displays all commands detailled documentation.
The ${term.gray('[-html]')} option emits the documentation into a local vssg_doc.htm file.
'
}

// doc command feature are implemented here. The parameters number has been checked before call.
fn doc(p []string) ! {
	mut html := '-html' in p

	if p.len == 1 && '-html' !in p {
		return error('Unkown parameter "${p[0]}".')
	}

	if html {
		emit_html_doc()!
		println('Documentation file "${term.blue(cst.doc_file)}" emitted.')
	} else {
		println("vssg's commands documentation:\n")
		mut cmds := Command.get()
		for _, c in cmds {
			println(c.help)
			println('________________________________________________________________________________')
		}
	}
}

// emit_html_doc launch  "vssg doc | aha -b -w > vssg_doc.htm". This output documentation through aha
// (ascii-HTML-adapter) and redirect the stdout to a file. This allow to get an HTML document of vssg
// detailed help, with colors kept.
fn emit_html_doc() ! {
	util.exec(cst.doc_command, true, false)!
}
