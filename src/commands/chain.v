module commands

import term
import util
import constants as cst
import structures { Topic }
import os

// Chain structure, implementing Command interface.
struct Chain implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Chain Command.
pub fn Chain.new() Command {
	return Chain{
		kind:    .command
		name:    'chain'
		desc:    'Chains different pushes of a same topic together with previous and next links.'
		help:    Chain.help()
		arg_min: 0
		arg_max: 0
		exec:    chain
	}
}

// help give a complete description of the command, including parameters.
fn Chain.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('chain')} string

${term.rgb(255,
		165, 0, 'Warning:')} This command must be launched from within topic directory.

This command will open all pushe from the current topics, and insert (if any) a link to previous and
next push. Its done by patching custom HTML tag in template "${cst.lnk_next_tag}" and "${cst.lnk_prev_tag}".
Order is given by order of push in .topic file.
'
}

enum LnkType {
	next
	previous
}

// chain command feature are implemented here. The parameters number has been checked before call.
fn chain(params []string) ! {
	if util.where_am_i() in [.blog_dir, .outside] {
		return error('This command must be run from a topic directory.')
	}

	topics := Topic.load()!

	if topics.posts.len == 0 {
		return error('The topic "${topics.title}" does not contain any push.')
	}
	println('Chaining "${topics.title}" : ${topics.posts.len} pushes found.')

	lst := topics.posts.values()
	for id, ps in lst {
		prev := if id == 0 { ?int(none) } else { int(lst[id - 1].id) }
		next := if id == lst.len - 1 { ?int(none) } else { int(lst[id + 1].id) }

		prev_lnk := generate_link(prev, .previous)
		next_lnk := generate_link(next, .next)

		filename := '${cst.push_dir_prefix}${ps.id}${os.path_separator}${cst.push_filename}'
		// println('Updating ${filename} - ${ps.title}')
		 println('Prev link= ${prev_lnk}')
		 println('Next link= ${next_lnk}')

		mut lines := util.load_text_file(filename, none)!
		p,n := update_lnk(mut lines, prev_lnk, next_lnk)
		if n == false {
			println('${term.rgb(255, 165, 0, 'Warning:')} ${cst.lnk_next_tag} was not found in ${filename}.')
		}
		if p == false {
			println('${term.rgb(255, 165, 0, 'Warning:')} ${cst.lnk_prev_tag} was not found in ${filename}.')
		}

		util.write_all(filename, lines)!
		println('${term.blue(filename)} successfully chained.')
	}
}

// generate_link builds a HTML link to previous or next push, returned as string.
fn generate_link(to ?int, kind LnkType) string {
	// href style is used as HTML On/Off button to show and hide the link.
	//<vssg-lnk-prev><a href="../push_2/index.html">Prev Push</a></vssg-lnk-prev> ON
	//<vssg-lnk-prev><a style="display: none;">Prev Push</a></vssg-lnk-prev>  OFF
	href := if to != none {
		label := if kind == .previous {'Previous'} else {'Next'}
		style :=if kind == .previous {'style="float : left" '} else {'style="float : right"'}
		'<a href="..${os.path_separator}${cst.push_dir_prefix}${to}${os.path_separator}${cst.push_filename}" ${style}>${label}</a>'
	} else {
		'<a style="display: none;"></a>'
	}

	mut ln := ''
	match kind {
		.next {
			ln = cst.lnk_next_tag + href + cst.next_tag_close
		}
		.previous {
			ln = cst.lnk_prev_tag + href + cst.prev_tag_close
		}
	}
	return ln
}

//  update_lnk replaces previous/next links in given lines.
fn update_lnk(mut lines []string, prev string, next string) (bool, bool) {
	mut found_prev := false
	mut found_next := false

	for mut l in lines {
		if l.contains(cst.lnk_next_tag) && l.contains(cst.next_tag_close) {
			found_next = true
			l = next // replace the whole line with next link.
		}
		if l.contains(cst.lnk_prev_tag) && l.contains(cst.prev_tag_close) {
			found_prev = true
			l = prev // replace the whole line with prev link.
		}
	}

	return found_prev, found_next
}
