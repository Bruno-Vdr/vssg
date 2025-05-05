#!/bin/bash
vssg init Blog
cd Blog

# Copy files common to al HTML page
cp ../tests_files/blog_menu/menu.htm ./
cp ../tests_files/blog_menu/navbar_style.css ./
cp ../tests_files/Common/banniere.jpg ./

# Create Topics
pushes=("Cydonia.txt" "Jupiter.txt" "Lorem.txt" "Mercure.txt" "Neptune.txt" "Sedna.txt")
for i in {0..10}
do
  vssg add "Topic $i"
  directory=$(vssg obfuscate -s "Topic $i")
  cd $directory
  for o in {0..30}
  do
    vssg push ${pushes[$(($o%6))]}
  done
  vssg chain
  cd ..
done
#vssg add SolSys
#vssg add Small
#vssg add Third
#
## Fill Solsys topic
#cd ./2dc8c707808d050a # cd SolSys
#vssg push Cydonia.txt
#vssg push Mercure.txt
#vssg push Neptune.txt
#vssg push Sedna.txt
#vssg chain
#cd ..
#
## Fill Small topic
#cd ./3d2cc8d952adebec # cd Small
#vssg push Sedna.txt
#vssg push Sedna.txt
#vssg chain
#vssg bend ./push_1/index.htm
#cd ..
#
## Fill Third topic
#cd ./ce9a28d8e47beefe # cd Third
#vssg push Jupiter.txt
#vssg remove -f 0
#vssg push Mercure.txt
#vssg push Mercure.txt
#vssg modify 1 Jupiter.txt
#vssg chain
#
#cd ..
#cd .. # Back out of Blog


