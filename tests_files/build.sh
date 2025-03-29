#!/bin/bash
vssg init Blog
cd Blog
vssg add SolSys
vssg add Small
vssg add Third
cd ./2dc8c707808d050a # cd SolSys
vssg push ../../tests_files/Cydonia.txt
vssg push ../../tests_files/Mercure.txt
vssg push ../../tests_files/Neptune.txt
vssg push ../../tests_files/Sedna.txt
vssg chain
cd ..

cd ./3d2cc8d952adebec # cd Small
vssg push ../../tests_files/Sedna.txt
vssg push ../../tests_files/Sedna.txt
vssg chain
vssg bend ./push_1/index.htm
cd ..

cd .. # Back out of Blog


