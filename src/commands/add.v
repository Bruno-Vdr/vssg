module commands

import term
import util
import structures { Blog, Topic }
import constants as cst
import os

// Add structure, implementing Command interface.
struct Add implements Command {
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

${term.red('Warning:')} This command must be launched from within blog directory.

The add command creates a new topic inside the blog:
    -Create a directory based on hashed(${term.blue('topic')}).
    -Update/create ${cst.topic_file} file in hashed directory.
    -Update ${cst.blog_file} in blog\'s directory.
    -Create ${cst.style_file} in topic\'s directory.
    -Create ${cst.pushs_list_template_file} in topic\'s directory.
    -Create ${cst.push_template_file} in topic\'s directory.
    -Create ${cst.push_style_template_file} in topic\'s directory.
'
}

// add command feature are implemented here. The parameters number has been checked before call.
fn add(p []string) ! {
	title := p[0]
	mut blog := Blog.load() or { return error('Unable to load_blog_file: ${err}, ${@FILE_LINE}') }

	if title in blog.topics {
		return error(' The topic already exists in ${cst.blog_file} file. ${@FILE_LINE}')
	}

	dir := util.obfuscate(title)
	println('Creating topic: "' + term.yellow(title) + '" in ' + term.blue(dir) + ' directory.')

	// Create destination directory.
	if os.exists('${dir}') {
		return error('unable to create ${dir} : The directory already exists.  ${@FILE_LINE}')
	}
	os.mkdir('./${dir}', os.MkdirParams{0o755}) or {
		return error('mkdir ${dir} failed: ${err},  ${@FILE_LINE}')
	}

	blog.add_topic(title)
	topic := Topic.new(title)
	topic.save(topic.directory)! // Add command is launched from Blog directory, but topic is saved inside topic dir.
	blog.save()!

	// Create style into Topic directory. File is embedded in constant.v file.
	util.create_default_file('./', '${dir}${os.path_separator}${cst.style_file}', cst.pushs_list_style_css.to_string()) or {
		return error('Creation of ${cst.style_file} fails: ${err}. ${@FILE_LINE}')
	}

	// Create default posts list into Topic directory. File is embedded in constant.v file.
	util.create_default_file('./', '${dir}${os.path_separator}${cst.pushs_list_template_file}',
		cst.pushs_list_template.to_string()) or {
		return error('Creation of ${cst.pushs_list_template_file} fails: ${err}. ${@FILE_LINE}')
	}

	// Create post.template file
	util.create_default_file('./', '${dir}${os.path_separator}${cst.push_template_file}',
		cst.push_template.to_string()) or {
		return error('Creation of ${cst.push_template_file} fails: ${err}. ${@FILE_LINE}')
	}

	// Create post_style.css
	util.create_default_file('./', '${dir}${os.path_separator}${cst.push_style_template_file}',
		cst.push_style_css.to_string()) or {
		return error('Creation of ${cst.push_style_template_file} fails: ${err}. ${@FILE_LINE}')
	}

	println('You should now customize your local style and post list template ' +
		term.blue('${dir}${os.path_separator}${cst.style_file}') + ' and ' +
		term.blue('${dir}${os.path_separator}${cst.pushs_list_template_file}') + '.')
	blog.generate_topics_list_html()!

	return
}
