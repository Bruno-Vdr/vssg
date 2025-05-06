# Pushing

Push and Modify are two major commands of **vssg**.

These commands MUST be launched from the topic's directory you want to update. In order to use them
both VSSG_PUSH_DIR and VSSG_IMG_PUSH_DIR must be set.

vssg push **Saturn.txt** : Saturn.txt is the push_text_file.

This command will load the push file from the directory pointed by VSSG_PUSH_DIR. Images (if any) referenced in the
Saturn.txt file will be searched (copied) from the VSSG_IMG_PUSH_DIR path. (See [VSSG variables](EnvVars.md))

An example of minimal push file:

![image](pictures/min_push.png)

These 4 lines must be present in that order in the push file.

- **title**: mandatory, is the title of your push.
- **link label**: optional, is the link to your push in push list of the topic.
- **date**: optional : specify the date ('DD/MM/YYYY HH:mm') or it will be set to actual time.
- **sections...** : mandatory, section name should match your push template. Your template will be used to generate
  the push HTML page, and [section:...] in your push, will be substituted with this text section.

You can have as many section as you want in your push template. They all will be substituted with the corresponding
section text in your push file. Nevertheless, referring to an non existing section in your push text will generate a
warning:

![image](pictures/no_section.png)

Sections in template that are not filled also generate a warning:

![image](pictures/not_filled.png)

In push_text_file, images are provided like this:

[img:merc2.jpg:"Pole sud de Mercure"] : Picture name, followed by optional comment
[img:Jupiter_2.jpg] : An image without comment.

Only the filename is provided as path is taken from the VSSG_IMG_PUSH_DIR environment variable.

![image](pictures/push_minimal.png)

Here push perform the following actions:
- Create directory push_X
- Create directory push_X/pictures
- Update the .topic Topic file
- Create the push HTML page
- Copy images (if any) into picture directory


To modify you can use the command: **vssg modify 0 Minimal.txt**

![image](pictures/modify_minimal.png)

The modify command only modifies an existing push. It perform the following actions:
- Update the .topic Topic file
- Create the push HTML page
- Copy images (if any) into picture directory

Pushing (vssg push file.txt) several times, will leads to the same push posted multiples times.
That's why the modify command exists. It patches an existing push.

You can remove a push using the command **remove**.
