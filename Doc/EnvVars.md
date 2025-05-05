# Environment variables

**vssg** uses 5 environment variables.

![Terminal](./pictures/env.png "The env command from blog's directory.")

**VSSG_BLOG_ROOT** : This is the most important variable here. The absolute path of your blog directory. Should
en with '/' to indicates its directory nature.

**VSSG_PUSH_DIR**: This variable must contains the absolute path where the push files will be loaded from, when
using push or modify command. All push files are taken from this directory. It should end with a '/' indicating
it's a directory.

**VSSG_IMG_PUSH_DIR**: This variable is the blog source of images. Images, referenced in push file are taken here,
before beeing moved into ./pictures/ directory of pushes. It should end with a '/' indicating it's a directory.

**VSSG_BLOG_REMOTE_URL**: This variable indicates the remote blogs directory, in rsync format:
- /home/John/Blog/   if remote URL is a local directory (useful for tests).
- name@domain.com:distant_dir  in case of SSH access.



