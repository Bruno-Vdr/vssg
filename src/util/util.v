module util

import os
import time
import constants as cst
import term
import hash.fnv1a
import strconv
import io

// parse_topic_values parses a single line of the following format:
// A start label, a doubled quoted string and a int between []
// topic = "topik" [1737634926] # In directory ./glob/520c837d69349ecc
// Comment, starting at # are ignored.
// Since these files should not be modified by hand, malformed file/line are skipped.
// The function returns an Option rather than a Result.
pub fn parse_topic_values(label string, line string) ?(string, i64, bool) {
	if line.len == 0 {
		return none
	}

	pos := line.index('#') or { line.len }
	s := line.substr_with_check(0, pos) or { line }

	if s.starts_with(label) {
		value := s.find_between('"', '"')
		dte := s.find_between('[', ']')
		locked := s.find_between('[Locked=', ']')
		if locked !in ['true', 'false'] {
			return none
		}
		return if value.len == 0 || dte.len == 0 { none } else { value, dte.i64(), locked == 'true' }
	}
	return none
}

// parse_name_value : parse a line starting with label and containting a double quoted string.
// e.g. : msg = "Message"  the '=' not mandatory.
pub fn parse_name_value(label string, s string) ?string {
	if s.starts_with(label) {
		value := s.find_between('"', '"')
		return if value.len == 0 { none } else { value }
	}
	return none
}

// parse_push_values : parses a line containing push values.
// Expected line format: "push = [id:0][title:A link override][date:1737637908][dir:./push_0]"
// Since these files should not be modified by hand, malformed file/line are skipped.
// The function returns an Option rather than a Result.
pub fn parse_push_values(label string, s string) ?(u64, string, i64, string) {
	if s.starts_with(label) {
		id_str := s.find_between('[id:', ']')
		id := strconv.parse_uint(id_str, 10, 64) or { return none }

		title := s.find_between('[title:', ']')
		if title.len == 0 {
			return none
		}

		date_str := s.find_between('[date:', ']')
		date := strconv.parse_int(date_str, 10, 64) or { return none }

		dir := s.find_between('[dir:', ']')
		if dir.len == 0 {
			return none
		}

		return if title.len == 0 {
			none
		} else {
			id, title, date, dir
		}
	}
	return none
}

// deploy_template performs a copy of file name taken in directory pointed by VSSG_TEMPLATE_DIR to
// the given path / output_name
pub fn deploy_template(name string, dest_path string, output_name string) ! {
	if path := util.get_default_template_dir() {
		println('deploy_template: Copying ${path+name} to ${output_name}')
		os.cp(path + name, dest_path + output_name)!
	} else {
		return error('Unable to retrieve ${cst.default_tmpl_dir} environment variable. Is the variable set ?')
	}
}

pub fn to_blog_date(date i64) string {
	return time.unix(date).custom_format(cst.blog_date_format)
}

// get_blog_root Returns blog's root directory. Add terminal path separator if missing.
pub fn get_blog_root() ?string {
	p := os.getenv_opt(cst.blog_root)
	return if p != none {
		if p.ends_with(os.path_separator) {
			p
		} else {
			p + os.path_separator
		}
	} else {
		none
	}
}

// get_img_push_dir Returns image push directory. Add terminal path separator if missing.
pub fn get_img_push_dir() ?string {
	p := os.getenv_opt(cst.img_src_env)
	return if p != none {
		if p.ends_with(os.path_separator) {
			p
		} else {
			p + os.path_separator
		}
	} else {
		none
	}
}

// get_default_push_dir Returns push directory. Add terminal path separator if missing.
pub fn get_default_push_dir() ?string {
	p := os.getenv_opt(cst.default_push_dir)
	return if p != none {
		if p.ends_with(os.path_separator) {
			p
		} else {
			p + os.path_separator
		}
	} else {
		none
	}
}

// get_default_template_dir Returns push directory. Add terminal path separator if missing.
pub fn get_default_template_dir() ?string {
	p := os.getenv_opt(cst.default_tmpl_dir)
	return if p != none {
		if p.ends_with(os.path_separator) {
			p
		} else {
			p + os.path_separator
		}
	} else {
		none
	}
}

pub fn get_remote_url() ?string {
	return os.getenv_opt(cst.remote_url)
}

pub fn get_sync_opt() ?string {
	return os.getenv_opt(cst.rsync_permanent_option)
}

// obfuscate obfuscate/mangle a topic name
pub fn obfuscate(title string) string {
	return fnv1a.sum64_string(title).hex()
}

