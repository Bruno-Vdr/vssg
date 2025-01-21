module util

import os
import time
import constants as cst
import term

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

pub fn create_default_file(path string, filename string, multiline string) ! {
	println('Creating ${filename}  file in ' + term.blue('${path}'))
	mut file := os.open_file('${path}${os.path_separator}${filename}', 'w+', os.s_iwusr | os.s_irusr) or {
		return error('os.open_file() fails: ${err}')
	}

	defer {
		file.close()
	}

	file.writeln(multiline) or { return error('file.writeln() fails: ${err}') }
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
