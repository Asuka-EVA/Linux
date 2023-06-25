#!/bin/bash
src_ip="10.8.161"
for i in {2..254}
do
        {
        ping -c1 -W 1 $src_ip.$i &>/dev/null
        if [ $? -eq 0 ];then
                echo "alive: $src_ip.$i" >> /dev/null
        else
                echo "down: $src_ip.$i"
        fi
        } &
done
wait
echo "结束"
