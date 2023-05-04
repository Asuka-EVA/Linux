# WEB服务器

```shell
世上最重要的事，不在于我们在何处，而在于我们朝着什么方向走。
```

### 1、WEB服务简介

```shell
# 目前最主流的三个Web服务器是Apache、Nginx、 IIS。
- Web服务器一般指网站服务器，可以向浏览器等Web客户端提供文档，也可以放置网站文件，让全世界浏览；可以放置数据文件，让全世界下载。
- WEB服务器也称为WWW(WORLD WIDE WEB)服务器，主要功能是提供网上信息浏览服务。
- 服务器是一种被动程序只有当Internet上运行其他计算机中的浏览器发出的请求时，服务器才会响应
```

### 2、WEB 服务协议

```shell
# WEB 服务应用层使用HTTP协议。
# HTML（标准通用标记语言下的一个应用）文档格式。--index.html
# 浏览器统一资源定位器（URL）。
# 为了解决HTTP协议的这一缺陷，需要使用另一种协议：安全套接字层超文本传输协议HTTPS。为了数据传输的安全，HTTPS在HTTP的基础上加入了SSL协议，SSL依靠证书来验证服务器的身份，并为浏览器和服务器之间的通信加密。
# WWW 采用的是浏览器/服务器结构
```

```shell
web服务器只能解析静态页面。 动态页面:只要和数据库进行连接的都属于动态页面，比如java写的代码，PHP的代码，python的代码。
```

```shell
web服务器:apache (参考服务器配置、优化。静态并发量最高2000) nginx(tengine) IIS  #端口全部为80!https为443端口
```

### Web 中间件

```shell
常见的web中间件也叫web容器:
php的中间件: php-fpm(php端口9000)
java的中间件: (tomcat端口8080。并发量到150就不行了)、jboss、Weblogic
python: uwsgi(默认端口5000)
```

```shell
前端页面:静态元素: .html .img js css swf 配合:apache、nginx。
后端页面:动态元素:根据不同的开发语言: .php .jsp  配合：java、php、python
SQL
数据库-mysql、mariadb
```

# Apache 服务的搭建与配置

## Apache 介绍

Apache HTTP Server（简称Apache）是Apache软件基金会的一个开放源码的网页服务器，Apache是世界使用排名第一的Web服务器软件。它可以运行在几乎所有广泛使用的计算机平台上，由于其跨平台和安全性被广泛使用，是最流行的Web服务器端软件之一。

```shell
Apache的主程序名叫httpd。
```

```shell
多实例: 在同一台服务器上启动多个相同apache进程。只要端口不一样就可以。
```

### 一、apache安装

```shell
[root@qfedu.com ~]# systemctl stop firewalld
[root@qfedu.com ~]# systemctl disable firewalld
[root@qfedu.com ~]# setenforce 0
[root@qfedu.com ~]# yum install -y httpd
[root@qfedu.com ~]# systemctl start httpd
[root@qfedu.com ~]# netstat -lntp | grep 80 #查看apache端口
tcp6       0      0 :::80                   :::*                    LISTEN      2776/httpd
#端口80.可以改
```

```shell
index.html:默认主页名称
默认发布网站的目录:/var/www/html
系统产生apache账户，家目录是:/usr/share/httpd
```

**1.apache目录介绍**

```shell
apache的工作目录(基准目录)
conf   存储配置文件
conf.d 存储配置子文件
logs   存储日志 
modules 存储模块
run    存储Pid文件,存放的pid号码。是主进程号
```

