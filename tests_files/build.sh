#!/bin/bash
vssg init Blog
cd Blog

# Copy files common to al HTML page
cp ../tests_files/blog_menu/menu.htm ./
cp ../tests_files/blog_menu/navbar_style.css ./
cp ../tests_files/Common/banniere.jpg ./

# Create Topics
pushes=("Cydonia.txt" "Jupiter.txt" "Lorem.txt" "Mercure.txt" "Neptune.txt" "Sedna.txt")
for i in {0..2}
do
  vssg add "Topic $i"
  directory=$(vssg obfuscate -s "Topic $i")
  cd $directory
  for o in {0..5}
  do
    vssg push ${pushes[$(($o%6))]}
  done
  vssg chain
  cd ..
done

cd .. # Back out of Blog


