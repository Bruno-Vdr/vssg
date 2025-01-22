module util

import os
import time
import constants as cst
import term
import hash.fnv1a

pub fn parse_topic_values(label string, s string) ?(string, i64) {
	if s.starts_with(label) {
		value := s.find_between('"', '"')
		dte := s.find_between('[', ']')
		return if value.len == 0 { none } else { value, dte.i64() }
	}

	return none
}

pub fn parse_name_value(label string, s string) ?string {
	if s.starts_with(label) {
		value := s.find_between('"', '"')
		return if value.len == 0 { none } else { value }
	}

	return none
}

pub fn parse_post_values(label string, s string) ?(u64, string, i64, string) {
	if s.starts_with(label) {
		id := s.find_between('[id:', ']').u64()
		title := s.find_between('[title:', ']')
		date := s.find_between('[date:', ']').i64()
		dir := s.find_between('[dir:', ']')

		if title.len == 0 {
			return none
		} else {
			return id, title, date, dir
		}
	}
	return none
}

pub fn create_default_file(path string, filename string, multiline string) ! {
	println('Creating ${filename}  file in ' + term.blue('${path}'))
	mut file := os.open_file('${path}${os.path_separator}${filename}', 'w+', os.s_iwusr | os.s_irusr) or {
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

// Static method that obfuscate a topic name
pub fn obfuscate(title string) string {
	return fnv1a.sum64_string(title).hex()
}
