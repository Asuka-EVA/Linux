# disk basic partition

```shell
1、首先需要先给虚拟机添加磁盘            步骤：分区。格式化。挂载。
[root@qfedu.com ~]# ll /dev/sd*
brw-rw----. 1 root disk 8,  0 Nov  7 23:15 /dev/sda
brw-rw----. 1 root disk 8,  1 Nov  7 23:15 /dev/sda1
brw-rw----. 1 root disk 8,  2 Nov  7 23:15 /dev/sda2
brw-rw----. 1 root disk 8, 16 Nov  7 23:15 /dev/sdb
brw-rw----. 1 root disk 8, 32 Nov  7 23:15 /dev/sdc
[root@qfedu.com ~]# lsblk  #查看磁盘设备
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part 
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
sdb               8:16   0   10G  0 disk 
sdc               8:32   0    8G  0 disk 
```

```shell
2、fdisk
MBR   14个分区（4个主分区，扩展分区，逻辑分区）

[root@qfedu.com ~]# fdisk -l /dev/sdb #查看磁盘分区信息
fdisk /dev/sdb     #通过fdisk[磁盘名称]对制定的磁盘分区

# lsblk 查看分区结果
【如果分区后无法发现分区结果，请刷新分区表后再次查看】
# partprobe /dev/sdb
```

```shell
3、gdisk
GPT  128个主分区
创建分区
[root@qfedu.com ~]# yum -y install gdisk  #安装分区工具
[root@qfedu.com ~]# gdisk -l /dev/sdb
[root@qfedu.com ~]# gdisk /dev/sdb
```

```shell
4、创建文件系统(格式化)centos7默认使用xfs
[root@qfedu.com ~]# mkfs.ext4 /dev/sdb1   #格式化成ext4格式的文件系统
[root@qfedu.com ~]# mkfs.xfs /dev/sdc2   #格式化成xfs格式的文件系统
```

```shell
5、挂载mount使用
[root@qfedu.com ~]# mkdir /mnt/disk1   #创建挂载目录
[root@qfedu.com ~]# mkdir /mnt/disks   #创建挂载目录
[root@qfedu.com ~]# mount -o rw /dev/sdb1 /mnt/disk1/  #-o 指定读写权限（ro只读，rx读写）
mount参数:
-o 指定读写权限
-a 需要定义(/etc/fstab)执行-a才会自动挂载
[root@qfedu.com ~]# mount /dev/sdc2 /mnt/disks/
```

```shell
6、查看磁盘挂载与磁盘使用空间
[root@qfedu.com ~]# df -Th
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root xfs        17G  1.2G   16G   7% /
devtmpfs                devtmpfs  982M     0  982M   0% /dev
tmpfs                   tmpfs     993M     0  993M   0% /dev/shm
tmpfs                   tmpfs     993M  8.7M  984M   1% /run
tmpfs                   tmpfs     993M     0  993M   0% /sys/fs/cgroup
/dev/sda1               xfs      1014M  125M  890M  13% /boot
tmpfs                   tmpfs     199M     0  199M   0% /run/user/0
/dev/sdb1               ext4      283M  2.1M  262M   1% /mnt/disk1
/dev/sdc2               xfs       197M   11M  187M   6% /mnt/disks
参数解释：
-T  打印文件系统类型
-h 人性化显示，磁盘空间大小
```

```shell
7、取消挂载
[root@qfedu.com ~]# umount /mnt/disks/
[root@qfedu.com ~]# umount -l /mnt/disk1/ #强行卸载，即使目录有资源被进程占用，也可以卸载
```

# fstab-Automatically mount at boot

```shell
/etc/fstab文件实现开机的时候自动挂载
[root@qfedu.com ~]# blkid /dev/sdb1  #查看uuid和文件系统类型
/dev/sdb1: UUID="d1916638-bd0a-4474-8051-f788116a3a92" TYPE="ext4"
[root@qfedu.com ~]# vim /etc/fstab
参数解释：
第1列:挂载设备
(1)/dev/sda5  
(2)UUID=设备的uuid   rhel6/7的默认写法   同一台机器内唯一的一个设备标识
第2列:挂载点
第3列:文件系统类型
第4列:文件系统属性	
第5列:是否对文件系统进行磁带备份：0 不备份
第6列:是否检查文件系统：0 不检查
```

