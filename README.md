# VSSG is a static site generator

The Static Site Generator (SSG) is written in new language v. This language can be found [here](https://vlang.io/). V language
is fast and very well suited for any application. The language is quite simple, elegant and avoid most of syntactic noise.
This leads to a great code concision and a very easy to learn language.

The project aims to have zero dependencies:
- No database link, replaced by minimalistic ASCII files.
- No PHP or other dynamic scripts.
- No javascript / framework dependencies.
- No CMS.
- Only HTML and CSS


**vssg** is command line driven, and almost fully self documented. All operations are done via command
line. The project is very Linux, developer centric, and I won't make any effort to support MS Windows.

The SSG was written for my personal need, and doesn't aim to be widely used. It is provided as is, with hope to
be useful for others people. The project is released under MIT license, as most of V projects

![Terminal](Doc/pictures/term.png "The SSG is command line driven")

## Three concepts of vssg:
vssg recognize only three concepts:

- The Blog: A blog, denoted by it's directory. It contains 1 to N topics.
- Topics: 1 to N exists in the Blog. Topics are similar to forum Topics/Threads, denoted as blog's sub-directory.
- Pushes: 0 to N Pushes inside a Topic directory. Each push is an HTML page, in a topic sub-directory.

## Quickstart guide:

Want an example: [Go the the test blog, to try by yourself vssg.](./Doc/Playground.md)

## A more detailed start guide:

### 0) Grab and install V lang from [V repository](https://github.com/vlang/v).

Then grab vssg sources, follow installation procedure. Then DL vssg source files and in the main directory (the one that
contains the v.mod) file run "v ." command. This will compile vssg executable. You should alias or put is in your $PATH
env variable.

### 1) Init the blog with the command:
In your favorite terminal type "vssg init Blog"  (vssg must be in your $PATH)

 ![Terminal](Doc/pictures/init.png "The init command results:")

It's **strongly** suggested to export the absolute path of your blog to VSSG_BLOG_ROOT environment variable.
This variable will be used by many commands.

### 2) Add few topics to the Blog:
First, **you must move in your blog directory**. All vssg commands are relatives to the
location the commands are launched from. Two locations are known: Blog's root, and Topic directory.

Launch the "vssg add SolSys" to add a Topic in your blog.

![Terminal](Doc/pictures/add.png "The add command results:")

The command traces its actions, and guides you for customization. Here, add deploys several css and
template files to be customised before pushing pages. Note that the topic's name is hashed (fnv1a algorithm) to generate
a directory name. Here SolSys topic is held in 2dc8c707808d050a directory.

you can perform a "vssg show" to list topics, from blog's directory:

![Terminal](Doc/pictures/show.png "The show command from blog's directory.")

### 3) Insert a push into a given topic.
To insert a push in a specific Topic, just move (cd) into the Topic directory. To retrieve the topic hashed name
just perform a "vssg show" (see above). The pushes are provided through text files (format specified later). These
files are typically grabbed from a location specified by the VSSG_PUSH_DIR, setup via export VSSG_PUSH_DIR="Absolute dir path".

Environment variable used by vssg can be shown with "vssg env" command.

![Terminal](Doc/pictures/env.png "The env command from blog's directory.")

Then, from topic's directory

Just perform "vssg push Jupiter.txt" (provided Jupiter.txt exists in the directory pointed by VSSG_PUSH_DIR)

![Terminal](Doc/pictures/push.png "The push command from SolSys directory.")

Pushes, in directory can be listed with "vssg show" command, from withing directory. From blog's directory, it shows
Topics.

![Terminal](Doc/pictures/show_push.png "The show command from SolSys directory.")

Should you need to modify the push, you can update it with modify command (Pushing again would give 2 distinct pushes).
E.g. "vssg modify 0 Jupiter.txt". This will regenerate dependant HTML, file, copy images, without creating again
directories.

![Terminal](Doc/pictures/modify.png "The modify command from SolSys directory.")

### 4) Browse your blog:

Now, you have a base.html file in your blog directory that allow to navigate through your blog. With vssg, the index.html
file, in the blog's root directory is use to redirect to the last push. To generate it, just launch the command "vssg bend":

![Terminal](Doc/pictures/bend.png "The bend command from SolSys directory.")

### 5) Publish your blog:

For publishing a blog, vssg relies on the [rsync](https://manpages.debian.org/bookworm/rsync/rsync.1.en.html) command.
Defaults parameters are: --delete -avzhrc to ensure perfect mirroring with local and distant blog.
See your distribution package manager to install the tool if needed. In order to use the "vssg sync" command, you need to
setup two environment variables: VSSG_BLOG_ROOT (Should be done at init command) and VSSG_BLOG_REMOTE_URL. This last
variable could be a local directory, for testing purpose for example. For real remote synchronization it will probably
look more like this:

![Terminal](Doc/pictures/remote_url.png "VSSG_BLOG_REMOTE_URL env example")

Depending on your domain, hosting, and remote access. In order to adapt rsync command to your hosting needs, vssg offers
a last environment variable to customize the command: VSSG_RSYNC_OPT. My hosting requires a SSH access on port 22, with a directory to
keep untouched (.well-known) so here is my VSSG_RSYNC_OPT:

![Terminal](Doc/pictures/rsync_opt.png "VSSG_RSYNC_OPT env example")

Giving the full rsync command:

![Terminal](Doc/pictures/full_rsync.png " full command env example")

You can run the command "vssg sync -dry" in order to perform a basic check, without sending or receiving data. It's also
displays the whole rsync command.

**Note:** The synchronization is relative to your current location. From blog root directory, the whole blog is synced,
but from a topic directory, only this topic will be synced.

### Further readings:

- [Blog files hierarchy](./Doc/Hierarchy.md)
- [VSSG templates](./Doc/Templates.md)
- [Environment variables](./Doc/EnvVars.md)
- [Detailed push command](./Doc/Pushing.md)
- [All vssg commands](./Doc/AllCommands.md)
