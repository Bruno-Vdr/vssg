module commands

import term
import util
import constants as cst
import os

// Deploy structure, implementing Command interface.
struct Deploy implements Command {
	kind    CommandType
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Deploy Command.
pub fn Deploy.new() Command {
	return Deploy{
		kind:    .helper
		name:    'deploy'
		desc:    'Deploys local CSS/HTML templates.'
		help:    Deploy.help()
		arg_min: 0
		arg_max: 0
		exec:    deploy
	}
}

// help give a complete description of the command, including parameters.
fn Deploy.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('deploy')}

${term.rgb(255,165, 0, 'Warning:')} This command must be launched from blog or topic directory.

The deploy emit local  (embedded) templates files in the current directory accordingly to current blog or topic position.
Note: All files are deployed by the command.
'
}

// deploy command feature are implemented here. The parameters number has been checked before call.
fn deploy(p []string) ! {
	match util.where_am_i() {
		.blog_dir {deploy_blog_templates('./')!}
		.topic_dir {deploy_topics_templates('./')!}
		.outside {return error('Command must be called from blog or topic directory.')}
	}
}

// deploy_blog_templates emit template files for topics list HTML page.
pub fn deploy_blog_templates(path string)! {
	// Generate a style file that will be used to generate topic lists index.htm page.
	// This template file is embedded in constants.v file.
	util.create_default_file(path, cst.style_file, cst.topics_list_style_css.to_string()) or {
		return error('creating topic list style css file fails: ${err}. Command init, ${@LOCATION}')
	}

	// Generate a template file that will be used to generate topic lists index.htm page.
	// This template file is embedded in constants.v file.
	util.create_default_file(path, cst.topics_list_template_file, cst.topics_list_template.to_string()) or {
		return error('creating topic list template file fails: ${err}. Command init, ${@LOCATION}')
	}
}

// deploy_topics_templates emit template files for topics list HTML page.
pub fn deploy_topics_templates(dir string)! {
	// Create push_list style into Topic directory. File is embedded in constant.v file.
	util.create_default_file('./', '${dir}${os.path_separator}${cst.style_file}', cst.pushs_list_style_css.to_string()) or {
		return error('Creation of ${cst.style_file} fails: ${err}. ${@LOCATION}')
	}

	// Create default push_list into Topic directory. File is embedded in constant.v file.
	util.create_default_file('./', '${dir}${os.path_separator}${cst.pushs_list_template_file}',
		cst.pushs_list_template.to_string()) or {
		return error('Creation of ${cst.pushs_list_template_file} fails: ${err}. ${@LOCATION}')
	}

	// Create push.template file
	util.create_default_file('./', '${dir}${os.path_separator}${cst.push_template_file}',
		cst.push_template.to_string()) or {
		return error('Creation of ${cst.push_template_file} fails: ${err}. ${@LOCATION}')
	}

	// Create push_style.css
	util.create_default_file('./', '${dir}${os.path_separator}${cst.push_style_template_file}',
		cst.push_style_css.to_string()) or {
		return error('Creation of ${cst.push_style_template_file} fails: ${err}. ${@LOCATION}')
	}
}