![image-20191108154554145.png](https://github.com/Asuka-EVA/Linux/blob/main/disk%20management/assets/image-20191108154554145.png?raw=true)

```shell
[root@qfedu.com ~]# mount -a #自动挂载
```

```shell
xfs格式
[root@qfedu.com ~]# vim /etc/fstab
/dev/sdc2       /mnt/disks      xfs     defaults        0 0
[root@qfedu.com ~]# mount -a
```

```shell
/etc/rc.d/rc.local开机自动挂载
这个配置文件会在用户登陆之前读取，这个文件中写入了什么命令，在每次系统启动时都会执行一次。也就是说，如果有任何需要在系统启动时运行的工作，则只需写入 /etc/rc.d/rc.local 配置文件即可
```

```shell
[root@qfedu.com ~]# vim /etc/rc.d/rc.local #将挂载命令直接写到文件中
```

![image-20191108155316602](https://github.com/Asuka-EVA/Linux/blob/main/disk%20management/assets/image-20191108155316602.png?raw=true)

```shell
[root@qfedu.com ~]# chmod +x /etc/rc.d/rc.local #添加执行权限
[root@qfedu.com ~]# reboot
```

# Logical Volume Manager

```shell
1、创建lvm
首先准备添加3块磁盘：可以是/dev/sdb这种没有分区的也可以是/dev/sdb1这种已经分区了的
注意：如果没有pv命令安装 #yum install -y lvm2
[root@linux-server ~]# ll /dev/sd*
brw-rw----. 1 root disk 8,  0 Nov  9 12:59 /dev/sda
brw-rw----. 1 root disk 8,  1 Nov  9 12:59 /dev/sda1
brw-rw----. 1 root disk 8,  2 Nov  9 12:59 /dev/sda2
brw-rw----. 1 root disk 8, 16 Nov  9 12:59 /dev/sdb
brw-rw----. 1 root disk 8, 32 Nov  9 12:59 /dev/sdc
brw-rw----. 1 root disk 8, 48 Nov  9 14:04 /dev/sdd
```

```shell
2、创建pv
[root@linux-server ~]# pvcreate /dev/sdb #创建pv
  Physical volume "/dev/sdb" successfully created.
[root@linux-server ~]# pvs  #查看pv
  PV         VG     Fmt  Attr PSize   PFree 
  /dev/sdb          lvm2 ---   10.00g 10.00g
[root@linux-server ~]# pvscan  #查看pv
  PV /dev/sda2   VG centos          lvm2 [<19.00 GiB / 0    free]
  PV /dev/sdb                       lvm2 [10.00 GiB]
  Total: 2 [<29.00 GiB] / in use: 1 [<19.00 GiB] / in no VG: 1 [10.00 GiB]
```

```shell
3、创建vg
[root@linux-server ~]# vgcreate vg1 /dev/sdb   #创建vg
  Volume group "vg1" successfully created
参数解释：
-s 16M 指的是在分区的时候指定vg的大小。
[root@linux-server ~]# vgs    #查看vg
  VG     #PV #LV #SN Attr   VSize   VFree  
  centos   1   2   0 wz--n- <19.00g      0 
  vg1      1   0   0 wz--n- <10.00g <10.00g
[root@linux-server ~]# vgscan
  Reading volume groups from cache.
  Found volume group "centos" using metadata type lvm2
  Found volume group "vg1" using metadata type lvm2
[root@linux-server ~]# vgdisplay #查看vg
--- Volume group ---
  VG Name               vg1
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <10.00 GiB
  PE Size               4.00 MiB
  Total PE              2559
  Alloc PE / Size       0 / 0 MiB
  Free  PE / Size       2559 / <10.00 GiB
  VG UUID               bVvQxe-4M2A-mMuk-b3gJ-4Maj-0xDy-5QZDOp
```

```shell
4、创建lv
[root@linux-server ~]# lvcreate -L 150M -n lv1 vg1  #创建lv
  Rounding up size to full physical extent 152.00 MiB
  Logical volume "lv1" created.
[root@linux-server ~]# lvcreate -l 20 -n lv2 vg1  #采用PE方式在创建一个lv
  Logical volume "lv2" created.
参数解释：
-L 指定lv的大小
-n 给创建的lv起一个名字
-l 20 指定PE 
[root@linux-server ~]# lvs   #查看lv
  LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root centos -wi-ao---- <17.00g                                                    
  swap centos -wi-ao----   2.00g                                                    
  lv1  vg1    -wi-a----- 152.00m                                                    
  lv2  vg1    -wi-a-----  80.00m 
```

```shell
5、制作文件系统并挂载
[root@linux-server ~]# mkfs.xfs /dev/vg1/lv1
[root@linux-server ~]# mkfs.ext4 /dev/vg1/lv2
[root@linux-server ~]# mkdir /mnt/lv{1..2}
[root@linux-server ~]# mount /dev/vg1/lv1 /mnt/lv1
[root@linux-server ~]# mount /dev/vg1/lv2 /mnt/lv2
[root@linux-server ~]# df -Th
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/vg1-lv1     xfs       149M  7.8M  141M   6% /mnt/lv1
/dev/mapper/vg1-lv2     ext4       74M  1.6M   67M   3% /mnt/lv2
```

# LVM expansion

```shell
#注意：如果lv所在的vg有空间直接扩容就ok了！
```

```shell
1、扩大VG vgextend
1.创建pv
[root@linux-server ~]# pvcreate /dev/sdc 
  Physical volume "/dev/sdc" successfully created.
2.直接vgextend扩容
[root@linux-server ~]# vgextend vg1 /dev/sdc       #vg1卷组名字，将/dev/sdc扩展到vg1中
  Volume group "vg1" successfully extended
[root@linux-server ~]# vgs
  VG     #PV #LV #SN Attr   VSize   VFree 
  centos   1   2   0 wz--n- <19.00g     0 
  vg1      2   2   0 wz--n-  19.99g 18.23g
```

```shell
2、扩大LV lvextend
[root@linux-server ~]# vgs  #查看vg
  VG     #PV #LV #SN Attr   VSize   VFree 
  centos   1   2   0 wz--n- <19.00g     0 
  vg1      1   2   0 wz--n- <19.99g <9.77g
[root@linux-server ~]# lvextend -L 850M /dev/vg1/lv1  #扩展到850M
[root@linux-server ~]# lvextend -L +850M /dev/vg1/lv1 #在原有基础上加850M
[root@linux-server ~]# lvs
  LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root centos -wi-ao---- <17.00g                                                    
  swap centos -wi-ao----   2.00g                                                    
  lv1  vg1    -wi-ao----   1.66g                                                    
  lv2  vg1    -wi-ao----  80.00m 
[root@linux-server ~]# lvextend -l +15 /dev/vg1/lv1 #在原有基础上加15个PE
[root@linux-server ~]# lvs
  LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root centos -wi-ao---- <17.00g                                                    
  swap centos -wi-ao----   2.00g                                                    
  lv1  vg1    -wi-ao----  <1.68g                                                    
  lv2  vg1    -wi-ao----  80.00m
```

```shell
3、FS(file system)文件系统扩容
[root@linux-server ~]# df -Th
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/vg1-lv1     xfs       149M  7.8M  141M   6% /mnt/lv1
/dev/mapper/vg1-lv2     ext4       74M  1.6M   67M   3% /mnt/lv2
[root@linux-server ~]# xfs_growfs /dev/vg1/lv1  #xfs扩容
[root@linux-server ~]# resize2fs /dev/vg1/lv2   #ext4扩容
[root@linux-server ~]# df -Th
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/vg1-lv1     xfs       1.7G  9.1M  1.7G   1% /mnt/lv1
/dev/mapper/vg1-lv2     ext4       74M  1.6M   67M   3% /mnt/lv2
```

# swap partition

```shell
1、查看当前的交换分区
[root@linux-server ~]# free -m 
              total        used        free      shared  buff/cache   available
Mem:           1984         155        1679           8         149        1656
Swap:          2047           0        2047
[root@linux-server ~]# swapon -s  #查看交换分区信息
```

```shell
2、增加交换分区可以是基本分区，LVM，File
[root@linux-server ~]# fdisk /dev/sdd  #分一个主分区出来
[root@linux-server ~]# partprobe /dev/sdd #刷新分区表
[root@linux-server ~]# ll /dev/sdd*
brw-rw----. 1 root disk 8, 16 Nov  9 14:11 /dev/sdd
brw-rw----. 1 root disk 8, 17 Nov  9 14:11 /dev/sdd1
```

```shell
3、初始化
[root@linux-server ~]# mkswap /dev/sdd1  #初始化
Setting up swapspace version 1, size = 5242876 KiB
no label, UUID=d2fd3bc0-10c0-4aeb-98ea-6b640d29b783
```

```shell
4、挂载
[root@linux-server ~]# blkid /dev/sdd1  #查看UUID
/dev/sdd1: UUID="d2fd3bc0-10c0-4aeb-98ea-6b640d29b783" TYPE="swap" 
[root@linux-server ~]# vim /etc/fstab  #制作开机挂载
/dev/sdd1       swap    swap    defaults        0 0
[root@linux-server ~]# swapon -a #激活swap分区(读取/etc/fstab)
[root@linux-server ~]# swapon -s
Filename                                Type            Size    Used    Priority
/dev/dm-1                               partition       2097148 0       -1
/dev/sdd1                               partition       5242876 0       -2

#swapoff /dev/sdd1  #关闭swap分区
```

```shell
5、file制作
[root@linux-server ~]# dd if=/dev/zero of=/swap2.img bs=1M count=512
解释：dd 读入  从空设备里面拿空块 到交换分区                块多大  一共多少兆
[root@linux-server ~]# mkswap /swap2.img  #初始化
[root@linux-server ~]# vim /etc/fstab
/swap2.img      swap    swap    defaults        0 0
[root@linux-server ~]# chmod 600 /swap2.img #交换分区权限需要设置为600，默认644权限不安全。
[root@linux-server ~]# swapon -a
[root@linux-server ~]# swapon -s
Filename                                Type            Size    Used    Priority
/dev/dm-1                               partition       2097148 0       -1
/dev/sdd1                               partition       5242876 0       -2
/swap2.img                              file    524284  0       -3
```

# mount

```shell
[root@linux-server ~]# mount  #查看已经挂载上的系统的属性
```

```shell
exec/noexec
[root@linux-server ~]# mount /dev/vg1/lv1 /mnt/lv1/		#挂载默认是有执行权限的
[root@linux-server ~]# mount -o noexec /dev/vg1/lv2 /mnt/lv2  #不允许执行二进制文件
[root@linux-server ~]# cat /mnt/lv1/hello.sh
#!/bin/bash
echo "hello"

[root@linux-server ~]# cat /mnt/lv2/hello2.sh
#!/bin/bash
echo "hello"
[root@linux-server ~]# chmod +x /mnt/lv1/hello.sh 
[root@linux-server ~]# chmod +x /mnt/lv2/hello2.sh
[root@linux-server ~]# /mnt/lv1/hello.sh
hello
[root@linux-server ~]# /mnt/lv2/hello2.sh
-bash: /mnt/lv2/hello2.sh: Permission denied
```

```shell
取消挂载
[root@linux-server ~]# df -Th
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/vg1-lv1     xfs       1.7G   34M  1.7G   2% /mnt/lv1
/dev/mapper/vg1-lv2     ext4       74M  1.6M   67M   3% /mnt/lv2
[root@linux-server ~]# umount /mnt/lv2/
```

# lv-remove

```shell
[root@localhost ~]# lvremove /dev/vg2/lv2

Do you really want to remove active logical volume vg2/lv2? [y/n]: y

  Logical volume "lv2" successfully removed
  
  #先移除lv

[root@localhost ~]# vgremove /dev/vg2

  Volume group "vg2" successfully removed
  
  #再移除vg

[root@localhost ~]# pvremove /dev/sdc

  Labels on physical volume "/dev/sdc" successfully wiped.

  #移除pv
```

