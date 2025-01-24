module structures

import io
import os
import time
import constants as cst

pub struct Section {
pub:
	name string
	code []string
}

pub struct Post {
pub:
	filename   string    // Source file.
	title      string    // Post's title
	poster     string    // Post's Poster (Thumbnail or full image)
	link_label string    // Link's label toward the post.
	sections   []Section // Post core
	date       i64       // Creation date (Seconds since Epoque)
pub mut:
	id u64 // Unique id in topics
}

// load allows to build Post structure from the given file.
// The given file must follow the expected format.
pub fn Post.load(filename string) !Post {
	lines := load_all(filename)!
	return parse_post(lines, filename)!
}

// Fix unique id (in this topic) of the post.
pub fn (mut p Post) set_id(id u64) {
	p.id = id
}

// load_all loads a complete text file, line by line and rejecting all data
// after '#' comment symbol. Empty lines are also rejected. Leading spaces
// are removed too.
fn load_all(filename string) ![]string {
	mut lines := []string{} // []string is array type, []string{} declares an empty array.
	mut file := os.open(filename) or {
		return error('failed loading file "${filename}": ${err}, ${@FILE_LINE}')
	}

	defer {
		file.close()
	}

	// Load all given file content excepted comments. Leading spaces are also removed.
	mut b_reader := io.new_buffered_reader(reader: file)
	for {
		mut line := b_reader.read_line() or { break }

		// Remove empty lines and comments # bla bla...
		line = line.trim_left(' ')
		if !line.starts_with('#') && line.len > 0 {
			lines << line
		}
	}
	return lines
}

// parse_post retrieve Post data from relevant lines.
// The file format is very strict:
// [title: My title]	Cannot be empty
// [poster: Image.png] Can be empty
// [link label: The link] Can be empty, filled with title then
// [date:DD/MM/YYYY kk:mm]
// [section:Name]
// start of post tag.
// [section:...]
// ...
fn parse_post(lines []string, source_file string) !Post {
	mut index := 0
	mut title := ''
	mut poster := ''
	mut link_label := ''
	mut unix_date := i64(0)
	mut sections := []Section{}

	// Parse first line: [title: Here is my Title !]
	if lines.len > index {
		title = parse_line(lines[index], '[title:', ']')!
		if title.len == 0 {
			return error('Post title is empty. [${@FILE_LINE}]')
		}
		index++
	}

	// Parse next line: [poster:Poster.png]
	if lines.len > index {
		poster = parse_line(lines[index], '[poster:', ']')! // Section must exist, but can be empty
		index++
	}

	// Parse next line: [link label: Here is my Title !]
	if lines.len > index {
		link_label = parse_line(lines[index], '[link label:', ']')!
		if link_label.len == 0 {
			link_label = title // Link label will be identical to post title.
		}
		index++
	}

	// Parse next line: [date:]
	if lines.len > index {
		date_str := parse_line(lines[index], '[date:', ']')!
		if date_str.len == 0 {
			// No date provided, use now()
			unix_date = time.ticks() / 1000
		} else {
			date := time.parse_format(date_str, cst.blog_date_format) or {
				return error('Unable to parse date in ${date_str}, expected format is ${cst.blog_date_format}. [${@FILE_LINE}]')
			}
			unix_date = date.unix()
		}

		index++
	}

	// Parse next line: [section:]
	for index < lines.len {
		mut code := []string{}

		// Here we should find a Section.
		name := parse_line(lines[index], '[section:', ']') or {
			return error('[section:xxx] expected here, but find ${lines[index]}. [${@FILE_LINE}]')
		}
		index++

		// Parse section lines
		for index < lines.len {
			if _ := parse_line(lines[index], '[section:', ']') {
				index-- // This line must be reparsed in outer loop
				break // Leave for inner loop
			}
			code << lines[index]
			index++
		}
		// All lines are parsed
		sections << Section{
			name: name
			code: code
		}

		index++
	}

	// println('Parsed post, find ${sections.len} sections:\n ${sections}')

	return Post{
		filename:   source_file
		title:      title
		poster:     poster
		link_label: link_label
		sections:   sections
		date:       unix_date
	}
}

//  parse_line will retrieve text between open_token and close_token.
// The text can be empty e.g. a link label not filled will use title as label.
fn parse_line(line string, open_token string, close_token string) !string {
	if line.starts_with(open_token) && line.contains(close_token) {
		title := line.find_between(open_token, close_token)
		return title
	}

	return error('failed parsing "${line}", it does not start with "${open_token}" or close with "${close_token}". [${@FILE_LINE}]')
}
