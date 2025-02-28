module commands

import term
import os
import encoding.base64 as stdbase64

// Base64 structure, implementing Command interface.
struct Base64 implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Base64 Command.
pub fn Base64.new() Command {
	return Base64{
		kind:    .helper
		name:    'base64'
		desc:    'Base64 (hash) the given string.'
		help:    Base64.help()
		arg_min: 1
		arg_max: 1
		exec:    base64
	}
}

// help give a complete description of the command, including parameters.
fn Base64.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('base64')} ${term.blue('filename')}

The base64 command converts given (image) file to base64 string file. It allows images to be embeded in HTML
page, without needed additional file.
'
}

// base64 command feature are implemented here. The parameters number has been checked before call.
fn base64(p []string) ! {
	filename := p[0]
	if !os.exists(filename) {
		return error('The file "${term.blue(filename)}" does not exists.')
	}

	dot_pos := filename.last_index('.') or {
		return error('Cannot find filename extension in filename "${filename}"')
	}

	if filename.len - dot_pos <= 1 {
		return error('Filename has no extension "${filename}"')
	}

	extension := filename.substr(dot_pos + 1, filename.len)

	// Open file
	mut input_file := os.open_file(filename, 'r') or {
		return error('cannot open "${filename} ${err}".')
	}

	defer {
		input_file.close()
	}

	// Allocate Approx 64kB buffer for conversion.
	in_buff_size := 65520 // 280*234 ! Must be multiple of 234 (3*78) for clean output
	out_buff_size := 87360 // 65520 * 4/3

	mut in_buff := []u8{len: in_buff_size}
	mut out_buff := []u8{len: out_buff_size}

	println('<img src="data:image/${extension};base64,')
	for {
		byte_read := input_file.read(mut in_buff) or {
			if err !is os.Eof {
				eprintln('Error reading file "${os.args[1]} -> ${err}".')
				return
			} else {
				continue
			}
		}

		// Create a slice that reuse the *same memory* as the parent array.
		slice := unsafe { in_buff[0..byte_read] }
		encoded := stdbase64.encode_in_buffer(slice, out_buff.data)

		s_out := unsafe { out_buff[0..encoded] }
		emit(s_out.bytestr())

		if byte_read < in_buff.len {
			break
		}
	}
	println('">')
}

// emit prints base64 output with 78 chars wide lines.
fn emit(ascii string) {
	columns := 78
	mut start := 0
	for start < ascii.len {
		inc := if start + columns < ascii.len { columns } else { ascii.len - start }
		s := ascii[start..start + inc]
		start += columns
		println(s)
	}
}
