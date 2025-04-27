module commands

import term
import util
import constants as cst
import os
import time

// Backup structure, implementing Command interface.
struct Backup implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Backup Command.
pub fn Backup.new() Command {
	return Backup{
		kind:    .command
		name:    'backup'
		desc:    'Generates a backup (.zip) of the whole blog.'
		help:    Backup.backup()
		arg_min: 1
		arg_max: 1
		exec:    backup
	}
}

// backup give a complete description of the command, including parameters.
fn Backup.backup() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('backup')} ${term.blue('directory')}

${term.rgb(255,
		165, 0, 'Warning:')} This command must be launched from outside blog\'s directory.

The backup command generates a compressed (.zip) archive if the blog in ${term.blue('directory')}.
The archive can be restored later. Useful in case of dangerous command usage.
Note: No check is done to verify presence of a blog. The directory may contain anything.
Classic images format file are just stored .jpg .png as they are already compressed, to
save time at compression stage.
'
}

// backup command feature are implemented here. The parameters number has been checked before call.
fn backup(p []string) ! {
	match util.where_am_i() {
		.outside {
			if !os.exists(p[0]) {
				return error('The directory "${p[0]}" doesn\'t exist.')
			}

			date := time.now().unix()
			str_date := time.unix(date).custom_format(cst.zip_file_date_format)
			output_file := p[0].trim_right(os.path_separator) + '_' + str_date + '.zip'
			cmd := cst.zip_cmd + ' ' + cst.zip_opt + ' ' + output_file + ' ' + p[0]
			util.exec(cmd, true, false)!
		}
		else {
			return error("This command must be launched from outside blog's directory.")
		}
	}
}
