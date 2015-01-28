#!/system/bin/busybox sh

BUSYBOX="/system/bin/busybox"

/system/bin/chown system:system /dev/block/by-name/misc
/system/bin/chmod 0600 /dev/block/by-name/misc

/system/bin/chown rild:media /dev/mux*
/system/bin/chmod 0777 /dev/mux*

mkdir /boot-resource
mount -t vfat /dev/block/by-name/boot-resource  /boot-resource

if [ ! -e /data/system.notfirstrun ]; then	
    echo "do preinstall job"	
  
	/system/bin/sh /system/bin/pm preinstall /system/preinstall
	/system/bin/sh /system/bin/pm preinstall /sdcard/preinstall
	/system/bin/sh /system/bin/data_copy.sh


	$BUSYBOX touch /data/system.notfirstrun	
	
	 mkdir /databk
   mount -t ext4 /dev/block/by-name/databk /databk
   rm /databk/data_backup.tar
   umount /databk
   rmdir /databk
   echo "preinstall ok"

elif [ -e /boot-resource/data.need.backup ];then
   echo "data backup:tar /databk/data_backup.tar /data"
   mkdir /databk
   mount -t ext4 /dev/block/by-name/databk /databk
   
   rm /databk/data_backup.tar

   $BUSYBOX tar -cf /databk/data_backup.tar /data
   rm /boot-resource/data.need.backup
   rm /data/wifi_type
  
   umount /databk
   rmdir /databk

else 
   umount /databk
   rmdir /databk
   echo "do nothing"
fi
umount /boot-resource
rmdir /boot-resource





