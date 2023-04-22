# Scheduled Tasks

```shell
[root@linux-server ~]# at now +1min    #一分钟后开始执行
at> useradd uuuu  
at> <EOT>     	#Ctrl+D
job 1 at Sat Mar 21 22:34:00 2015

[root@linux-server ~]# id uuuu
```

```shell
[root@linux-server ~]# vim at.jobs 
useradd u99 
useradd u00 
touch /a.txt

[root@linux-server ~]# at 20:33 < at.jobs
```

```shell
1. 准备sudo用户
[root@linux-server ~]# id jack
uid=1007(jack) gid=1012(jack) groups=1012(jack)
[root@linux-server ~]# useradd jack   #如果不存在创建
[root@linux-server ~]# visudo
  91 ## Allow root to run any commands anywhere
  92 root    ALL=(ALL)       ALL
  93 jack    ALL=(ALL)       NOPASSWD: ALL  #添加内容

[root@linux-server ~]# su - jack 

2. 以sudo 用户jack创建at任务
   [jack@linux-server ~]$ vim jack.at
   sudo useradd u200
   sudo useradd u300
   sudo touch /home/jack.txt
   [jack@linux-server ~]$ at 20:38 < jack.at                                     
```

# Cyclic scheduling executes cron user level

```shell
安装软件
    [root@qfedu.com ~]#  yum -y install crontabs  #如果软件不存在安装

启动服务
    rhel7:
    [root@qfedu.com ~]#  systemctl start crond.service
    [root@qfedu.com ~]#  systemctl status crond.service
    [root@qfedu.com ~]#  systemctl enable crond.service
[root@linux-server ~]# systemctl status crond.service  #查看服务状态

[root@linux-server ~]# ps -ef | grep crond 
root        755      1  0 20:18 ?        00:00:00 /usr/sbin/crond -n

#crond进程每分钟会处理一次计划任务

存储位置：
[root@linux-server ~]# cd /var/spool/cron/

管理方式： 
crontab -l	List the jobs for the current user. //列出当前用户的计划任务
crontab -r	Remove all jobs for the current users. //删除当前用户所有的计划任务
crontab -e	Edit jobs for the current user.  	//编辑当前用户的计划任务

管理员可以使用 
-u username, 去管理其他用户的计划任务
```

```shell
语法格式 :
Minutes   Hours    Day-of-Month    Month    Day-of-Week    Command 
 分钟	     小时	        日			 月		   周		   执行的命令，最好是命令的绝对路径
 0-59	  0-23  	  1-31         1-12	      0-7
   *       *           *              *        *

时间：
*：每
*/5 每隔分钟
，：不同的时间段
- ： 表示范围
```

```shell
1、实战
[root@linux-server ~]# vim /home/soso.sh         vi cront1.sh
#!/bin/bash
touch /opt/a.txt
[root@linux-server ~]# chmod +x /home/soso.sh

2、创建计划任务
[root@linux-server ~]# crontab -e			//当前用户编写计划任务

每天6:00执行
0 6 * * *  /home/soso.sh

每天8:40执行
40 8 * * * /home/soso.sh

每周六凌晨4:00执行
0 4 * * 6  /home/soso.sh

每周六凌晨4:05执行
5 4 * * 6  /home/soso.sh 

每周六凌晨5:00执行
0 5 * * 6  /home/soso.sh

每周一到周五9:30
30 9 * * 1-5  /home/soso.sh

每周一到周五8:00，每周一到周五9:00
0 8,9 * * 1-5   /home/soso.sh

每周六23:59
59 23 * * 6      /home/soso.sh

每天0:30
30 0 * * *    /home/soso.sh

[root@linux-server ~]# crontab -l      #列出计划任务

00 00 * * * /home/soso.sh			#每天凌晨

00 02 * * * ls			            #每天2:00整 

00 02 1 * * ls  			        #每月1号2:00整 

00 02 14 2 * ls	                    #每年2月14号2:00整

00 02 * * 7 ls  			        #每周日2:00整 

00 02 * 6 5 ls  			        #每年6月的周五2:00整

00 02 * * * ls			            #每天2:00整 

*/5 * * * * ls				        #每隔5分钟 

00 02 1,5,8 * * ls		                #每月1,5,8号的2:00整 

00 02 1-8 * * ls                    #每月1到8号的2:00整

3、使用其他用户创建
[root@linux-server ~]# crontab -u jack -e  #使用jack用户创建
[root@linux-server ~]# crontab -u jack -l  #查看jack用户的计划任务
[root@linux-server ~]# crontab -r  #删除当前用户的计划任务
[root@linux-server ~]# crontab -u jack -r #删除jack用户的计划任务
```

