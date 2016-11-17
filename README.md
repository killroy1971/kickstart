#Kickstart Scripts

This repository contains sample kickstart scripts.

##Kickstart Files
* ks.centos7.stig-40GB - Creates a bare metal RHEL/CENTOS 7 machine with all DISA STIG volumes
  in a 50 GB logical volume.  You'll need 500 MB of space for /boot.
* ks.centos7.stig-12GB - Creates a bare metal RHEL/CENTOS 7 with all DISA STIG volumes 
  in a 12 GB locial volume.  You'll need 500 MB of space for /boot.
* libvirt.centos7 - Creates a libvirt KVM CENTOS 7 VM
* vagrant.centos6 - Creates a CENTOS 6 vagrant box target (works with Virtual Box and Packer)
* vagrant.centos7 - Creates a CENTOS 7 vagrant box target (works with Virtual Box and Packer)
* ks.fedora24-svr - Creates a generic Fedora Server machine with nfs-utils, screen, zsh, 
  ksh, vim, and chrony
* puppet-centos6.ks - Creates a basic CentOS 6 Puppet client server.


---
DISA STIG requries the following volumes:
* / - root
* /var
* /var/log
* /var/log/audit
* /usr
* /home
* /tmp
* /opt

The '/tmp' folder should be mounted as "noexec."
