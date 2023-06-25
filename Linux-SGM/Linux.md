# Linux系统基本操作

## 查看ip地址

```shell
ip a  #查看ip地址
```

## 切换用户

```shell
su - #创建的用户名
exit #退出用户
```

## 查看服务器时间

```shell
date
date +%F  #只显示当前的年月日
date +%X  #只显示当前的时间到秒
pwd       #显示当前的工作路径
```

## 查看文件信息

```shell
ls  #查看当前目录下的文件
ls  /root/a.txt  #单独列出文件
ls   /home          #查看指定目录下的文件
ls  -l     #长格式显示(显示文件的详细信息)
文件类型\权限    硬链接个数   所有者 所属组   大小    修改时间   名字 
ll -d /home/  #显示目录的详细信息
ls -lh     #-h 人性化显示 （显示文件大小）
ls -a      #all 显示所有文件 （包括隐藏文件）
ls file*    #以file开头的所有文件    *通配符。表示所有字符（隐藏文件除外）
ls *.txt     #以任意开头以.txt结尾的所有文件
ll -d /home/  #查看目录详细信息
ll /home/ #查看目录下面文件的详细信息
ll -t  #按最新的修改时间排序
clear #清屏,快捷键----ctrl+l
```

## 创建文件

```shell
touch 文件名
```

## 删除文件

```shell
rm -rf 文件名
```

## 关机

```shell
init 0  poweroff
```

## 重启

```shell
reboot  init 6
```

## 关闭防火墙与Selinux

```shell
systemctl stop firewalld  #关闭防火墙
systemctl disable firewalld #永久关闭防火墙

关闭selinux
vi /etc/sysconfig/selinux  #永久关闭，需要重启机器
将文件中的SELINUX=enforcing改为disabled

getenforce  #查看selinux是否开启
Enforcing

setenforce 0 #临时关闭
```

## 扩展

```shell
ifup ens33  #启动网卡
systemctl restart network  #重启网络
ctrl+c  #终止命令
```

# 文件管理

## 历史命令

```shell
history
```

## 切换目录

```shell
.     #表示当前目录
cd .. #回到上一级目录等同于相对路径
cd 或者 cd ~	#直接回到家目录
cd /home/alice  #切换目录=绝对路径
cd -  #回到原来目录
```

## 创建文件

```shell
touch file1.txt  #无则创建，如果存在修改时间
touch /home/file10.txt
touch /home/{zhuzhu,gougou} #{}集合
touch /home/file{1..20}  #批量创建
```

```shell
echo  加内容   >  加文件名    #覆盖:把之前的内容替换掉

echo  加内容  >> 加文件名     #追加:保留之前的内容,在后面添加新内容
当使用echo 123 >> a.txt 这个命令的时候在文件不存在的时候会创建该文件并将内容追加到改文件中
```

## 创建目录

```shell
mkdir dir1
mkdir /home/dir2 /home/dir3
mkdir /home/{dir4,dir5} 
mkdir -v /home/{dir6,dir7}   #-v ：verbose 冗长的。显示创建时的详细信息
mkdir -p /home/dir8/111/222  #-p 创建连级目录，一级一级的创建
```

## 复制

```shell
cp -v anaconda-ks.cfg /home/dir1/  #-v 显示详细信息
cp anaconda-ks.cfg /home/dir1/test.txt  #复制并改文件名
cp -r /etc /home/dir1             #-r 拷贝目录使用，连同目录里面的文件一块拷贝
```

```shell
语法: cp  -r  源文件1 源文件2 源文件N  目标目录    #将多个文件拷贝到同一个目录
# cp -r /etc/sysconfig/network-scripts/ifcfg-ens33 /etc/passwd /etc/hosts .
# cp -r /etc /tmp
```

## 移动

```shell
mv /root/file1 /tmp/
mv /tmp/file1 /tmp/file2  #更名
```

## 删除

```shell
rm -rf dir1/
-r 递归，删除目录时
-f force强制
-v 详细过程
```

```shell
rm -rf /home/dir10/*  //不包括隐藏文件
```

## 查看文件

### cat---查看一个文件的全部内容

```shell
[root@linux-server ~]# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
...

参数：
-n 显示行号
-A 包括控制字符（换行符/制表符）
```

### head头部

```shell
head /etc/passwd  #默查看前十行
head -2 /etc/passwd  #默认查看前两行
```

### tail尾部

```shell
tail /etc/passwd #默认查看文件的后十行
tail -1 /etc/passwd  #查看文件最后一行
tail /var/log/messages
tail -f /var/log/secure  #-f 动态查看文件的尾部
tailf /var/log/secure  #功能同上
```

