module commands

import term
import structures { Blog }
import util
import constants as cst
import os

// Drop structure, implementing Command interface.
struct Drop implements Command {
	kind    CommandType
	validity RunFrom
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Drop Command.
pub fn Drop.new() Command {
	return Drop{
		kind:    .command
		validity: .blog_dir
		name:    'drop'
		desc:    'Drops a complete topic with its pushes (if any).'
		help:    Drop.help()
		arg_min: 1
		arg_max: 2
		exec:    drop
	}
}

// drop give a complete description of the command, including parameters.
fn Drop.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('drop')} topic_title [-f]

${term.rgb(255,
		165, 0, 'Warning:')} This command must be launched from within blog directory.

The drop command deletes a complete topic with all of its pushes, if any. By default the commands appends the
${cst.dir_removed_suffix} suffix to the directory. By adding the ${term.red('-f')} the
directory will be definitely removed.

    -It also updates ${cst.blog_file} accordingly.
    -Rebuilt the HTML links to topic page, "${cst.topics_list_filename}".

To get a list of topics, run "vssg show" from blog\'s root directory."
'
}

// drop command feature are implemented here. The parameters number has been checked before call.
fn drop(p []string) ! {
	mut force_delete := false
	mut title := p[0]

	if p.len == 2 {
		if '-f' in p {
			force_delete = true
		} else {
			return error('Unknown parameter in "${p[0]}" or "${p[1]}".')
		}
		title = if p[0] == '-f' { p[1] } else { p[0] }
	}

	mut blog := Blog.load() or { return error('Unable to load_blog_file: ${err}. ${@LOCATION}') }
	blog.delete(title)!
	println('Found Topic named "${title}".')
	blog.save()!

	dir := util.obfuscate(title)
	if os.exists(dir) {
		if force_delete {
			os.rmdir_all(dir) or {
				return error('Could not remove directory "${dir}": ${err}. ${@LOCATION}')
			}
			println('Associated directory "${dir}" was deleted.')
		} else {
			os.mv(dir, dir + cst.dir_removed_suffix) or {
				return error('Could not remove directory "${dir}": ${err} ${@LOCATION}')
			}
			println('Associated directory "${dir}" was renamed ${dir}${cst.dir_removed_suffix}.')
		}

		// Now Rebuild topic list HTML page
		blog.generate_topics_list_html()!
	} else {
		println('Associated directory "${dir}" was not found.')
	}

	println('You can now use "${term.green('vssg')} ${term.yellow('sync')}" to publish.')
	println('Please also considere using "${term.green('vssg')} ${term.yellow('bend')}" to a valid URL (drop might break bend).')
}