# logrotate-log rotation

```shell
配置日志轮转
[root@linux-server ~]# vim /etc/logrotate.conf	
weekly     			#轮转的周期，一周轮转，单位有年,月,日 
rotate 4			#保留4份 
create				#轮转后创建新文件 
dateext             #使用日期作为后缀 
#compress			#日志轮替时,旧的日志进行压缩 
include /etc/logrotate.d  			 #包含该目录下的配置文件,会引用该目录下面配置的文件

/var/log/wtmp {			          	#对该日志文件设置轮转的方法    
 monthly			                #一月轮转一次  
 minsize 1M			            	#最小达到1M才轮转,否则就算时间到了也不轮转
 create 0664 root utmp		        #轮转后创建新文件，并设置权限   
 rotate 2			                #保留2份 
}

/var/log/btmp {    
 missingok			              	#丢失不提示    
 monthly			                
 create 0600 root utmp		        
 rotate 1			                
} 
```

```shell
实战
例1：轮转文件/var/log/yum.log

[root@linux-server ~]# vim /etc/logrotate.d/yum	   
/var/log/yum.log {
 missingok                                #丢失不提醒
 #notifempty                              #空文件不轮转 
 #size 30k									#只要到了30k就轮转
 #yearly
 daily                                     #每天轮转一次   
 rotate 3      
 create 0644 root root 
}

测试：
[root@linux-server ~]# /usr/sbin/logrotate   -f  /etc/logrotate.conf	  #手动轮转    实际工作不加f
[root@linux-server ~]# ls /var/log/yum*
/var/log/yum.log  /var/log/yum.log-20191110

[root@linux-server ~]# grep yum /var/lib/logrotate/logrotate.status #查看记录所有日志文件最近轮转的时间
"/var/log/yum.log" 2019-11-10-21:26:14
```

# ssh-remote management service

```shell
1、安装
[root@linux-server ~]# yum install -y openssh*
1.服务器端启动服务：
systemctl  start  sshd
2.关闭防火墙和selinux
```

```shell
登录方式
远程登录：
[root@linux-server ~]# ssh root@192.168.246.114
参数解释：
root 用户默认不写为root，也可以使用其他用户
```

```shell
无密码登陆（ssh密钥认证）
1.产生公钥和私钥：  生成一对密钥：公钥+私钥
[root@linux-server ~]# ssh-keygen  #一直回车
2.查看钥匙的目录：
[root@linux-server ~]# cd /root/.ssh/
id_rsa  ---私钥
id_rsa.pub  ---公钥
known_hosts  ----确认过公钥指纹的可信服务器列表的文件
authorized_keys ---授权文件，是传输过公钥到对方服务后会自动重命名生成的
3.拷贝公钥给对方机器：
[root@linux-server ~]# ssh-copy-id 对方机器ip地址
[root@localhost .ssh]# ssh 10.8.152.118
ip地址：指的是对方服务器
4.远程连接的时候就不用输入密码了
```

```shell
修改端口号：
修改配置文件：
# vim /etc/ssh/sshd_config
17 #Port 22   #将注释去掉，修改端口号可以修改为自定义的。    65535范围内
[root@linux-server ~]# systemctl restart sshd

远程登录
-p：prot端口，指定端口，如果端口修改了需要指定    需要重启
案例：
[root@linux-server ~]# ssh root@192.168.246.158 -p 2222
```

# Remote copy

```shell
远程拷贝：
# scp  -P 端口号 /a.txt    ip：/路径
                源文件      目标地址

[root@linux-server ~]# scp -r -P 2222 test/ 192.168.246.158:/root/
谁是远程加谁ip
远程拷贝目标机器改了端口加-(大)P 
目录加 -r
```

