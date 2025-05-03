# The blog hierachy:

The blog file hierarchy is frozen and will always be the same:

- 1 blog root (here Blog/)
- 1 to N Topics (name hashed e.g. 2dc8c707808d050a/)
- 0 to N pushes (named push_X with a single pictures sub directory.)

![Terminal](hierarchy.png "The SSG is command line driven")

## The .blog file:

This file is in the blog's root directory, is unique and should not be edited. **vssg** uses it to keep
track of all topics within the blog. The file is easily understandable, with [1746281460] representing
a Unix date, seconds since epoque.

**Title - Unix date - Comment**

![Terminal](blog_file.png ".blog file")

## The .topic file:
Topic files are in each topic directory. This file is also unique, and should not be edited. **vssg**  uses
it to keep track of pushes within the topic. The file is still easily understandable:

**ID - Title - Unix date - Directory**


![Terminal](topic_file.png ".topic file")

