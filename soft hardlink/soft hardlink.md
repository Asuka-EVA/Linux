# Hard link

```shell
[root@Asuka ~]# echo 222 > /file2
[root@Asuka ~]# ll -i /file2                 #-i：显示inode编号
34045994 -rw-r--r-- 1 root root 4 Dec 29 20:52 file2
[root@Asuka ~]# ln /file2 /file2-h1
[root@Asuka ~]# ll -i /file2 /file2-h1       #查看inode号
34045994 -rw-r--r-- 2 root root 4 7月  30 22:25 /file2
34045994 -rw-r--r-- 2 root root 4 7月  30 22:25 /file2-h1

[root@Asuka ~]# rm -rf /file2        #删除源文件
[root@Asuka ~]# ll -i /file2-h1      #查看链接文件
34045994 -rw-r--r--. 3 root root 4 Nov  9 15:01 /file2-h1
查看:
[root@Asuka ~]# cat /file2-h1
222

#删除源文件对连接文件没有影响
```

# Soft link

```shell
语法：ln -s  源文件  链接文件

[root@Asuka ~]# echo 111 > /file1
[root@Asuka ~]# ll -i /file1 
545310 -rw-r--r-- 1 root root 4 7月  30 22:06 /file1
[root@Asuka ~]# ln -s /file1 /file11		#将文件file1软链接到file11
[root@Asuka ~]# ll /file11 
lrwxrwxrwx 1 root root 6 Dec 20 17:58 /file11 -> /file1

[root@Asuka ~]# ll -i /file11 /file1    #查看inode号
545310 -rw-r--r-- 1 root root 4 7月  30 22:06 /file1
545343 lrwxrwxrwx 1 root root 6 7月  30 22:06 /file11 -> /file1

[root@Asuka ~]# cat /file1 
111
[root@Asuka ~]# cat /file11 
111

[root@Asuka ~]# rm -rf /file11 #取消软连接。

[root@Asuka ~]# ln -s /file1 /file11
[root@Asuka ~]# rm -rf /file1  #删除源文件
[root@Asuka ~]# ll /file11 
lrwxrwxrwx 1 root root 6 Dec 20 17:58  /file11 -> /file1   #已失效

#给目录设置软链接必须是绝对路劲
[root@Asuka ~]# ln -s /root/aaa/ /usr/bbb
[root@Asuka ~]# ll /usr/bbb
lrwxrwxrwx 1 root root 10 Dec 29 21:08 /usr/bbb -> /root/aaa/
[root@Asuka ~]# rm -rf /usr/bbb  #取消链接，注意:删除目录链接时目录后面加“/”是删除目录，不加是删除链接
```