### grep过滤关键字	grep 针对文件内容进行过滤

```shell
grep 'root' /etc/passwd
```

```shell
grep 'root' /etc/passwd
过滤以root开头的行：^ --以什么开头
```

```shell
grep 'bash$' /etc/passwd
过滤以bash结尾的行：$ --以什么结尾
```

### less --分页显示

```shell
less /etc/makedumpfile.conf.sample
1.空格键是翻页  回车键是翻行
2.上下箭头可以来回翻
3. /关键字     #搜索 (n按关键字往下翻   N按关键字往上翻)
4.快捷键:q -quit 退出
```

### more  --分页显示文件内容

```shell
more  文件名  
空格键是翻页  回车键是翻行
```

# 文件编辑器

## 查找替换

```shell
语法----> :范围 s/old/new/选项 
:s/world/nice/         #替换当前光标所在行
:3s/sbin/nice/         #替换指定行
:1,5 s/nologin/soso/   #从1－5行的nologin 替换为soso
:%s/bin/soso/          #替换所有行
:%s/sbin/nice/g        #替换行内所有关键字

注释：%表示替换所有行  g表示行内所有关键字

将文件另存(另存为)
语法----> :w 存储到当前文件
:w /tmp/aaa.txt    #另存为/tmp/aaa.txt 
:1,3 w /tmp/2.txt  #从1-3行的内容另存为/tmp/2.txt
```

## 设计环境

```shell
:set nu    #设置行号 
:set list  #显示控制字符
:set nonu  #取消设置行号 
```

# 用户管理

## 用户组

### 创建组

```shell
groupadd hr   #创建一个用户组叫hr
groupadd net01 -g 2000  #创建组叫net01，并指定gid为2000
grep 'net01' /etc/group  #查看/etc/group中组net01信息
```

### 修改组

```shell
groupmod 参数 组名
-g：修改组的gid
-n：修改组名
```

```shell
groupmod -g 2000 grp1
groupmod -n 新组名 grp1
```

### 删除组

```shell
groupdel net01  #删除组net01
注意：用户的主属组不能删除
```

### 查看组

```shell
cat /etc/group
组名:代表组密码:gid:组员
```

## 用户

```shell
useradd user01   #创建用户
```

```shell
/etc/passwd  ---->查看账户是否存在的文件
/home/  ---->用户的家目录，每创建一个用户会在/home目录下面创建对应的家目录
/etc/shadow   --->用户的密码文件
```

```shell
[root@linux-server ~]# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
分隔符：:
第一列：用户名
第二列：密码
第三列：用户标识号--->（uid）是一个整数，系统内部用它来标识用户。通常用户标识号的取值范围是0～65535。0是超级用户root的标识号
第四列：gid
第五列：描述信息。
第六列：家目录
第七列：是用户登陆到界面的第一个命令，开启一个shell。登陆shell
```

### 判断用户是否存在

```shell
id user01   #查看用户的uid、gid、和所在组
uid=1001(user01) gid=1003(user01) groups=1003(user01)
                    主属组                    附属组
uid 系统用来识别账户的user identify
gid 系统用来识别组的group identify
```

### 查看现在所使用的账户

```shell
whoami 查看我现在所使用的账户
```

### 创建用户

```shell
useradd user02 -u 503   #指定uid为503
useradd user05 -s /sbin/nologin  #创建用户并指定shell
useradd user07 -G it,fd  #创建用户，指定附加组
useradd -g 1003 user8 #指定用户的主属组为1003组
useradd user10 -u 4000 -s /sbin/nologin
```

### 删除用户

```shell
userdel -r user02  #删除用户user2，同时删除用户家目录
```

### 用户密码

```shell
passwd alice  #root用户可以给任何用户设置密码
passwd   #root用户给自己设置密码
su - alice
passwd  #普通用户只能给自己修改密码，而且必须提供原密码
```

### 用户操作

#### 修改用户名

```shell
usermod -l NEW_name user8
id user8
```

#### 修改GID

```shell
usermod user10 -g new_gid    #gid需要提前存在
id user10
```

#### 修改UID

```
usermod -u new_id jack
id jack
```

#### 修改用户的登录shell

```shell
usermod -s /sbin/nologin user07   #修改用户的登录shell
```

# 组成员管理

## 给组添加用户

```shell
gpasswd -a user10 grp2
```

## 同时添加多个用户到组

```shell
gpasswd -M tom,alice it
```

## 从组删除用户

```shell
gpasswd -d user07 hr
```

