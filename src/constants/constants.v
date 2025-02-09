module constants

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
pub const img_src_env = 'VSSG_IMG_PUSH_DIR' // Env var pointing to images used in push.
pub const remote_url = 'VSSG_BLOG_URL' // Env var pointing remote site location.
pub const blog_root = 'VSSG_BLOG_ROOT' // Current blog's root
pub const rsync_permanent_option = "VSSG_SYNC_OPT"
pub const rsync_cmd_opt = 'rsync -avzhrc'

// Templates file are embeded into vssg executable.
pub const topics_list_template = $embed_file('../templates/topics_list.htm', .zlib)
pub const topics_list_style_css = $embed_file('../templates/topics_list_style.css', .zlib)

pub const pushs_list_template = $embed_file('../templates/pushs_list.htm', .zlib)
pub const pushs_list_style_css = $embed_file('../templates/pushs_list_style.css', .zlib)

pub const push_template = $embed_file('../templates/push.htm', .zlib)
pub const push_style_css = $embed_file('../templates/push_style.css', .zlib)