```shell
认识主配置文件:
# vim /etc/httpd/conf/httpd.conf 
ServerRoot "/etc/httpd"             #工作目录
Listen 80                           #监听端口
Listen 192.168.2.8:80 指定监听的本地网卡 可以修改
User apache    					    # 子进程的用户，有可能被人改称www账户
Group apache   						# 子进程的组
ServerAdmin root@localhost  		# 设置管理员邮件地址
DocumentRoot "/var/www/html"        # 发布网站的默认目录，想改改这里。
IncludeOptional conf.d/*.conf       # 包含conf.d目录下的*.conf文件

# 设置DocumentRoot指定目录的属性
<Directory "/var/www/html">   		# 网站容器开始标识
Options Indexes FollowSymLinks   	# 找不到主页时，以目录的方式呈现，并允许链接到网站根目录以外
AllowOverride None               	# 对目录设置特殊属性:none不使用.htaccess控制,all允许
Require all granted                 # granted表示运行所有访问，denied表示拒绝所有访问
</Directory>    					# 容器结束
DirectoryIndex index.html      		# 定义主页文件，当访问到网站目录时如果有定义的主页文件，网站会自动访问
```

### 二、访问控制

**1.准备测试页面**

```shell
[root@qfedu.com ~]# echo test1 > /var/www/html/index.html #编写测试文件
```

**2.访问控制测试**

**可以直接编辑apache主配置文件**

```shell
1.默认允许所有主机访问
[root@qfedu.com ~]# vim /etc/httpd/conf/httpd.conf
```

![image-20200806202746369](assets/image-20200806202746369.png)

```shell
[root@qfedu.com ~]# systemctl restart httpd
```

![image-20200806204234875](assets/image-20200806204234875.png)

```shell
2.只拒绝一部分客户端访问:
[root@qfedu.com ~]# vim /etc/httpd/conf/httpd.conf
```

![image-20200806210039708](assets/image-20200806210039708.png)

```shell
[root@qfedu.com ~]# systemctl restart httpd
```

![image-20200806203546116](assets/image-20200806203546116.png)

```shell
[root@test ~]# curl -I http://192.168.153.144  #用另外一台机器测试访问成功
HTTP/1.1 200 OK
Date: Thu, 06 Aug 2020 20:40:37 GMT
Server: Apache/2.4.6 (CentOS)
Last-Modified: Thu, 06 Aug 2020 20:12:02 GMT
ETag: "6-5ac3b1a02ac4f"
Accept-Ranges: bytes
Content-Length: 6
Content-Type: text/html; charset=UTF-8
```

```shell
在Linux中curl是一个利用URL规则在命令行下工作的文件传输工具，它支持文件的上传和下载，是综合传输工具，习惯称url为下载工具。
-o：指定下载路径
-I:查看服务器的响应信息

404 没有访问页面
403 被拒绝访问
202 正常访问
```

```shell
3.拒绝所有人
[root@qfedu.com ~]# vim /etc/httpd/conf/httpd.conf
```

![image-20200806205725058](assets/image-20200806205725058.png)

```shell
[root@qfedu.com ~]# systemctl restart httpd
```

![image-20200806203546116](assets/image-20200806203546116.png)

```shell
[root@test ~]# curl -I http://192.168.153.144
HTTP/1.1 403 Forbidden
Date: Thu, 06 Aug 2020 20:38:00 GMT
Server: Apache/2.4.6 (CentOS)
Content-Type: text/html; charset=iso-8859-1
```

#### 修改默认网站发布目录

```shell
[root@qfedu.com ~]# vim /etc/httpd/conf/httpd.conf
119  DocumentRoot "/www"            							# 修改网站根目录为/www
131  <Directory "/www">               							# 把这个也对应的修改为/www

[root@qfedu.com ~]# mkdir /www    ##创建定义的网站发布目录
[root@qfedu.com ~]# echo "这是新修改的网站家目录/www" > /www/index.html #创建测试页面
[root@qfedu.com ~]# systemctl restart httpd      #重启服务
```

![image-20200806204634696](assets/image-20200806204634696.png)

### 三、虚拟主机

```shell
虚拟主机:多个网站在一台服务器上。web服务器都可以实现。
三种:基于域名 基于端口 基于Ip
```

