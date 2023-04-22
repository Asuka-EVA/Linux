# set permanent static ip

```shell
[root@linux-server ~]# cd /etc/sysconfig/network-scripts/  #网卡配置文件存放路径
[root@linux-server network-scripts]# cp ifcfg-ens33 ifcfg-ens33.bak #将源文件备份
[root@linux-server network-scripts]# vi ifcfg-ens33 #编辑网卡配置文件
TYPE="Ethernet"         #网络类型：以太网类型
PROXY_METHOD="none"   
BROWSER_ONLY="no"
BOOTPROTO="static"    #默认值none或static 这两种属于静态获取ip地址，dhcp自动获取ip
IPADDR=192.168.246.134 #设置静态ip地址
GATEWAY=192.168.246.2 #设置网关，nat模式网关是2，桥接为1.
NETMASK=255.255.255.0  #设置掩码或者
#PREFIX=24
DEFROUTE="yes"  #是否设置默认路由，yes表示该配置
NAME="ens33"    #网卡名称，可以不存在
DEVICE="ens33"   #设备名称
ONBOOT="yes"    #开机启动
DNS1=114.114.114.114 #dns全国通用地址，dns最多可以设置三个
DNS2=8.8.8.8 #谷歌的dns
DNS3=202.106.0.20 #北京的DNS。
```

```shell
重启网络---修改完配置文件一定要重启网络
# systemctl restart network   #rhel7
# /etc/init.d/network restart  红帽5、6里面的。
```

![image-20191116135101705](D:\图片\typora\image-20191116135101705.png)

```shell
编辑DNS配置文件设置DNS
[root@linux-server ~]# vi /etc/resolv.conf   #添加如下内容
nameserver 114.114.114.114    #指定dns地址
```

# set dynamic ip

```shell
[root@linux-server ~]# vi /etc/sysconfig/network-scripts/ifcfg-ens33 
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="dhcp"   #只需要将这里修改为dhcp。
DEFROUTE="yes"
NAME="ens33"
DEVICE="ens33"
ONBOOT="yes"

重启网络
[root@linux-server ~]# systemctl restart network
```

![image-20191116135525810](D:\图片\typora\image-20191116135525810.png)

# Configure local parsing

```shell
写法：ip   主机名
[root@soso666 ~]# vi /etc/hosts    ---添加如下内容
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.246.130 soso666 soso   #添加解析
```

![image-20191116161635272](D:\图片\typora\image-20191116161635272.png)

# modify network card

```shell
1.修改网卡配置文件
[root@linux-server ~]# cd /etc/sysconfig/network-scripts/
[root@linux-server network-scripts]# mv ifcfg-ens33 ifcfg-eth0  #改名
[root@linux-server network-scripts]# vim ifcfg-eth0  #只需要修改配置文件中的名称
NAME="eth0"
DEVICE="eth0"
2.GRUB添加kernel参数
[root@linux-server ~]# vim /etc/sysconfig/grub   #在文件中最后一行添加
GRUB_CMDLINE_LINUX="...... net.ifnames=0" #告诉系统关闭原来命名功能
3.执行命令生效---#加载配置文件
[root@linux-server ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
4.重启机器
 # reboot
[root@linux-server ~]# cd /etc/sysconfig/network-scripts/
```

![image-20191130140057368](D:\图片\typora\image-20191130140057368.png)

![image-20191205144539217](D:\图片\typora\image-20191205144539217.png)