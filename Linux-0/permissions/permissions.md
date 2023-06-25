# Effect of rwx on files

```shell
[root@linux-server ~]# vim /home/file1
date
[root@linux-server ~]# ll /home/file1 
-rw-r--r--. 1 root root 5 Nov  3 15:19 /home/file1

[root@linux-server ~]# su - alice  #切换普通用户
[alice@linux-server ~]$ cat /home/file1 
date
[alice@linux-server ~]$ /home/file1   #执行文件
-bash: /home/file1: Permission denied
[alice@linux-server ~]$ exit
logout
[root@linux-server ~]# chmod o+x /home/file1
[alice@linux-server ~]$ /home/file1 
Sun Nov  3 15:26:21 CST 2019

[root@linux-server ~]# chmod o+w /home/file1 
[alice@linux-server ~]$ vim /home/file1
date
123
ls
```

# Effect of rwx on directories

```shell
1、对目录没有w，对文件有rwx
[root@linux-server ~]# mkdir /dir10
[root@linux-server ~]# touch /dir10/file1
[root@linux-server ~]# chmod 777 /dir10/file1 
[root@linux-server ~]# ll -d /dir10/
drwxr-xr-x. 2 root root 19 Nov  3 15:37 /dir10/
[root@linux-server ~]# ll /dir10/file1 
-rwxrwxrwx. 1 root root 0 Nov  3 15:37 /dir10/file1
[root@linux-server ~]# vim /dir10/file1
jack
[root@linux-server ~]# su - alice
Last login: Sun Nov  3 15:28:06 CST 2019 on pts/0
[alice@linux-server ~]$ cat /dir10/file1 
jack
[alice@linux-server ~]$ rm -rf /dir10/file1   #权限不够
rm: cannot remove ‘/dir10/file1’: Permission denied
[alice@linux-server ~]$ touch /dir10/file2   #权限不够
touch: cannot touch ‘/dir10/file2’: Permission denied

#结果可以看出文件是继承目录权限的
```

```shell
2、对目录有w，对文件没有任何权限
[root@linux-server ~]# chmod 777 /dir10/
[root@linux-server ~]# chmod 000 /dir10/file1 
[root@linux-server ~]# ll -d /dir10/
drwxrwxrwx. 2 root root 19 Nov  3 15:38 /dir10/
[root@linux-server ~]# ll /dir10/file1 
----------. 1 root root 5 Nov  3 15:38 /dir10/file1
[root@linux-server ~]# su - alice   #切换普通用户
Last login: Sun Nov  3 15:38:53 CST 2019 on pts/0
[alice@linux-server ~]$ cat /dir10/file1 
cat: /dir10/file1: Permission denied    #没有权限
[alice@linux-server ~]$ rm -rf /dir10/file1 
[alice@linux-server ~]$ touch /dir10/file2

#文件在目录内，文件的删除权限是目录所拥有
```

# Let go of all command usage rights

```shell
配置解释：
root表示用户名
第一个 ALL 指示允许从任何终端、机器访问 sudo
第二个 (ALL) 指示 sudo 命令被允许以任何用户身份执行
第三个 ALL 表示所有命令都可以作为 root 执行
```

```shell
[root@linux-server ~]# visudo    #打开配置文件
90 ##
91 ## Allow root to run any commands anywhere
92 root    ALL=(ALL)       ALL
93 jack    ALL=(ALL)       NOPASSWD: ALL   #添加内容
94 ## Allows members of the 'sys' group to run networking, software,
测试
[root@linux-server ~]# su - jack
Last login: Wed Nov  6 22:04:46 CST 2019 on pts/2
[jack@linux-server ~]$ sudo mkdir /test1
```

# Release the right to use individual commands

```shell
[root@linux-server ~]# visudo
     91 ## Allow root to run any commands anywhere
     92 root    ALL=(ALL)       ALL
     93 jack    ALL=(ALL)       NOPASSWD:ALL
     94 alice   ALL=(ALL)       NOPASSWD:/usr/bin/mkdir, /usr/bin/rm, /usr/bin/touch
     95 
     96 ## Allows members of the 'sys' group to run networking, software,
测试：
[root@linux-server ~]# su - alice
Last login: Fri Jul 24 00:52:13 CST 2020 on pts/1
[alice@linux-server ~]$ touch /file
touch: cannot touch ‘/file’: Permission denied
[alice@linux-server ~]$ sudo touch /file
```

