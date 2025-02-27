module commands

import term
import util
import structures { Blog, Topic }
import constants as cst
import os

// Add structure, implementing Command interface.
struct Add implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Init Command.
pub fn Add.new() Command {
	return Add{
		kind:    .command
		name:    'add'
		desc:    'Creates a new topic (run from inside the blog directory).'
		help:    Add.help()
		arg_min: 1
		arg_max: 1
		exec:    add
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
    -Update ${cst.blog_file} in blog\'s directory.
    -Create ${cst.style_file} in topic\'s directory.
    -Create ${cst.pushs_list_template_file} in topic\'s directory.
    -Create ${cst.push_template_file} in topic\'s directory.
    -Create ${cst.push_style_template_file} in topic\'s directory.
    -Generate ${cst.topics_list_filename} HTML file, with links to differents topics.
'
}

// add command feature are implemented here. The parameters number has been checked before call.
fn add(p []string) ! {
	title := p[0]
	mut blog := Blog.load() or { return error('Unable to load_blog_file: ${err}. ${@LOCATION}') }

	for item in blog.topics {
		if item.title == title {
			return error(' The topic "${title}" already exists in ${cst.blog_file} file.')
		}
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

	println('You should now customize your local style and post list template ' +
		term.blue('${dir}${os.path_separator}${cst.style_file}') + ' and ' +
		term.blue('${dir}${os.path_separator}${cst.pushs_list_template_file}') + '.')
	blog.generate_topics_list_html()!

	println('Don\'t forget to perform ${term.yellow('vssg sync')} before sending an article. If a topic is not sent, pushes inside are not visibles.')
	return
}
