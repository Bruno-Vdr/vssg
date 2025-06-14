module commands

import term
import util
import structures { Blog, Topic }
import constants as cst
import os

// Add structure, implementing Command interface.
struct Add implements Command {
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

// new builds a Init Command.
pub fn Add.new() Command {
	return Add{
		kind:       .command
		validity:   .blog_dir
		run_locked: true
		name:       'add'
		desc:       'Creates a new topic (run from inside the blog directory).'
		help:       Add.help()
		arg_min:    1
		arg_max:    1
		exec:       add
	}
}

// help return the complete description of the command.
fn Add.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('add')} ${term.blue('topic')}

${term.rgb(255,
		165, 0, 'Warning:')} This command must be launched from within blog directory.

The add command creates a new topic inside the blog:
    -Create a directory based on hashed(${term.blue('topic')}).
    -Update/create ${cst.topic_file} file in hashed directory.
    -Update ${term.blue(cst.blog_file)} in blog\'s directory.
    -Create ${cst.style_file} in topic\'s directory.
    -Create ${cst.pushs_list_template_file} in topic\'s directory.
    -Create ${cst.push_template_file} in topic\'s directory.
    -Create ${cst.push_style_template_file} in topic\'s directory.
    -Generate ${cst.topics_list_filename} HTML file, with links to differents topics.
    -Generate in new topic directory a ${cst.pushs_list_filename} (Empty) html page with pushes list.
'
}

// add command feature are implemented here. The parameters number has been checked before call.
fn add(p []string, run_locked bool) ! {
	title := p[0]
	mut blog := Blog.load() or { return error('Unable to load_blog_file: ${err}. ${@LOCATION}') }

	if blog.exists(title) {
		return error(' The topic "${title}" already exists in ${cst.blog_file} file.')
	}

	dir := util.obfuscate(title)
	println('Creating topic: "' + term.yellow(title) + '" in ' + term.blue(dir) + ' directory.')

	// Create destination directory.
	if os.exists('${dir}') {
		return error('unable to create ${dir} : The directory already exists.')
	}
	os.mkdir('./${dir}', os.MkdirParams{0o755}) or {
		return error('mkdir ${dir} failed: ${err},  ${@LOCATION}')
	}

	blog.add_topic(title)
	topic := Topic.new(title)
	topic.save(topic.directory)! // Add command is launched from Blog directory, but topic is saved inside topic dir.
	blog.save()!

	deploy_topics_templates(dir)! // in deploy.v

	// Topic dir has been created, but pushes list page doesn't exists. Create on to avoid 404 Error from Topic list page.
	// This must be done after templates deployment.
	gen_empty_push_list(topic.directory)!

	println('You should now customize your local style and post list template ' +
		term.blue('${dir}${os.path_separator}${cst.style_file}') + ' and ' +
		term.blue('${dir}${os.path_separator}${cst.pushs_list_template_file}') + '.')
	blog.generate_topics_list_html()!

	println('Don\'t forget to perform ${term.yellow('vssg sync')} before sending an article. If a topic is not sent, pushes inside are not visibles.')
	return
}

// gen_empty_push_list : Go in topic direcory and force generation of (empty) push list page.
fn gen_empty_push_list(dir string) ! {
	os.chdir(dir)!
	t := Topic.load()!
	t.generate_pushes_list_html()!
	os.chdir('..')!
}
