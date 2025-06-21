#! /bin/bash

export VSSG_PUSH_DIR=`pwd`/Push/
export VSSG_IMG_PUSH_DIR=`pwd`/Img/
export VSSG_TEMPLATE_DIR=`pwd`/Templates/
unset VSSG_BLOG_REMOTE_URL
unset VSSG_RSYNC_OPT
echo "unset following variables: VSSG_BLOG_REMOTE_URL, VSSG_RSYNC_OPT."

vssg init Novae
export VSSG_BLOG_ROOT=`pwd`/Novae/
cd Novae

vssg add Infos
cd ./316924f5f8127be2

vssg push Push1.txt
vssg push Push2.txt
vssg chain
vssg bend

cd ..
