#version=RHEL7
# System authorization information
auth --enableshadow --passalgo=sha512

# Use CDROM installation media
cdrom

# Use graphical install
graphical

# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=vda

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=enp0s3 --ipv6=auto --activate
network  --hostname=host1.example.com

# Root password
rootpw --iscrypted $6$HAVEpMUe.LJdMf38$OGc82aGA/rOUNP0RSFiBAu4tuC.rX5jSsvQVD74jbWeAyBuenh3FHy1RBKChCZAaThsaV0i4OljVMWiny7/.Z0

# User account
user --groups=wheel --name=glenn --password=$6$W09Bf9vw4tieKyW4$a2CFH/0gHxJ49VKuU9AnyaO7AWMX.eOxSWlbUTFHDtCeAecrLcn4LAV3h8SuzgPZiTF5EmPaeZihSQxs/1AuT0 --iscrypted --gecos="Glenn H. Snead"

# System timezone
timezone America/New_York --isUtc
user --name=vagrant --gecos="vagrant"

# Partition clearing information
clearpart --all --initlabel 

# System bootloader configuration
# autopart --type=lvm
bootloader --location=mbr --boot-drive=vda
part /boot --fstype="xfs" --onpart=vda1
part pv.17 --fstype="lvmpv" --noformat --onpart=vda2
volgroup vg01 pv.17
logvol swap --fstype="swap" --name=swap --vgname=vg01
logvol / --fstype="xfs" --name=root --vgname=vg01

%packages
@core
rsync
net-tools
screen

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end
%post --nochroot
%end

%post
%end
