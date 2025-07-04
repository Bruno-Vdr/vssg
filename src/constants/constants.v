module constants

import os

pub const blog_file = '.blog'
pub const topic_file = '.topic'
pub const style_file = 'style.css'
pub const img_size_warning = 1024 * 512 // bytes
pub const push_dir_prefix = 'push_'
pub const dir_removed_suffix = '__deleted'
pub const pushs_pic_dir = 'pictures'
pub const link_model_tag = '[LinkModel]'
pub const end_model = '[EndModel]'
pub const list_links_tag = '[LIST_LINKS]'
pub const topics_list_filename = 'base.htm'
pub const push_filename = 'index.htm'
pub const pushs_list_filename = 'index.htm'
pub const blog_entry_filename = 'index.htm'
pub const push_template_file = 'push.tmpl'
pub const push_style_template_file = 'push_style.tmpl'
pub const topics_list_template_file = 'topics_list.tmpl'
pub const topics_list_style_template_file = 'topics_list_style.tmpl'
pub const pushs_list_template_file = 'pushs_list.tmpl'
pub const pushs_list_style_template_file = 'pushs_list_style.tmpl'

pub const blog_date_format = 'DD/MM/YYYY HH:mm'

// Custom tags, used for chain command.
pub const max_lnk_label_len = 16
pub const lnk_next_tag = '<vssg-lnk-next>'
pub const next_tag_close = '</vssg-lnk-next>'
pub const lnk_prev_tag = '<vssg-lnk-prev>'
pub const prev_tag_close = '</vssg-lnk-prev>'
pub const lnk_next_label = 'Next &gt;'
pub const lnk_prev_label = '&lt; Prev.'

// VSSG environment variables.
pub const default_push_dir = 'VSSG_PUSH_DIR' // Default dir of push files.
pub const img_src_env = 'VSSG_IMG_PUSH_DIR' // Env var pointing to images used in push.
pub const remote_url = 'VSSG_BLOG_REMOTE_URL' // Env var pointing remote site location.
pub const blog_root = 'VSSG_BLOG_ROOT' // Current blog's root
pub const default_tmpl_dir = 'VSSG_TEMPLATE_DIR' // Blog's template directory.
pub const rsync_permanent_option = 'VSSG_RSYNC_OPT'
pub const prev_next_label = 'VSSG_PREV_NEXT_LABELS'

// zip command related options.
pub const zip_cmd = 'zip'
pub const zip_opt = '-r -n .jpg:.JPG:.jpeg:.JPEG:.png:.PNG' // better compress, recursive.
pub const zip_file_date_format = 'DD_MM_YYYY_kk_mm_ss'

// Rsync command related options.
pub const rsync_cmd_opt = 'rsync --delete -avzhrc'
pub const rsync_single_file = 'rsync -avzc'
pub const rsync_pull_opt = 'rsync -chavzP'
pub const rsync_files_only = 'rsync -avzc --exclude=\'*/\' '
pub const rsync_specific_dir_only = 'rsync -avzcr '

// Image Magick command to shrink images in the Blog. '@FILE' will be dynamically replaced. ORDER MATTERS !
pub const convert_cmd = 'magick convert -interlace Plane -quality 85% @IFILE -resize 900 -auto-orient -strip @OFILE'
pub const image_list_name = 'images.html'

// Documentation file
pub const doc_file = 'vssg_doc.htm'
pub const doc_command = 'vssg doc | aha -b -w > vssg_doc.htm'

// Default files right = -rw-r--r--
pub const file_access = os.s_iwusr | os.s_irusr | os.s_irgrp | os.s_iroth
