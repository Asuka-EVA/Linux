# Construction and configuration of apache service

## apache install

```shell
[root@Asuka ~]# systemctl stop firewalld
[root@Asuka ~]# systemctl disable firewalld
[root@Asuka ~]# setenforce 0
[root@Asuka ~]# yum install -y httpd
[root@Asuka ~]# systemctl start httpd
[root@Asuka ~]# netstat -lntp | grep 80 #查看apache端口
tcp6       0      0 :::80                   :::*                    LISTEN      2776/httpd
#端口80.可以改
```

```shell
index.html:默认主页名称
默认发布网站的目录:/var/www/html
系统产生apache账户，家目录是:/usr/share/httpd
```

```shell
apache目录介绍
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

## Access control

```shell
访问控制步骤：
1、vim  /etc/httpd/conf/httpd.conf
2、修改参数(允许所有主机访问、只拒绝一部分访问、拒绝所有人访问)
```

```shell
准备测试页面
[root@Asuka ~]# echo test1 > /var/www/html/index.html #编写测试文件
```

```shell
访问控制页面
可以直接编辑apache主配置文件
1.默认允许所有主机访问
[root@Asuka ~]# vim /etc/httpd/conf/httpd.conf
```

![image-20200806202746369](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806202746369.png?raw=true)

```shell
[root@Asuka ~]# systemctl restart httpd
```

```shell
2.只拒绝一部分客户端访问:
[root@Asuka ~]# vim /etc/httpd/conf/httpd.conf
```

![image-20200806210039708](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806210039708.png?raw=true)

```shell
[root@Asuka ~]# systemctl restart httpd
```

![image-20200806203546116](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806203546116.png?raw=true)

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

```
3、拒绝所有人
[root@Asuka ~]# vim /etc/httpd/conf/httpd.conf
```

![image-20200806205725058](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806205725058.png?raw=true)

```shell
[root@Asuka ~]# systemctl restart httpd
```

![image-20200806203546116](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806203546116-16816495535891.png?raw=true)

```shell
[root@test ~]# curl -I http://192.168.153.144
HTTP/1.1 403 Forbidden
Date: Thu, 06 Aug 2020 20:38:00 GMT
Server: Apache/2.4.6 (CentOS)
Content-Type: text/html; charset=iso-8859-1
```

## Modify the default website publishing directory

```shell
[root@Asuka ~]# vim /etc/httpd/conf/httpd.conf
119  DocumentRoot "/www"            							# 修改网站根目录为/www
131  <Directory "/www">               							# 把这个也对应的修改为/www

[root@Asuka ~]# mkdir /www    ##创建定义的网站发布目录
[root@Asuka ~]# echo "这是新修改的网站家目录/www" > /www/index.html #创建测试页面
[root@Asuka ~]# systemctl restart httpd      #重启服务
```

![image-20200806204634696](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806204634696.png?raw=true)

## virtual host

```shell
虚拟主机:多个网站在一台服务器上。web服务器都可以实现。
三种:基于域名 基于端口 基于Ip
```

```shell
1.基于域名
[root@Asuka ~]# cd /etc/httpd/conf.d/
[root@Asuka conf.d]# touch www.tianbao.com.conf
[root@Asuka conf.d]# vim www.tianbao.com.conf
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
[root@Asuka ~]# mkdir /soso #创建发布目录
[root@Asuka ~]# mkdir /soho
[root@Asuka ~]# echo qianfen > /soso/index.html #创建测试页面
[root@Asuka ~]# echo qfedu > /soho/index.html
[root@Asuka ~]# systemctl restart httpd
```

```shell
在wind电脑上面打开C:\Windows\System32\drivers\etc\hosts文件。可以用管理员身份打开
```

![image-20200806211348899](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806211348899.png?raw=true)

```shell
测试访问
```

![image-20200806211329944](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806211329944.png?raw=true)

```shell
2、基于端口
[root@Asuka ~]# vim /etc/httpd/conf/httpd.conf  ---添加
```

![image-20200806210650822](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806210650822.png?raw=true)

```shell
[root@Asuka ~]# vim /etc/httpd/conf.d/test.conf
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
[root@Asuka ~]# systemctl restart httpd
注意：解析并没有变
```

```shell
访问：www.soso666.com
```

![image-20200806211538434](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806211538434.png?raw=true)

```shell
访问: test.soso666.com:81
```

![image-20200806211455003](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806211455003.png?raw=true)

```shell
3.基于IP
[root@Asuka ~]# ifconfig ens33:0 192.168.153.123  #添加一个临时ip
[root@Asuka ~]# vim /etc/httpd/conf.d/test.conf
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
[root@Asuka ~]# systemctl restart httpd

#取消添加的ip地址
#ifconfig ens33:0 192.168.153.123 down
```

```shell
可以配置本地解析也可以不配置本地解析
```

![image-20200806212232477](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806212232477.png?raw=true)

![image-20200806212212299](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20200806212212299.png?raw=true)

# Construction and configuration of Nginx service

## nginx install

```shell
安装步骤：
1、检查防火墙
2、配置yum源
3、清理缓存，建立缓存
```

```shell
获取Nginx
Nginx的官方主页： http://nginx.org
```

```shell
关闭防火墙关闭selinux
[root@Asuka ~]# systemctl stop firewalld  #关闭防火墙
[root@Asuka ~]# systemctl disable firewalld #开机关闭防火墙
[root@Asuka ~]# setenforce 0  #临时关闭selinux
[root@Asuka ~]# getenforce   #查看selinux状态

Nginx安装:
Yum方式：
[root@Asuka ~]# cd /etc/yum.repos.d/
[root@Asuka yum.repos.d]# vi nginx.repo  #编写nginx的yum源
[nginx]
name=nginx
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
[root@Asuka yum.repos.d]# yum clean all
[root@Asuka yum.repos.d]# yum makecache
[root@Asuka ~]# yum install -y nginx  #安装nginx
```

```shell
[root@Asuka ~]# systemctl start nginx  #启动
[root@Asuka ~]# systemctl restart nginx #重启
[root@Asuka ~]# systemctl enable nginx  #开机启动
[root@Asuka ~]# systemctl stop nginx  #关闭
```

```shell
 0.0  46384   968 ?        Ss   18:46   0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
nginx      3928  0.0  0.1  46792  1932 ?        S    18:46   0:00 nginx: worker process
root       3932  0.0  0.0 112660   968 pts/1    R+   18:47   0:00 grep --color=auto nginx
2.查看nginx端口
[root@Asuka ~]# netstat -lntp | grep 80
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      3927/nginx: master
#注意：nginx默认端口为80
3.测试主页是否可以访问：
[root@Asuka ~]# curl -I http://127.0.0.1
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

![image-20191116185020795](https://github.com/Asuka-EVA/Linux/blob/main/web%20server/assets/image-20191116185020795.png?raw=true)

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

## common combination

```shell
LNMP (Linux + Nginx + MySQL/Mariadb + PHP)  #php-fpm进程，这个组合是公司用的最多的组合
LAMP (Linux + Apache + MySQL/Mariadb + PHP) 
Nginx + Tomcat   #java项目常用的组合。取代apache
```

