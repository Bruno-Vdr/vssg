module commands

import util
import term
import os
import constants as cst
import structures { Post, PostSummary, Section, Topic }

// Init structure, implementing Command interface.
struct Push implements Command {
	name    string
	desc    string
	help    string
	arg_min int
	arg_max int
	exec    fn (s []string) ! @[required]
}

// new builds a Init Command.
pub fn Push.new() Command {
	return Push{
		name:    'push'
		desc:    'Push a new article into topic (run from inside the topic directory).'
		help:    Push.help()
		arg_min: 1
		arg_max: 1
		exec:    push
	}
}

// help give a complete description of the command, including parameters.
fn Push.help() string {
	return '
Command: ${term.green('vssg')} ${term.yellow('push')} ${term.blue('push_text_file')}

The push command creates a new push/entry in the ${term.magenta('current topic directory')}:
	-Create a directory named ${cst.push_dir_prefix}xx
	-Create a pictures sub-directory named ${cst.push_dir_prefix}xx${os.path_separator}${cst.pushs_pic_dir}
	-Update/Create the ${cst.topic_file} with new push.
	-Create ${cst.style_file} in new directory ${cst.push_dir_prefix}xx for local customization
	-Generation of HTML push page ${cst.push_filename} based on template {${cst.push_template_file}}
	-Pictures copy to ${cst.push_dir_prefix}xx/${cst.pushs_pic_dir} based on ${term.blue('push_text_file')}
'
}

// push command feature are implemented here. The parameters number has been checked before call.
fn push(p []string) ! {
	post_file := p[0]

	// First, check post_file.
	if !os.exists('${post_file}') {
		return error('Failed loading "${post_file}" : The file does not exist. ${@FILE_LINE}.')
	}

	mut post := Post.load(post_file)!
	mut topics := Topic.load()!
	id := topics.get_next_post_id()
	post.set_id(id)
	path := cst.push_dir_prefix + id.str()

	if os.exists('${path}') {
		return error('failed creating ${path} : The directory already exists. [${@FILE_LINE}]')
	}
	os.mkdir('./${path}', os.MkdirParams{0o755}) or {
		return error('mkdir ${path} fails: ${err}. [${@FILE_LINE}]')
	}
	println('Created push directory: ${term.blue(path)}')

	// Create a sub dir for pictures
	pic_dir := './${path}${os.path_separator}${cst.pushs_pic_dir}'
	os.mkdir(pic_dir, os.MkdirParams{0o755}) or {
		return error('mkdir ${pic_dir} fails: ${err}. [${@FILE_LINE}]')
	}
	println('Created push images sub-directory :  ${term.blue(pic_dir)}')

	// Add post to our structure.
	ps := PostSummary{post.id, post.link_label, post.date, '.${os.path_separator}${cst.push_dir_prefix}${post.id}'}
	topics.posts << ps

	// Save topic file. Post cmd is run from within Topic dir.
	topics.save('./')!

	// Generate style.css for this post -> cp  push_style.css ./post_1/style.css  For further post customization
	os.cp(cst.push_style_template_file, '${path}${os.path_separator}${cst.style_file}') or {
		return error('Unable to copy ${cst.push_style_template_file} in ${path}: ${err}. [${@FILE_LINE}]')
	}

	// Build HTML page of links to posts.
	generate_push_html(path, &post, post_file)!

	println('You can now customize your ' +
		term.blue('${path}${os.path_separator}${cst.style_file}') + ' and ' +
		term.blue('${path}${os.path_separator}${cst.push_filename}') + '.')

	// Now update topics's page containing links to posts.
	return topics.generate_posts_list_html()
}

