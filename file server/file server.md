# Build NFS remote shared storage

```shell
centos7（服务端和客户端都关闭防火墙和selinux内核防火墙）

#systemctl stop firewalld

#systemctl disable firewalld	

#setenforce 0
```

```shell
NFS-server操作
[root@nfs-server ~]# yum -y install rpcbind  #安装rpc协议的包
[root@nfs-server ~]# yum -y install nfs-utils #安装nfs服务,提供文件系统
启动服务
[root@nfs-server ~]# systemctl start nfs
[root@nfs-server ~]# systemctl start rpcbind
[root@nfs-server ~]# mkdir /nfs-dir   #创建存储目录
[root@nfs-server ~]# echo "nfs-test" >> /nfs-dir/index.html  #制作test文件
[root@nfs-server ~]# vim /etc/exports   #编辑共享文件
/nfs-dir        192.168.246.0(rw,no_root_squash,sync)

可选参数注释：
ro：只读
rw：读写
*:表示共享给所有网段。
sync：所有数据在请求时写入共享
root_squash： 对于使用分享目录的使用者如果是root用户，那么这个使用者的权限将被压缩成为匿名使用者，只读权限。
no_root_squash：使用分享目录的使用者，如果是 root 的话，那么对于这个分享的目录来说，他就具有 root 的权限。
```

