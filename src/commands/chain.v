module commands

import term
import util
import constants as cst
import structures { Topic }
import os

// Chain structure, implementing Command interface.
struct Chain implements Command {
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

// new builds a Chain Command.
pub fn Chain.new() Command {
	return Chain{
		kind:       .command
		validity:   .topic_dir
		run_locked: false
		name:       'chain'
		desc:       'Chains different pushes of a same topic together with previous and next links.'
		help:       Chain.help()
		arg_min:    0
		arg_max:    0
		exec:       chain
	}
}

// help give a complete description of the command, including parameters.
fn Chain.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('chain')}

${term.rgb(255, 165,
		0, 'Warning:')} This command must be launched from within topic directory.

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
fn chain(params []string, run_locked bool) ! {
	topics := Topic.load()!
	pst := topics.get_posts_number()
	if pst == 0 {
		return error('The topic "${topics.title}" does not contain any push.')
	}
	println('Chaining "${topics.title}" : ${pst} pushes found.')

	lst := topics.get_posts().values()
	for id, ps in lst {
		prev_id := if id == 0 { none } else { int(lst[id - 1].id) }
		next_id := if id == lst.len - 1 { none } else { int(lst[id + 1].id) }

		mut prev_title := ''
		if prev_id != none {
			prev_title = lst[id - 1].title
		}

		mut next_title := ''
		if next_id != none {
			next_title = lst[id + 1].title
		}

		prev_lnk := generate_link(prev_id, .previous, prev_title)
		next_lnk := generate_link(next_id, .next, next_title)

		filename := '${cst.push_dir_prefix}${ps.id}${os.path_separator}${cst.push_filename}'

		mut lines := util.load_transform_text_file(filename, none)!
		p, n := update_lnk(mut lines, prev_lnk, next_lnk)
		if n == false {
			println('${term.rgb(255, 165, 0, 'Warning:')} ${cst.lnk_next_tag} was not found in ${filename}.')
		}
		if p == false {
			println('${term.rgb(255, 165, 0, 'Warning:')} ${cst.lnk_prev_tag} was not found in ${filename}.')
		}

		if p || n {
			util.write_all(filename, lines)!
			println('${term.blue(filename)} successfully chained.')
		} else {
			println('${term.blue(filename)} skipped as previous/next links marker were not found.')
		}
	}

	println('You can now use "${term.green('vssg')} ${term.yellow('sync')}" to publish.')
}

// generate_link builds a HTML link to previous or next push, returned as string.
fn generate_link(to ?int, kind LnkType, title string) string {
	// href style is used as HTML On/Off button to show and hide the link.
	//<vssg-lnk-prev><a href="../push_2/index.html">Prev Push</a></vssg-lnk-prev> ON
	//<vssg-lnk-prev><a style="display: none;">Prev Push</a></vssg-lnk-prev>  OFF

	href := if to != none {
		bnd_title := if title.len <= cst.max_lnk_label_len {
			title
		} else {
			title.substr(0, cst.max_lnk_label_len - 3) + '...'
		}
		prv, nex := util.get_prev_next_labels()
		label := if kind == .previous { prv } else { nex }
		style := if kind == .previous { 'style="float:left;" ' } else { 'style="float:right;"' }
		'<a href="..${os.path_separator}${cst.push_dir_prefix}${to}${os.path_separator}${cst.push_filename}" ${style}><button  style="font-size: medium; font-weight: bolder;">${
			label + '<br>' + bnd_title}</button></a>'
	} else {
		'<a style="visibility: hidden;"></a>'
	}

	return match kind {
		.next {
			cst.lnk_next_tag + href + cst.next_tag_close
		}
		.previous {
			cst.lnk_prev_tag + href + cst.prev_tag_close
		}
	}
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