// generate_push_html generate push HTML code. It also move pictures to push_xx/pictures.
fn generate_push_html(path string, post &Post, push_filename string) ! {
	// Load local post template, and generate post.
	tmpl_lines := os.read_lines(cst.push_template_file) or {
		return error('os.read_lines fails on ${cst.push_template_file} : ${err}. [${@FILE_LINE}]')
	}

	// Check if environment variable provides image sources. If not, post must provide abs name for images.
	img_dir := util.get_img_post_dir() or { '' }
	if img_dir.len == 0 {
		println('${term.bright_yellow(cst.img_src_env)} ${term.red('is not set !')}')
	} else {
		println('${term.bright_yellow(cst.img_src_env)} set to "${term.bright_blue(img_dir)}"')
	}

	// Now create push HTML file
	mut push_file := os.open_file('${path}${os.path_separator}${cst.push_filename}', 'w+',
		os.s_iwusr | os.s_irusr) or {
		return error('Failed opening ${cst.push_filename} : ${err}. [${@FILE_LINE}]')
	}

	defer {
		push_file.close()
	}

	// Copy poster's post into pictures.
	pic_dir := './${path}${os.path_separator}${cst.pushs_pic_dir}'
	mut src := img_dir + os.path_separator + post.poster
	dst := pic_dir + os.path_separator + post.poster
	os.cp(src, dst) or {
		return error('Unable to copy poster ${src} in ${dst}: ${err}. [${@FILE_LINE}]\n[Hint: is your ${cst.img_src_env} environment variable set ?]')
	}

	// Initialize dynamic vars.
	mut dyn := util.DynVars.new()
	dyn.add('@title', post.title)
	dyn.add('@poster', cst.pushs_pic_dir + os.path_separator + post.poster)
	dyn.add('@date', util.to_blog_date(post.date))

	// Build map to easily retrieve section by name
	mut m := map[string]Section{}
	for section in post.sections {
		m[section.name] = section
	}

	for i,li in tmpl_lines {
		line := li.trim_space()

		mut section_name := ''
		if line.starts_with('[section:') && line.ends_with(']') {
			section_name = line.find_between('[section:', ']')
			section := m[section_name] or {
				// return error('Unknown section "${section_name}" in template file "${cst.push_template}". [${@FILE_LINE}]')
				println(term.red('Warning: Found section "${section_name}" line ${i+1} in template ${cst.push_template_file} this is not filled in ${push_filename}.'))
				break
			}

			// Emit section core into the file
			for l in section.code {
				if im, com := search_for_image(l) {
					// We parsed an image tag. Emit it !
					img_src := img_dir + os.path_separator + im
					img_dst := path + os.path_separator + cst.pushs_pic_dir + os.path_separator + im
					img_src_html := cst.pushs_pic_dir + os.path_separator + im

					// Copy image source to post's pictures destination.
					os.cp(img_src, img_dst) or {
						// Just signal copy error, do not interrupt HTML generation.
						eprintln(term.bright_red('Unable to copy image ${img_src} : ${err}. [${@FILE_LINE}]'))
						eprintln('[Hint: did you set your environment variable ${term.bright_yellow(cst.img_src_env)} ?]')
					}

					// Emit HTML <img> tag
					push_file.writeln('<img src="${img_src_html}">') or {
						return error('Failed writing file. ${err}. [${@FILE_LINE}]')
					}

					// Emit comment (if any)
					if com.len > 0 {
						push_file.writeln('<h6>${com}</h6>') or {
							return error('Failed writing file. ${err}. [${@FILE_LINE}]')
						}
					}
				} else {
					// Emit line as is after substituting dynamic vars (if any).
					substitute := dyn.substitute(l) or {
						return error('Failure in push file : ${err}. [${@FILE_LINE}]')
					}
					push_file.writeln(substitute) or {
						return error('Failed writing file. ${err}. [${@FILE_LINE}]')
					}
				}
			}
		} else {
			// Not a special section, emit line as is after substituting dynamic vars (if any).
			substitute := dyn.substitute(line) or {
				return error('Wrong template ${cst.push_template} : ${err}. [${@FILE_LINE}]')
			}
			push_file.writeln(substitute) or {
				return error('Failed writing file. ${err}. [${@FILE_LINE}]')
			}
		}
	}
}

// search_for_image tries to parse and image tag in the given string. Returns it if any
// Expected format: [img:IMG_NAME.GFX:"A brilliant optional comment"]
// Comment-less tag: [img:IMG_NAME.GFX]
fn search_for_image(l string) ?(string, string) {
	// Image is single statement in a line.
	if !l.starts_with('[img:') || !l.ends_with(']') {
		return none
	}

	c_sta := l.index(':"') or { -1 }
	c_sto := l.index('"]') or { -1 }

	if c_sta != -1 && c_sto != -1 && c_sta < c_sto {
		com := l.find_between(':"', '"]')
		im := l.find_between('[img:', ':"')
		return im, com
	}

	return l.find_between('[img:', ']'), ''
}
