grep "swapaccount=1" /etc/default/grub || sudo sed -i -r 's|^(GRUB_CMDLINE_LINUX_DEFAULT=)\"(.*.)\"|\1\"\2 swapaccount=1 \"|' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo systemctl reboot