// extract_link_model receives a full template file that will contain a list of links.
// e.g. : topic list, or pushes list template. Link models are between twe links tag.
pub fn extract_link_model(t_lines []string) !([]string, int, int) {
	// Now extract [LinkModel]...[EndModel] section
	mut lmt := -1
	mut em := -1

	// Locate index of model tag start and stop.
	for i, l in t_lines {
		if l.contains(cst.link_model_tag) {
			lmt = i
		}
		if l.contains(cst.end_model) {
			em = i
		}
	}

	if lmt == -1 || em == -1 {
		return error('${cst.link_model_tag} or ${cst.end_model} tags not found in template file. ${@FILE_LINE}')
	}

	if lmt >= em {
		return error('${cst.link_model_tag} or ${cst.end_model} order not respected in template file. ${@FILE_LINE}')
	}

	// Copy Link model for later use. +1 to skip [LinkModel] tag
	link_model := t_lines[lmt + 1..em].clone()

	return link_model, lmt, em
}

pub enum Location {
	blog_dir
	topic_dir
	outside
}

// where_am_i indicates if current working directory is Blog's root, Topic'dir or somewhere else.
pub fn where_am_i() Location {
	blog := os.exists(cst.blog_file)
	topic := os.exists(cst.topic_file)

	if (blog || topic) == false {
		return .outside
	}

	if (blog && topic) == true {
		eprintln(term.red('Error: Found both ${cst.blog_file} and ${cst.topic_file} in the same directory. This is completely abnormal situation!'))
		panic('Exiting program. ${@FILE_LINE}')
	}

	if blog {
		return .blog_dir
	} else {
		return .topic_dir
	}
}

// Type alias used with load_transform_text_file function. The filtering function can transform, reject or
// keep untouched parameter string.
pub type Op = fn (string) ?string

// del_empty_and_comments to use as closure parameter with load_transform_text_file.
// The method removes all empty lines and trailing symbols after #.
pub fn del_empty_and_comments(str string) ?string { // Filtering closure. Remove commentary, rejects empty strings.
	mut s := str.trim_left(' ')
	if p := s.index('#') {
		s = s.substr(0, p) // remove all after comment
	}
	return if s.len == 0 { none } else { s }
}

// load_transform_text_file loads all lines from given text file, and apply func to each
// of them. Rejection, transformation are done in the func closure
pub fn load_transform_text_file(f string, func ?Op) ![]string {
	mut file := os.open(f) or { return error('opening file : ${err} ${@FILE_LINE}') }
	defer {
		file.close()
	}

	mut ret := []string{} // []string is array type, []string{} allocates an empty array.
	mut b_reader := io.new_buffered_reader(reader: file)
	for {
		mut s := b_reader.read_line() or { break }

		// Apply func feature on line if any.
		if func != none {
			if after_func := func(s) { // Option unwrapping if any.
				ret << after_func
			}
		} else {
			ret << s
		}
	}
	return ret
}

// write_all write in f file, lines strings
pub fn write_all(f string, lines []string) ! {
	mut file := os.open_file(f, 'w+', os.s_iwusr | os.s_irusr) or {
		return error('Unable to write $${f}: ${err}, ${@FILE_LINE}')
	}

	defer {
		file.close()
	}

	for l in lines {
		file.writeln(l) or { return error('Unable to write ${f}: ${err}, ${@FILE_LINE}') }
	}
}

pub fn exec(cmd string, verbose bool, dry_run bool) ! {
	// Extract exe name, first word in command.
	mut exe_name := cmd.trim_left(' ')
	if i := cmd.index(' ') {
		exe_name = cmd.substr(0, i)
	}

	if verbose {
		println('Command: "${term.yellow(cmd)}".')
	}

	if !dry_run {
		ret := os.execute(cmd)

		if ret.exit_code < 0 {
			return error('${ret.output} : error code =  ${ret.exit_code}. ${@LOCATION}')
		} else {
			if ret.exit_code == 127 { // Command not found
				return error('${exe_name} command not found. Is it installed and in your \$PATH ? ${@FILE_LINE}')
			} else {
				if ret.exit_code == 0 {
					if verbose {
						println(term.bright_green('${ret.output}'))
						println(term.bright_green('${exe_name} command successful.'))
					}
				} else {
					// An error occurs´
					return error('${exe_name} returns ${ret.exit_code} :\n' + term.red(ret.output) +
						'\nCheck ${exe_name} return code for more information. ${@FILE_LINE}')
				}
			}
		}
	} else {
		println('Command(s) was skipped (-dry) option.')
	}
}
