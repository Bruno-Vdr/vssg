module commands

import term
import util
import constants as cst
import os

// Convert structure, implementing Command interface.
struct Convert implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Convert Command.
pub fn Convert.new() Command {
	return Convert{
		kind:    .helper
		name:    'convert'
		desc:    "Transforms images to Blog format's image size."
		help:    Convert.help()
		arg_min: 0
		arg_max: 1
		exec:    convert
	}
}

// help give a complete description of the command, including parameters.
fn Convert.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('convert')} ${term.gray('[-o]')}

The convert command convert all .jpg images contained in directory pointed by VSSG_IMG_PUSH_DIR
(now: ${util.get_img_push_dir() or {
		'"Not set"'
	}}) to Blog\'s defined standard. The command relies on ImageMagik package, to run.
Executed command is the following:

${cst.convert_cmd}

If no -o option is added, the output file will be the source file, prefixed by r_  (resized).

The ${term.gray('-o')} option will overwrite source file.
'
}

struct Sd {
	src string
	dst string
}

// convert command feature are implemented here. The parameters number has been checked before call.
fn convert(p []string) ! {
	overwrite := '-o' in p

	if !overwrite && p.len > 0 {
		return error('Unknown option "${p[0]}". Only the "-o" is known on this command.')
	}

	path := util.get_img_push_dir() or {
		return error('Unable to get ${cst.img_src_env}. Is the env variable set ?')
	}

	entries := os.ls(path) or { [] }
	mut filtered := []Sd{}

	for entry in entries {
		if !os.is_dir(os.join_path(os.home_dir(), entry)) {
			if entry.ends_with('.JPG') || entry.ends_with('.jpg') {
				src_name := path + entry
				dst_name := if !overwrite {
					path + 'resized_' + entry
				} else {
					src_name
				}
				filtered << Sd{src: src_name, dst : dst_name}
			}
		}
	}

	for name in filtered {
		// Generate image magick command line.
		mut cmd := cst.convert_cmd.replace('@IFILE', name.src)
		cmd = cmd.replace('@OFILE', name.dst)
		println(cmd)
		util.exec(cmd, true, false) or { println('${term.red('Error:')} ${err}') }
	}

	generate_image_list(filtered, path)!
}

// generate_image_list build a HTML page containing preview of converted images with their name, to ease Push writing.
fn generate_image_list(images []Sd, path string) ! {
	// Now create/overwrite output file
	out_file := path + cst.image_list_name
	mut ofile := os.open_file(out_file, 'w+', cst.file_access) or {
		return error('opening ${out_file} : ${err}. ${@FILE_LINE}')
	}

	defer {
		ofile.close()
	}

	doc_start := '
<!DOCTYPE html>
<html>
<body>
'

	doc_end := '
</body>
</html>
'

	mut img_names := []string{}

	ofile.writeln(doc_start) or {
		return error('Unable to write ${cst.topics_list_filename}: ${err}. ${@FILE_LINE}')
	}

	mut col := 0

	mut html_table := []string{}
	html_table << '<table>'
	html_table << '<tr>'
	for image in images {
		html_table << '<th>'
		html_table << ' <img src="${image.dst}" alt="${image.dst}" width="200" height="200"><br>'
		html_table << '[img:${image.dst.replace(path, '')}:""]'
		img_names << '[img:${image.dst.replace(path, '')}:""]'
		html_table << '</th>'
		col++
		if col > 2 {
			html_table << '</tr>'
			html_table << '<tr>'
			col = 0
		}
	}

	html_table << '</table>'

	for l in html_table {
		ofile.writeln(l) or {
			return error('Unable to write ${cst.topics_list_filename}: ${err}. ${@FILE_LINE}')
		}
	}
	// Emit full name list.
	for name in img_names {
		ofile.writeln('${name}' + '\n<br>') or {
			return error('Unable to write ${cst.topics_list_filename}: ${err}. ${@FILE_LINE}')
		}
	}

	ofile.writeln(doc_end) or {
		return error('Unable to write ${cst.topics_list_filename}: ${err}. ${@FILE_LINE}')
	}
}
