module constants

pub const blog_file = '.blog'
pub const topic_file = '.topic'
pub const style_file = 'style.css'
pub const push_dir_prefix = 'push_'
pub const pushs_pic_dir = './pictures'
pub const topics_list_template_file = 'topics_list.template'
pub const pushs_list_template_file = 'posts_list.template'
pub const link_model_tag = '[LinkModel]'
pub const end_model = '[EndModel]'
pub const list_links_tag = '[LIST_LINKS]'
pub const topics_list_filename = 'index.htm'
pub const push_filename = 'index.htm'
pub const pushs_list_filename = 'index.htm'
pub const push_template_file = 'post.template'
pub const push_style_template_file = 'post_style.template'
pub const blog_date_format = 'DD/MM/YYYY kk:mm'
pub const img_src_env = 'VSSG_IMG_POST_DIR' // Env var pointing to images used in posts.
pub const remote_url = 'VSSG_BLOG_URL' // Env var pointing remote site location.
pub const blog_root = 'VSSG_BLOG_ROOT' // Current blog's root

// Templates file are embeded into vssg executable.
pub const topics_list_template = $embed_file('../templates/topics_list.template', .zlib)
pub const topics_list_style_css = $embed_file('../templates/topics_list_style.css', .zlib)

pub const posts_list_template = $embed_file('../templates/posts_list.template', .zlib)
pub const posts_list_style_css = $embed_file('../templates/posts_list_style.css', .zlib)

pub const default_post_template = $embed_file('../templates/default_post.template', .zlib)
pub const default_post_style_css = $embed_file('../templates/default_post_style.css', .zlib)
