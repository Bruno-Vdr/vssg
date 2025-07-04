module commands

import term
import util
import constants as cst
import os

// Deploy structure, implementing Command interface.
struct Deploy implements Command {
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

// new builds a Deploy Command.
pub fn Deploy.new() Command {
	return Deploy{
		kind:       .helper
		validity:   .blog_or_topic_dir
		run_locked: false
		name:       'deploy'
		desc:       'Deploys local CSS/HTML templates.'
		help:       Deploy.help()
		arg_min:    0
		arg_max:    0
		exec:       deploy
	}
}

// help give a complete description of the command, including parameters.
fn Deploy.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('deploy')}

${term.rgb(255,
		165, 0, 'Warning:')} This command must be launched from blog or topic directory.

The deploy command emits local  (embedded) templates files in the current directory accordingly to current blog or topic position.
Note: All files are deployed by the command.
'
}

// deploy command feature are implemented here. The parameters number has been checked before call.
fn deploy(p []string, run_locked bool) ! {
	if util.where_am_i() == .blog_dir {
		deploy_blog_templates('./')!
	} else { // .topic_dir
		deploy_topics_templates('./')!
	}
}

// deploy_blog_templates emit template files for topics list HTML page.
pub fn deploy_blog_templates(path string) ! {
	// Generate a style file that will be used to generate topic lists index.htm page.
	// util.create_default_file(path, cst.style_file, cst.topics_list_style_css.to_string()) or {
	// 	return error('creating topic list style css file fails: ${err}. Command init, ${@LOCATION}')
	// }
	util.deploy_template(cst.topics_list_style_template_file, './', '${path}${os.path_separator}${cst.style_file}' ) or {
		return error('util.deploy_template: ${err}. [${@FILE_LINE}]')
	}

	// Generate a template file that will be used to generate topic lists index.htm page.
	util.deploy_template(cst.topics_list_template_file, './', '${path}${os.path_separator}${cst.topics_list_template_file}' ) or {
		return error('util.deploy_template: ${err}. [${@FILE_LINE}]')
	}
}

// deploy_topics_templates emit template files for topics list HTML page.
pub fn deploy_topics_templates(dir string) ! {
	// Create push_list style into Topic directory. File is embedded in constant.v file.
	util.deploy_template(cst.pushs_list_style_template_file, './', '${dir}${os.path_separator}${cst.style_file}' ) or {
		return error('util.deploy_template: ${err}. [${@FILE_LINE}]')
	}

	// Create default push_list into Topic directory. File is embedded in constant.v file.
	util.deploy_template(cst.pushs_list_template_file, './', '${dir}${os.path_separator}${cst.pushs_list_template_file}' ) or {
		return error('util.deploy_template: ${err}. [${@FILE_LINE}]')
	}

	// Create push.tmpl
	util.deploy_template(cst.push_template_file, './', '${dir}${os.path_separator}${cst.push_template_file}' ) or {
		return error('util.deploy_template: ${err}. [${@FILE_LINE}]')
	}

	// Create push_style.tmpl
	util.deploy_template(cst.push_style_template_file, './', '${dir}${os.path_separator}${cst.push_style_template_file}' ) or {
		return error('util.deploy_template: ${err}. [${@FILE_LINE}]')
	}
}
