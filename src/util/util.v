module util

import os
import time
import constants as cst
import term
import hash.fnv1a
import strconv

// parse_topic_values parses a single line of the following format:
// A start label, a doubled quoted string and a int between []
// topic = "topik" [1737634926] # In directory ./glob/520c837d69349ecc
// Comment, starting at # are ignored.
// Since these files should not be modified by hand, malformed file/line are skipped.
// The function returns an Option rather than a Result.
pub fn parse_topic_values(label string, line string) ?(string, i64) {
	if line.len == 0 {
		return none
	}

	pos := line.index('#') or { line.len }

	s := line.substr_with_check(0, pos) or { line }

	if s.starts_with(label) {
		value := s.find_between('"', '"')
		dte := s.find_between('[', ']')
		return if value.len == 0 || dte.len == 0 { none } else { value, dte.i64() }
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

pub fn create_default_file(path string, output_file string, multiline string) ! {
	println('Creating ${output_file}  file in ' + term.blue('${path}'))
	mut file := os.open_file('${path}${os.path_separator}${output_file}', 'w+', os.s_iwusr | os.s_irusr) or {
		return error('os.open_file() fails: ${err}. [${@FILE_LINE}]')
	}

	defer {
		file.close()
	}

	file.writeln(multiline) or { return error('file.writeln() fails: ${err}. [${@FILE_LINE}]') }
}

pub fn to_blog_date(date i64) string {
	return time.unix(date).custom_format(cst.blog_date_format)
}

pub fn get_img_post_dir() ?string {
	return os.getenv_opt(cst.img_src_env)
}

pub fn get_remote_url() ?string {
	return os.getenv_opt(cst.remote_url)
}

pub fn get_blog_root() ?string {
	return os.getenv_opt(cst.blog_root)
}

// obfuscate obfuscate/mangle a topic name
pub fn obfuscate(title string) string {
	return fnv1a.sum64_string(title).hex()
}
