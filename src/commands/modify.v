module commands

import term
import strconv
import structures { Post, PostSummary, Topic }
import util
import constants as cst
import os

// Modify structure, implementing Command interface.
struct Modify implements Command {
	kind    CommandType
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
		kind:    .command
		name:    'modify'
		desc:    'Modifies an existing push.'
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

${term.rgb(255,
		165, 0, 'Warning:')} This command must be launched from within topic directory.
${term.rgb(255,
		165, 0, 'Warning:')} the push_text_file MUST be located in the directory pointed by the environment variable ${term.yellow('VSSG_PUSH_DIR')}.

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
	id := strconv.atou64(param[0]) or {
		return error('Cannot convert "${param[0]}" to unsigned ID.')
	} // int

	push_path := util.get_default_push_dir() or {
		return error('${cst.default_push_dir} is not set. Fix it with: export ${cst.default_push_dir}= ...')
	}
	post_filename := push_path + param[1]

	// Check post_filename, existing, loadable
	mut post := Post.load(post_filename)!

	// Load .topic
	mut topic := Topic.load()!

	// Verify in map that post exists in post list of topic by ID
	if p := topic.posts[id] {
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
		topic.posts[ps.id] = ps

		topic.save('./')!

		// Build HTML topic list
		topic.generate_pushes_list_html()!
		println('Re-generated pushes links (${cst.pushs_list_filename}).')

		// Environment var for Image dir is mandatory.
		img_dir := util.get_img_post_dir() or {
			return error('${cst.img_src_env} is not set. Fix it with: export ${cst.img_src_env}=/home/....')
		}
		// Build HTML page of the post.
		generate_push_html(p.dir, &topic, &post, img_dir)!
		println('Re-generated push file in ${p.dir}${os.path_separator}${cst.push_filename}.')
		println('You can now use "${term.green('vssg')} ${term.yellow('sync')}" to publish or "${term.green('vssg')} ${term.yellow('chain')}" to updates links.')
		return
	}

	// Topic has not been found.
	return error('push with id ${id} not found.')
}
