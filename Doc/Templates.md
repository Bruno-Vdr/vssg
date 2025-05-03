# Templates:

There are three templates files used by vssg:
- push template : used as model for each push.
- push list template: used to generate the page listing pushes in the topic.
- topic list template: used to generate the page listing all topics in blog.

These files, all have an associated css style file, are embedded inside the **vssg** executable and located
in src/templates:

![Terminal](pictures/template_location.png "VSSG_BLOG_REMOTE_URL env example")

This allow me to keep only a simple executable instead of a bunch of files, dependant to filesystem, at cost
of recompilation. When the templates are modified, the vssg executable should be recompiled.  Note that these
templates will be deployed inside the blog, for further customization (if any). It's good idea to work on
these files, and copy them back in templates directory when satisfied.

## Push template: push.htm:

This file is a regular HTML file. It's only specificity is one or more  [section:xxx]. This  [section:xxx]
where xxx could be any unique name, will be later substituted to the corresponding text, in the text file
given as parameter of push/modify command. This allows to place blocs of text where you want.

The template could embed 2 specials tags:

![Terminal](pictures/prev_next_links.png "2 special tags")

That will be replaced by links to previous and next push (if any). Theses tags are optional.