![image-20191116194232117](https://github.com/Asuka-EVA/Linux/blob/main/file%20server/assets/image-20191116194232117.png?raw=true)

```shell
[root@nfs-server ~]# systemctl restart nfs-server #重启服务。
[root@nfs-server ~]# systemctl enable nfs-server #制作开机启动

[root@testpm-server ~]# exportfs -v   #确认 NFS 服务器启动
/nfs-dir        192.168.246.0/24(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
```

```shell
web1  客户端操作
[root@web1 ~]# yum -y install rpcbind
[root@web1 ~]# yum -y install nfs-utils
[root@web1 ~]# mkdir /qf #创建挂载点
[root@web1 ~]# mount -t nfs 192.168.246.160:/nfs-dir /qf  #挂载
[root@web1 ~]# df -Th
Filesystem               Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root  xfs        17G  1.1G   16G   7% /
tmpfs                    tmpfs      98M     0   98M   0% /run/user/0
192.168.246.160:/nfs-dir nfs4       17G  1.4G   16G   8% /qf
[root@web1 ~]# ls /qf
index.html
[root@web1 ~]# umount /qf  #取消挂载


制作开机挂载
[root@client.qfedu.com ~]# vim /etc/fstab
192.168.246.160:/nfs-dir    /qf          nfs     defaults        0 0
[root@client.qfedu.com ~]# mount -a
```

# Vsftp configuration

```shell
FTP Server（服务端）
实验环境--准备两台机器
关闭防火墙和selinux
#systemctl stop firewalld
#systemctl disable firewalld	
#setenforce 0
=========================================
ftp-server 192.168.246.160
client 192.168.246.161
==========================================
[root@ftp-server ~]# yum install -y vsftpd
[root@ftp-server ~]# systemctl start vsftpd
```

```shell
FTP默认共享目录：/var/ftp
[root@ftp-server ~]# touch /var/ftp/pub/test.txt  #创建文件到共享目录
[root@ftp-server ~]# systemctl enable vsftpd
[root@ftp-server ~]# cd /var/ftp/
[root@ftp-server ftp]# ls
pub
[root@ftp-server ftp]# chown ftp.ftp pub/ -R  #修改根目录的属主与属组
[root@ftp-server ftp]# ll 
total 0
drwxr-xr-x. 2 ftp ftp 22 Aug  3 03:15 pub
```

```shell
重点：改变根目录的属主，如果不改变的话，只能访问，其他权限不能生效。因为我们是以ftp用户的身份访问的，而pub默认的属主属组是root。

注意：
修改完配置之后需要重启完服务才能生效
还需要从新从客户端登陆，否则修改后的配置看不到效果。
```

```shell
编辑配置文件
[root@ftp-server ~]# vi /etc/vsftpd/vsftpd.conf ----找到29行将下面的注释取消
34 anon_other_write_enable=YES
anon_umask=000  #匿名用户上传下载目录权限掩码
```

![image-20200802200151521](https://github.com/Asuka-EVA/Linux/blob/main/file%20server/assets/image-20200802200151521.png?raw=true)

```shell
35 anon_umask=000
```

```shell
[root@ftp-server ~]# systemctl restart vsftpd
```

```shell
FTP Clinet（客户端）
关闭防火墙和selinux
[root@client ~]# yum -y install lftp #安装客户端
get命令（下载，首先要开启下载功能）
[root@client ~]# lftp 192.168.246.160
lftp 192.168.246.160:~> ls
drwxr-xr-x    2 0        0               6 Oct 30  2018 pub
lftp 192.168.246.160:/> cd pub/
lftp 192.168.246.160:/pub> ls
-rw-r--r--    1 14       50              0 Aug 02 19:14 test.txt
lftp 192.168.246.160:/pub> get test.txt   #下载
lftp 192.168.246.160:/pub> exit
[root@client ~]# ls  #会下载到当前目录
anaconda-ks.cfg  test.txt

[root@client ~]# lftp 192.168.246.160
lftp 192.168.246.160:/pub> mkdir dir  #也可以创建目录
mkdir ok, `dir' created

put命令（上传命令，上传之前请在服务端进行配置，将上传功能打开）
[root@client ~]# touch upload.txt  #创建测试文件
[root@client ~]# mkdir /test/  #创建测试目录
[root@client ~]# touch /test/test1.txt #在测试目录下面创建测试文件
[root@client ~]# lftp 192.168.246.160
lftp 192.168.246.160:~> cd pub/
lftp 192.168.246.160:/pub> put /root/upload.txt  #上传文件
lftp 192.168.246.160:/pub> ls
-rw-------    1 14       50              0 Nov 16 12:14 upload.txt
drwx------    2 14       50              6 Aug 02 19:17 dir
lftp 192.168.246.160:/pub> mirror -R /test/  #上传目录以及目录中的子文件
Total: 1 directory, 1 file, 0 symlinks
New: 1 file, 0 symlinks
lftp 192.168.246.160:/pub> ls
drwx------    2 14       50             23 Nov 16 12:18 test
-rw-------    1 14       50              0 Nov 16 12:14 upload.txt

mirror 下载目录
```

# Ftp configuration local user login

```shell
创建zhangsan、lisi密码都设置为"123456"
[root@ftp-server ~]# useradd zhangsan 
[root@ftp-server ~]# useradd lisi
[root@ftp-server ~]# echo '123456' | passwd --stdin  zhangsan  #设置密码
Changing password for user zhangsan.
passwd: all authentication tokens updated successfully.
[root@ftp-server ~]# echo '123456' | passwd --stdin  lisi 
Changing password for user lisi.
passwd: all authentication tokens updated successfully.
```

```shell
配置本地用户ftp配置文件、
[root@ftp-server ~]# vim /etc/vsftpd/vsftpd.conf  ---添加注释并修改 
anonymous_enable=NO           #将允许匿名登录关闭   12行
#anon_umask=022                #匿名用户所上传文件的权限掩码 
#anon_upload_enable=YES        #允许匿名用户上传文件
#anon_mkdir_write_enable=YES   #允许匿名用户创建目录
#anon_other_write_enable=YES    #是否允许匿名用户有其他写入权（改名，删除，覆盖）
新添加
local_root=/home/zhangsan       # 设置本地用户的FTP根目录，一般为用户的家目录
local_max_rate=0                # 限制最大传输速率（字节/秒）0为无限制
```

![image-20200802205810530](https://github.com/Asuka-EVA/Linux/blob/main/file%20server/assets/image-20200802205810530.png?raw=true)

```shell
重启vsftpd
[root@ftp-server ~]# systemctl restart vsftpd
```

```shell
客户端操作
[root@ftp-client ~]# lftp 192.168.153.137 -u zhangsan
Password: 
lftp zhangsan@192.168.153.137:~> ls
lftp zhangsan@192.168.153.137:~> mkdir aaa
mkdir ok, `aaa' created
lftp zhangsan@192.168.153.137:~> ls
drwxr-xr-x    2 1000     1000            6 Aug 02 20:55 aaa
lftp zhangsan@192.168.153.137:~> put /root/test.txt 
lftp zhangsan@192.168.153.137:~> ls
drwxr-xr-x    2 1000     1000            6 Aug 02 20:55 aaa
-rw-r--r--    1 1000     1000            0 Aug 02 20:59 test.txt

服务器端查看
[root@ftp-server ~]# cd /home/zhangsan/
[root@ftp-server zhangsan]# ls
aaa  test.txt
[root@ftp-server zhangsan]# ll
total 0
drwxr-xr-x. 2 zhangsan zhangsan 6 Aug  3 04:55 aaa
-rw-r--r--. 1 zhangsan zhangsan 0 Aug  3 04:59 test.txt
```

