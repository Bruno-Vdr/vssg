# The Daily traveler's workflow:

VSSG has been written by and for travelers. Walking, visiting, taking picture, and finally writing article in
his personal blog.

- Select a bunch of JPG pictures for today's article, copy them in the (emptied) location pointed by VSSG_IMG_PUSH_DIR.
- [optional] Run the **vssg convert** command. This convert JPG pictures in web friendly and light pictures.
- Create an ascii text file [details](./Pushing.md) for the article in directory pointed by VSSG_PUSH_DIR .
- Write your text, insert any html tag and insert the selected pictures (Format: [img:picture.jpg:"Picture comment"] ).
  To help you, the **vssg convert** command created an html page containing thumbnails with picture names, into
  the directory pointed by VSSG_IMG_PUSH_DIR. To insert an image in your article, just copy the corresponding image
  **[img:mypic.jpg:""]**  tag where you want your image to be, and write a comment if any.

![Generated HTML page by convert command](pictures/images.png)

- When text is Ok, go in the topic directory you want to push with this article.
- Perform a **vssg push the_article.txt**. Check with a browser the local site.
- If modifications are needed: change the_article.txt and run a **vssg modify** to update you work ([details](./Pushing.md)).
- Repeat previous until Ok
- perform a **vssg chain** if you want link between topic's articles.
- perform a **vssg bend** if you want to update redirection to the last post.
- perform a **vssg sync [-bend]** to publish on the web. Use -bend to update redirection after bend.

[[Back to documentation]](../README.md)
