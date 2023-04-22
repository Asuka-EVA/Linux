# NAT fixed ip

```shell
1、网络地址(子网)：192.168.200.0
2、网关：192.168.200.2
3、根据以上信息，推出自己想要的IP:192.168.200.40
```

```shell
4、重新配置ip地址
cd /etc/sysconfig/network-scripts/
vim ifcfg-ens33

TYPE="Ethernet"
BOOTPROTO="none"#固定ip
DEVICE="ens33"
ONBOOT="yes"

IPADDR=192.168.174.40#你想要使用的ip地址
GATEWAY=192.168.174.2#网关
PREFIX=24#子网掩码
DNS1=114.114.114.114#域名服务器
```

```shell
5、重启网卡
systemctl restart network
```

```shell
6、永久关闭防火墙
# systemctl stop firewalld
# systemctl disable firewalld
# setenforce 0

# vi /etc/sysconfig/selinux
 SELINUX=enforcing  -----》SELINUX=disabled
 保存退出
```

```shell
7、安装初始化服务工具
# yum -y install vim wget unzip  net-tools
关闭虚拟机，然后打快照 
```

# bridge network fixed ip

```shell
1、网关：10.8.152.254
```

```shell
2、固定ip：需要通过脚本了解到
bash /root/ping.sh
#选择一个ip:10.8.152.239
```

```shell
3、重新配置ip地址
cd /etc/sysconfig/network-scripts/
vim ifcfg-ens33

TYPE="Ethernet"
BOOTPROTO="none"#固定ip
DEVICE="ens33"
ONBOOT="yes"

IPADDR=192.168.174.40#你想要使用的ip地址
GATEWAY=192.168.174.2#网关
PREFIX=24#子网掩码
DNS1=114.114.114.114#域名服务器
```

```shell
4、重启网卡
systemctl restart network
```

```shell
5、永久关闭防火墙
# systemctl stop firewalld
# systemctl disable firewalld
# setenforce 0

# vi /etc/sysconfig/selinux
 SELINUX=enforcing  -----》SELINUX=disabled
 保存退出
```

```shell
6、安装初始化工具
# yum -y install vim wget unzip  net-tools
关闭虚拟机，然后打快照 
```

