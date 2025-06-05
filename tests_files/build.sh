#!/bin/bash

export VSSG_PUSH_DIR=`pwd`/VSSG_Push/
export VSSG_IMG_PUSH_DIR=`pwd`/VSSG_Img/
export VSSG_TEMPLATE_DIR=`pwd`/templates/
unset VSSG_BLOG_REMOTE_URL
unset VSSG_RSYNC_OPT

vssg init Blog
export VSSG_BLOG_ROOT=`pwd`/Blog/
cd Blog

# Copy files common to al HTML page
cp ../blog_menu/menu.htm ./
cp ../blog_menu/navbar_style.css ./
cp ../Common/banner.png ./

# Create Topics
pushes=("Cydonia.txt" "Jupiter.txt" "Lorem.txt" "Mercure.txt" "Neptune.txt" "Sedna.txt")
for i in {0..2}
do
  vssg add "Topic $i"
  directory=$(vssg obfuscate -s "Topic $i")
  cd $directory
  for o in {0..6}
  do
    vssg push ${pushes[$(($o%6))]}
  done
  vssg chain
  cd ..
done
vssg bend ./base.htm
cd .. # Back out of Blog


