module constants

import os

	pub const blog_file = '.blog'
pub const topic_file = '.topic'
pub const style_file = 'style.css'
pub const push_dir_prefix = 'push_'
pub const dir_removed_suffix = '__DELETED'
pub const pushs_pic_dir = './pictures'
pub const topics_list_template_file = 'topics_list.tmpl'
pub const pushs_list_template_file = 'pushs_list.tmpl'
pub const link_model_tag = '[LinkModel]'
pub const end_model = '[EndModel]'
pub const list_links_tag = '[LIST_LINKS]'
pub const topics_list_filename = 'base.htm'
pub const push_filename = 'index.htm'
pub const pushs_list_filename = 'index.htm'
pub const blog_entry_filename = 'index.htm'
pub const push_template_file = 'push.tmpl'
pub const push_style_template_file = 'push_style.tmpl'
pub const blog_date_format = 'DD/MM/YYYY kk:mm'

// Custom tags, used for chain command.
pub const lnk_next_tag = '<vssg-lnk-next>'
pub const next_tag_close = '</vssg-lnk-next>'
pub const lnk_prev_tag = '<vssg-lnk-prev>'
pub const prev_tag_close = '</vssg-lnk-prev>'
pub const lnk_next_label = 'Next'
pub const lnk_prev_label = 'Prev.'

// VSSG environment variables.
pub const img_src_env = 'VSSG_IMG_PUSH_DIR' // Env var pointing to images used in push.
pub const remote_url = 'VSSG_BLOG_URL' // Env var pointing remote site location.
pub const blog_root = 'VSSG_BLOG_ROOT' // Current blog's root
pub const rsync_permanent_option = 'VSSG_SYNC_OPT'

// zip command related options.
pub const zip_cmd = 'zip'
pub const zip_opt = '-r -n .jpg:.JPG:.jpeg:.JPEG:.png:.PNG' // better compress, recursive.
pub const zip_file_date_format = 'DD_MM_YYYY_kk_mm_ss'

// Rsync command related options.
pub const rsync_cmd_opt = 'rsync --delete -avzhrc'
pub const rsync_single_file = 'rsync -avzhc'
pub const rsync_pull_opt = 'rsync -chavzP'

// Templates file are embeded into vssg executable.
pub const topics_list_template = $embed_file('../templates/topics_list.htm', .zlib)
pub const topics_list_style_css = $embed_file('../templates/topics_list_style.css', .zlib)

pub const pushs_list_template = $embed_file('../templates/pushs_list.htm', .zlib)
pub const pushs_list_style_css = $embed_file('../templates/pushs_list_style.css', .zlib)

pub const push_template = $embed_file('../templates/push.htm', .zlib)
pub const push_style_css = $embed_file('../templates/push_style.css', .zlib)

// Default files right = -rw-r--r--
pub const file_access = os.s_iwusr | os.s_irusr| os.s_irgrp | os.s_iroth
