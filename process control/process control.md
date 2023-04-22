# Send a signal to the vsftpd process 1,15 vsftpd signal test

```shell
[root@linux-server ~]# yum install -y vsftpd  #安装vsftpd
[root@linux-server ~]# systemctl start vsftpd  #启动
[root@linux-server ~]# ps aux | grep vsftpd
root      59363  0.0  0.0  53212   576 ?        Ss   16:47   0:00 /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

[root@linux-server ~]# kill -1 59363  #发送重启信号，例如vsftpd的配置文件发生改变，希望重新加载
```

```shell
[root@linux-server ~]# ps aux | grep vsftpd
root      59363  0.0  0.0  53212   748 ?        Ss   16:47   0:00 /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
[root@linux-server ~]# kill 59363 #正常杀死进程，信号为-15可以默认不写。我们可以使用systemctl stop vsftpd 停止服务。
[root@linux-server ~]# ps aux | grep vsftpd
root      62493  0.0  0.0 112660   968 pts/0    S+   16:51   0:00 grep --color=auto vsftpd

进程状态解释--了解：
+：表示运行在前台的进程组
S+：前台休眠状态
T+：暂停，挂起状态
s：父进程
```

# Use pkill to kill the vsftpd process

```shell
[root@linux-server ~]# systemctl start vsftpd
[root@linux-server ~]# ps -aux | grep vsftpd
root      73399  0.0  0.0  53212   572 ?        Ss   17:05   0:00 /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
root      73499  0.0  0.0 112660   968 pts/0    S+   17:05   0:00 grep --color=auto vsftpd
[root@linux-server ~]# pkill -9 vsftpd  #使用pkill可以指定进程名字
[root@linux-server ~]# ps -aux | grep vsftpd
root      73643  0.0  0.0 112660   968 pts/0    S+   17:05   0:00 grep --color=auto vsftpd
```

# job control

```shell
[root@linux-server~]# sleep 7000 &   #&:让命令或者程序后台运行
[1] 5441
[root@linux-server ~]# sleep 8000    #ctrl+z 把运行中程序放到后台(这方法会让程序在后台暂停)
^Z
[2]+  Stopped                 sleep 8000

[root@linux-server ~]# jobs  #查看后台的工作号
[1]-  Running                 sleep 7000 &
[2]+  Stopped                 sleep 8000
[root@linux-server ~]# bg %2  #让暂停的程序在后台运行，%是用来修饰job number，2就是job number。(程序的工作号)
[2]+ sleep 8000 &
[root@linux-server ~]# jobs 
[1]-  Running                 sleep 7000 &
[2]+  Running                 sleep 8000 &

[root@linux-server ~]# fg %1  #将后台的程序调到前台
sleep 7000

[root@linux-server ~]# jobs 
[2]+  Running                 sleep 8000 &
[root@linux-server ~]# kill -9 %2  #通过kill杀死进程
[root@linux-server ~]# jobs 
[2]+  Killed                  sleep 8000
[root@linux-server ~]# jobs #在次查看没有了
```

