#!/bin/bash
vssg init Blog
cd Blog
vssg add SolSys
vssg add Small
vssg add Third
cd ./2dc8c707808d050a # cd SolSys
vssg push Cydonia.txt
vssg push Mercure.txt
vssg push Neptune.txt
vssg push Sedna.txt
vssg chain
cd ..

cd ./3d2cc8d952adebec # cd Small
vssg push Sedna.txt
vssg push Sedna.txt
vssg chain
vssg bend ./push_1/index.htm
cd ..

cd ./ce9a28d8e47beefe # cd Third
vssg push Jupiter.txt
vssg remove -f 0
vssg push Mercure.txt
vssg push Mercure.txt
vssg modify 1 Jupiter.txt
vssg chain

cd .. # Back out of Blog


