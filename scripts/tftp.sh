#!/bin/sh
X86_INSTALL_DIR=/usr/share/rmt/public/repo/SUSE/Install/x86/SLE-SERVER/15-SP1

mkdir -p ${X86_INSTALL_DIR}/

mount /dev/cdrom /mnt
rsync -avP /mnt/ ${X86_INSTALL_DIR}/
umount /mnt


mkdir -p /srv/tftpboot/
mkdir /srv/tftpboot/bios
mkdir /srv/tftpboot/bios/x86
mkdir /srv/tftpboot/EFI
mkdir /srv/tftpboot/EFI/x86
mkdir /srv/tftpboot/EFI/x86/boot
mkdir /srv/tftpboot/EFI/armv8
mkdir /srv/tftpboot/EFI/armv8/boot


### x86 BIOS PXE
cp ${X86_INSTALL_DIR}/boot/x86_64/loader/{linux,initrd,message} /srv/tftpboot/bios/x86/
cp /usr/share/syslinux/vesamenu.c32 /usr/share/syslinux/pxelinux.0 /srv/tftpboot/bios/x86/
mkdir -p /srv/tftpboot/bios/x86/pxelinux.cfg
cat << EOF >> /srv/tftpboot/bios/x86/pxelinux.cfg/default
default vesamenu.c32
prompt 0
timeout 50

menu title PXE Install Server

label harddisk
  menu label Local Hard Disk
  localboot 0

label install-caasp-node
  menu label CaaSP Node
  kernel linux
  append load ramdisk=1 initrd=initrd netsetup=dhcp install=http://router.caasp.suse.ru/repo/SUSE/Install/x86/SLE-SERVER/15-SP1/ autoyast=http://router.caasp.suse.ru/autoyast/autoinst_caasp.xml

EOF

### x86 EFI
cp ${X86_INSTALL_DIR}/EFI/BOOT/{bootx64.efi,grub.efi,MokManager.efi} /srv/tftpboot/EFI/x86/
cp ${X86_INSTALL_DIR}/boot/x86_64/loader/{linux,initrd} /srv/tftpboot/EFI/x86/boot

cat << EOF >> /srv/tftpboot/EFI/x86/boot/grub.cfg

  timeout=60

default=0

# look for an installed SUSE system and boot it
menuentry "Boot from Hard Disk" {
        chainloader /efi/$os/grub.efi
}

menuentry 'CaaSP Node Installation' {
  linuxefi /boot/x86_64/loader/linux splash=silent netsetup=dhcp install=http://router.caasp.suse.ru/repo/SUSE/Install/x86/SLE-SERVER/15-SP1/ autoyast=http://router.caasp.suse.ru/autoyast/autoinst_caasp.xml
  initrdefi /boot/x86_64/loader/initrd
}

EOF