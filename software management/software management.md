# centos7 replaces yum official source
```shell
下载wget工具
# yum -y install wget
```
```shell
进入yum源配置文件所在文件夹
# cd /etc/yum.repos.d
```
```shell
备份官方yum源
# mv CentOS-Base.repo CentOS-Base.repo_bak
```
```shell
下载国内yum源【aliyun\163】
# wget -O CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
# wget -O CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
```
```shell
清理yum缓存
# yum clean all
```
```shell
重建缓存
# yum makecache
```
```shell
升级CentOS
# yum -y update
```

```shell
安装epel源【Extra Packages for Enterprise Linux】由Fedora社区打造,为RHEL及衍生发行版如:CentOS等提供高质量软件包的项目
# yum -y install epel-release
```
```shell
修改为阿里的epel源
# wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
```
```shell
安装yum源优先级管理工具
# yum -y install yum-priorities
```
```shell
添加优先级【数字越小优先级越高】
# vim /etc/yum.repo.d/epel.repo
priority=88
```
```shell
添加优先级【此数值小于epel里的88即可】
# vim /etc/yum.repo.d/Centos-7.repo
priprity=5
```
```shell
开启yum源优先级功能
# vim /etc/yum/pluginconf.d/priorities.conf
[main]
enable=1
```

# Create a local yum source through mirroring

```shell
首先需要挂载镜像
[root@linux-server ~]# mkdir /mnt/centos7u4
将本地镜像上传到虚拟机中的/root目录中 

# 语法： mount   挂载设备     挂载点 

[root@linux-server ~]# mount CentOS-7-x86_64-DVD-1708.iso /mnt/centos7u4/
[root@linux-server ~]# rm -rf /etc/yum.repos.d/*
[root@linux-server ~]# cd /etc/yum.repos.d/   #yum源配置文件存放目录
[root@linux-server yum.repos.d]# vim CentOS.Base.repo  #在编写yum配置文件是必须是.repo
[centos7u4]  #yum源区别名称，用来区分其他的yum源
name=centos7u4  #yum源描述   yum源名字
baseurl=file:///mnt/centos7u4  #指定本地yum源的路径
enabled=1  #是否使用此yum源（1为打开，0为关闭）
gpgcheck=0 #检查软件
```

# Make your own yum source by turning on the yum download cache function

```shell
制作自己的yum源：
打开Yum缓存功能:安装完软件之后,软件不会被删除(默认安装完之后，不会保留安装包)
# vim /etc/yum.conf  修改下面参数的值为1,软件会被保存到cachedir指定的目录下
keepcache=1
[root@linux-server ~]# yum install -y httpd 

[root@linux-server ~]# mkdir /yum_cache

[root@linux-server ~]# find /var/cache/yum/   -name "*.rpm" | xargs -i mv {}  /yum_cache/


[root@linux-server ~]# ls /yum_cache/
apr-1.4.8-7.el7.x86_64.rpm
apr-util-1.5.2-6.el7.x86_64.rpm
httpd-2.4.6-97.el7.centos.5.x86_64.rpm
httpd-tools-2.4.6-97.el7.centos.5.x86_64.rpm
mailcap-2.1.41-2.el7.noarch.rpm


[root@linux-server ~]# yum install -y createrepo  #创建repo文件工具
[root@linux-server ~]# createrepo /yum_cache/         //此目录就可以作为yum源了。
[root@linux-server ~]# vim /etc/yum.repos.d/myyum.repo
[myyum]
name=myyum
baseurl=file:///yum_cache/
enabled=1   #默认是开启的  
gpgcheck=0
[root@linux-server ~]# yum repolist
```

# Source package management

```shell
安装源码包 
准备工作(去Nginx官网下载Nginx软件的源码包) 
1.编译环境如编译器gcc、make 
# yum -y install gcc make zlib-devel pcre pcre-devel openssl-devel  #编译环境的准备

gcc是编译工具，编译单个文件
make工具可以看成是一个智能的批处理工具，通过调用makefile文件中用户指定的命令来进行编译和链接的。（将这种高级语言写的代码编译成二进制语言）
pcre支持正则表达式
zlib-devel，有些应用依赖于这个库才能正常运行，因此需要安装zlib-devel
openssl-devel 某些库文件等跟开发相关的东西。

2. 准备软件 nginx-1.16.0.tar.gz 
3. 部署安装Nginx软件服务
```

# Compile and install nginx

```shell
[root@linux-server ~]# wget http://nginx.org/download/nginx-1.16.1.tar.gz
[root@linux-server ~]# tar xzf nginx-1.16.1.tar.gz
[root@linux-server ~]# cd nginx-1.16.1
[root@linux-server nginx-1.16.1]# ./configure --user=www --group=www --prefix=/usr/local/nginx
[root@linux-server nginx-1.16.1]# make  #编译文件
[root@linux-server nginx-1.16.1]# make install  #安装文件
[root@linux-server ~]# useradd www   #创建nginx用户
[root@linux-server ~]# /usr/local/nginx/sbin/nginx  #启动nginx
[root@linux-server ~]# systemctl stop firewalld  #关闭防火墙

停止nginx
[root@linux-server nginx-1.16.1]# /usr/local/nginx/sbin/nginx -s stop
访问
```

```shell
详解源码安装三步曲 
# ./configure   #相对路径执行安装

 a. 指定安装路径，例如 --prefix=/usr/local/nginx     
 b. 检查安装环境，例如是否有编译器gcc，是否满足软件的依赖需求    最终生成：Makefile
 c. 软件模块或者功能的启用禁用

#make			  //按Makefile文件编译，产生可执行的文件。但是这个文件在当前目录中

#make install	    //按Makefile定义的文件路径安装，将产生的可执行文件，安装到合适的位置，相当于拷贝
```