```shell
1.基于域名
[root@qfedu.com ~]# cd /etc/httpd/conf.d/
[root@qfedu.com conf.d]# touch www.tianbao.com.conf
[root@qfedu.com conf.d]# vim www.tianbao.com.conf
<VirtualHost *:80>   #指定虚拟主机端口，*代表监听本机所有ip，也可以指定ip
DocumentRoot /tianbao     #指定发布网站目录，自己定义
ServerName www.tianbao.com  #指定域名，可以自己定义
<Directory "/tianbao">
  AllowOverride None    #设置目录的特性，如地址重写
  Require all granted   #允许所有人访问
</Directory>
</VirtualHost>
curl -I www.tianbao.com
vim /etc/hosts
   ip    www.tianbao.com
curl -I www.tianbao.com
systemctl restart httpd
拒绝连接
mkdir /tianbao
echo “tianbao....” >> /tianbao/index.html
curl  www.tianbao.com


mv www.tianbao.com.conf  www.tianbao_cainana.com.conf
 
<VirtualHost *:80>
DocumentRoot /soho
ServerName test.soso666.com
<Directory "/soho/">
  AllowOverride None
  Require all granted
</Directory>
</VirtualHost>
[root@qfedu.com ~]# mkdir /soso #创建发布目录
[root@qfedu.com ~]# mkdir /soho
[root@qfedu.com ~]# echo qianfen > /soso/index.html #创建测试页面
[root@qfedu.com ~]# echo qfedu > /soho/index.html
[root@qfedu.com ~]# systemctl restart httpd
```

```shell
在wind电脑上面打开C:\Windows\System32\drivers\etc\hosts文件。可以用管理员身份打开
```

![image-20200806211348899](assets/image-20200806211348899.png)

测试访问

![image-20200806211145051](assets/image-20200806211145051.png)

![image-20200806211329944](assets/image-20200806211329944.png)

**基于端口**

```shell
[root@qfedu.com ~]# vim /etc/httpd/conf/httpd.conf  ---添加
```

![image-20200806210650822](assets/image-20200806210650822.png)

```shell
2.基于端口
[root@qfedu.com ~]# vim /etc/httpd/conf.d/test.conf
<VirtualHost *:80>
  DocumentRoot /soso
  ServerName www.soso666.com
<Directory "/soso/">
  AllowOverride None
  Require all granted
</Directory>
</VirtualHost>

<VirtualHost *:81>   #修改端口
  DocumentRoot /soho
  ServerName test.soso666.com
<Directory "/soho/">
  AllowOverride None
  Require all granted
</Directory>
</VirtualHost>
[root@qfedu.com ~]# systemctl restart httpd
注意：解析并没有变
```

访问：www.soso666.com

![image-20200806211538434](assets/image-20200806211538434.png)

访问: test.soso666.com:81

![image-20200806211455003](assets/image-20200806211455003.png)

```shell
3.基于IP
[root@qfedu.com ~]# ifconfig ens33:0 192.168.153.123  #添加一个临时ip
[root@qfedu.com ~]# vim /etc/httpd/conf.d/test.conf
<VirtualHost 192.168.153.144:80>   #指定ip
  DocumentRoot /soso
  ServerName www.soso666.com
<Directory "/soso/">
  AllowOverride None
  Require all granted
</Directory>
</VirtualHost>

<VirtualHost 192.168.153.123:80>   #指定ip
  DocumentRoot /soho
  ServerName test.soso666.com
<Directory "/soho/">
  AllowOverride None
  Require all granted
</Directory>
</VirtualHost>
[root@qfedu.com ~]# systemctl restart httpd

#取消添加的ip地址
#ifconfig ens33:0 192.168.153.123 down
```

可以配置本地解析，也可以不配本地解析

![image-20200806212232477](assets/image-20200806212232477.png)

![image-20200806212212299](assets/image-20200806212212299.png)

###### 面试

```shell
进程和线程的区别：
线程：线程来源于进程
线程模式需要事先开启进程
线程模式并发量高
进程：进程稳定性高，线程稳定性低
进程独占内存
线程共享进程内存，一个进程可有有多个线程
```

###### Apache的工作模式---面试

