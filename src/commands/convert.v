module commands

import term
import util
import constants as cst
import os
// import time
import sync.pool
import runtime

// Convert structure, implementing Command interface.
struct Convert implements Command {
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

// new builds a Convert Command.
pub fn Convert.new() Command {
	return Convert{
		kind:       .helper
		validity:   .anywhere
		run_locked: true
		name:       'convert'
		desc:       "Transforms images to Blog format's image size."
		help:       Convert.help()
		arg_min:    0
		arg_max:    1
		exec:       convert
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

pub struct Sd {
	src string
	dst string
}

struct PathWithStats {
mut:
	path  string
	ctime i64
}

fn stats(path string) PathWithStats {
	return PathWithStats{
		path:  path
		ctime: if stat := os.lstat(path) { stat.mtime } else { 0 }
	}
}

// convert command feature are implemented here. The parameters number has been checked before call.
fn convert(p []string, run_locked bool) ! {
	overwrite := '-o' in p

	if !overwrite && p.len > 0 {
		return error('Unknown option "${p[0]}". Only the "-o" is known on this command.')
	}

	path := util.get_img_push_dir() or {
		return error('Unable to get ${cst.img_src_env}. Is the env variable set ?')
	}

	mut entries := []string{}

	// Get file list ORDERED by Modified date.
	for f in os.ls(path)!.map(stats(path + it)).sorted(|a, b| a.ctime < b.ctime) {
		entry := f.path
		entries << entry
		println('${entry} ${f.ctime}')
	}

	mut filtered := []Sd{}
	for entry in entries {
		if entry.ends_with('.JPG') || entry.ends_with('.jpg') {
			src_name := entry
			dst_name := if !overwrite {
				// Prefix filename with resized
				name := os.file_name(entry)
				pth := entry.replace(name, '')
				pth + os.path_separator + 'resized_' + name
			} else {
				src_name
			}
			filtered << Sd{
				src: src_name
				dst: dst_name
			}
		}
	}

	cores := runtime.nr_cpus()
	println('Spawning conversion on ${cores} cores.')
	mut pp := pool.new_pool_processor(pool.PoolProcessorConfig{ maxjobs: cores, callback: worker })
	pp.work_on_items(filtered)
	for s in pp.get_results[string]() {
		println(s)
	}

	generate_image_list(filtered, path)!
}

// worker is the callback given to the pool processor to convert images.
fn worker(mut p pool.PoolProcessor, idx int, worker_id int) &string {
	name := p.get_item[Sd](idx)
	// Generate image magick command line.
	mut cmd := cst.convert_cmd.replace('@IFILE', name.src)
	cmd = cmd.replace('@OFILE', name.dst)
	mut r := term.green('${name.src} converted to ${name.dst}')
	util.exec(cmd, false, false) or { r = '${term.red('Error:')} ${err}' }
	return &r
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
