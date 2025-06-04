# The Daily traveler's workflow:

VSSG has been written by and for travelers. Walking, visiting, taking picture, and finally writing article in
his personal blog.

- Select a bunch of pictures that will be presents in today's article.
- Copy them in the (emptied) location pointed by VSSG_IMG_PUSH_DIR.
- Run the vssg convert command. This convert pictures in web friendly light pictures.
- Open a text editor, and create a ascii text file [details](./Templates.md)for the article in directory pointed by VSSG_PUSH_DIR .
- Write your text, insert any html tag and insert the selected pictures.
  To help you, the vssg convert command created an html page containing thumbnails with picture names, into
  the directory pointed by VSSG_IMG_PUSH_DIR.
- When text is Ok, go in the topic directory you want to update with this article.
- Perform a **vssg push the_article.txt**. Check with a local browser if all is fine.
- If modifications are needed: change the_article.txt and run a vssg modify to update you work.
- Repeat previous until Ok
- perform a **vssg chain** if you want link between topic's articles.
- perform a **vssg bend** if you want to update redirection to the last post.
- perform a **vssg sync [-bend]** to publish on the web.