```shell
apche2.2工作模式？介绍下特点，说明什么情况下采取不同的工作模式？
apche 工作模式，分别是prefork，worker
prefork--进程模式 是一种进程，进程去请求处理，容易消耗内存但是稳定，某个进程出现问题不会影响其他请求，要求稳定时使用。
==============================================
worker--线程模式 使用多个子进程，每个子进程有多个线程，使用线程去处理请求，消耗内存小稳定不好，在访问量多的时候使用。
```

## Nginx 服务的搭建与配置

#### Nginx介绍

**Nginx是一款轻量级的Web 服务器/反向代理服务器及电子邮件（IMAP/POP3）代理服务器**，由俄罗斯的程序设计师Igor Sysoev所开发，其特点是占有内存少，并发能力强。事实上nginx的并发能力确实在同类型的网页服务器中表现较好。

#### 安装 Nginx

**1.2Nginx基本使用**

```shell
获取Nginx
Nginx的官方主页： http://nginx.org
```

```shell
关闭防火墙关闭selinux
[root@qfedu.com ~]# systemctl stop firewalld  #关闭防火墙
[root@qfedu.com ~]# systemctl disable firewalld #开机关闭防火墙
[root@qfedu.com ~]# setenforce 0  #临时关闭selinux
[root@qfedu.com ~]# getenforce   #查看selinux状态

Nginx安装:
Yum方式：
[root@qfedu.com ~]# cd /etc/yum.repos.d/
[root@qfedu.com yum.repos.d]# vi nginx.repo  #编写nginx的yum源
[nginx]
name=nginx
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
[root@qfedu.com yum.repos.d]# yum clean all
[root@qfedu.com yum.repos.d]# yum makecache
[root@qfedu.com ~]# yum install -y nginx  #安装nginx
```

```shell
[root@qfedu.com ~]# systemctl start nginx  #启动
[root@qfedu.com ~]# systemctl restart nginx #重启
[root@qfedu.com ~]# systemctl enable nginx  #开机启动
[root@qfedu.com ~]# systemctl stop nginx  #关闭
```

```shell
1.查看nginx状态
[root@qfedu.com ~]# ps aux | grep nginx 
root       3927  0.0  0.0  46384   968 ?        Ss   18:46   0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
nginx      3928  0.0  0.1  46792  1932 ?        S    18:46   0:00 nginx: worker process
root       3932  0.0  0.0 112660   968 pts/1    R+   18:47   0:00 grep --color=auto nginx
2.查看nginx端口
[root@qfedu.com ~]# netstat -lntp | grep 80
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      3927/nginx: master
#注意：nginx默认端口为80
3.测试主页是否可以访问：
[root@qfedu.com ~]# curl -I http://127.0.0.1
HTTP/1.1 200 OK
Server: nginx/1.16.1
Date: Sat, 16 Nov 2019 10:49:48 GMT
Content-Type: text/html
Content-Length: 635
Last-Modified: Fri, 11 Oct 2019 06:45:33 GMT
Connection: keep-alive
ETag: "5da0250d-27b"
Accept-Ranges: bytes
```

![image-20191116185020795](assets/image-20191116185020795.png)

```shell

[root@cainana ~]# vim /etc/nginx/nginx.conf
server {
    listen       80;   #监听的端口
    server_name  localhost;  #设置域名或主机名

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main; #日志存放路径

    location / {                        #请求级别:匹配请求路径
        root   /cainana;   #默认网站发布目录
        index  cainana.html;    #默认打开的网站主页
    }
   }
   }

mkdir /cainana
chmod 777 /cainana -R
echo "happy" >> /cainana/cainana.html
systemctl restart nginx
用windos打开网页输入虚拟机ip
```

#### 常见的组合方式

```shell
LNMP (Linux + Nginx + MySQL/Mariadb + PHP)  #php-fpm进程，这个组合是公司用的最多的组合
LAMP (Linux + Apache + MySQL/Mariadb + PHP) 
Nginx + Tomcat   #java项目常用的组合。取代apache
```
