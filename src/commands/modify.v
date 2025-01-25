module commands

import term
import strconv
import structures { Post, PostSummary, Topic }
import util
import constants as cst
import os

// Modify structure, implementing Command interface.
struct Modify implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Modify Command.
pub fn Modify.new() Command {
	return Modify{
		name:    'modify'
		desc:    'Modify an existing push.'
		help:    Modify.help()
		arg_min: 2
		arg_max: 2
		exec:    modify
	}
}

// help give a complete description of the command, including parameters.
fn Modify.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('modify')} ${term.magenta('id')} ${term.blue('push_text_file')}

${term.red('Warning:')} This command must be launched from within topic directory.

The modify command modifies the push, identified by ${term.magenta('id')} with the given push file.
To get the push\'s ${term.magenta('id')}, just do "${term.green('vssg')} ${term.yellow('show')}"
Modify is used to modify text, date, title or images of an already existing push.
    -The .topic file is updated accordingly to ${term.blue('push_text_file')}
    -The push HTML code is rebuilt.
    -The HTML topic page with link to pushes is also rebuilt.
'
}

// modify command feature are implemented here. The parameters number has been checked before call.
// param[0] =  ID as ASCII string
// param[1] = push file
fn modify(param []string) ! {
	id := strconv.atoi(param[0]) or { return error('Cannot convert "${param[0]}" to ID.') }
	post_filename := param[1]

	// Check post_filename, existing, loadable
	mut post := Post.load(post_filename)!

	// Load .topic
	mut topics := Topic.load()!

	// Verify that post exists in post list of topic by ID
	for mut p in topics.posts {
		if p.id != u64(id) {
			continue
		}

		// Topic has been found.
		lnk := if post.link_label.len == 0 {
			post.title
		} else {
			post.link_label
		}

		ps := PostSummary{
			...p // Struct update syntax : identical to p by default.
			title: lnk       // May change
			date:  post.date // May change
		}

		// Report id and date that are not provided by post file.
		post.set_id(p.id)

		// Replace new PostSummary by updated one.
		p = ps

		topics.save('./')!

		// Build HTML
		topics.generate_pushes_list_html()!
		println('Re-generated pushes links (${cst.pushs_list_filename}).')

		// Environment var for Image dir is mandatory.
		img_dir := util.get_img_post_dir() or {
			return error('${cst.img_src_env} is not set. Fix it with: export ${cst.img_src_env}=/home/....')
		}
		// Build HTML page of the post.
		generate_push_html(p.dir, &post, img_dir)!
		println('Re-generated push file in ${p.dir}${os.path_separator}${cst.push_filename}.')
		return
	}

	return error('push with id ${id} not found.')
}
