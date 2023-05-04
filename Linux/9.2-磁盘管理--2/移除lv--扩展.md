# lv移除

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
