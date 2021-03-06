#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use network installation
url --url="http://192.168.4.10/os/rhel7"
repo --name="Server-HighAvailability" --baseurl=http://192.168.4.10/os/rhel7/addons/HighAvailability
repo --name="Server-ResilientStorage" --baseurl=http://192.168.4.10/os/rhel7/addons/ResilientStorage
# Use graphical install
graphical

url --url http://192.168.4.14/pub/os/rhel7.4/
# Use text install
text

# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=eth0 --ipv6=ignore --activate
network  --hostname=opcmasterbase.gshome.lan

# Root password
rootpw --iscrypted $6$mrnfsiubvMDMK8CV$CyouEe9J.wdAErICvJxDsWx1xWgTM0IPUf5/Gd1f6JVoiePVs0hMG9IJ7xjdyALoe50sLzbQB6am6vJVpSYoZ0

# System services
services --enabled="chronyd"

# System timezone
timezone America/New_York --isUtc

user --groups=wheel --name=glenn --password=$6$7kZGDpNzm6C50Qz0$uZUkbcqxtzJMCRMP1Lx8hTljQ.3rQwfpIT1trEkOlIG7HWT57YBgLzUTc61RMm1b71Dc5IMyI7K2IEM1rkGEr1 --iscrypted --gecos="Glenn H. Snead"

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
autopart --type=lvm

# Partition clearing information
clearpart --none --initlabel

# Create my user account
user --groups=wheel --name=glenn --password=6$iI/lDzy6$d94xzZfc4o9Wh0J0N37ZWnsfdAEv.tmTNDYMGPI9ZbPJst65ObRQWojfAbk1qajnd5WZGAJD9WRXhBZVuiNcU/ --iscrypted --gecos="Glenn H. Snead"

# Partition clearing information
clearpart --all --initlabel

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda

# Disk partitioning information
part /boot --fstype="xfs" --ondisk=sda --size=500
part pv.20 --fstype="lvmpv" --ondisk=sda --size=4096 --grow
volgroup vg01 pv.20
logvol /  --fstype="xfs" --size=1024 --name=root --vgname=vg01
logvol /usr  --fstype="xfs" --size=10240 --name=usr --vgname=vg01
logvol /opt  --fstype="xfs" --size=5120  --name=opt --vgname=vg01
logvol /var  --fstype="xfs" --size=25600 --name=var --vgname=vg01
logvol /var/log  --fstype="xfs" --size=10240 --name=var_log --vgname=vg01
logvol /home  --fstype="xfs" --size=2048 --name=home --vgname=vg01
logvol /tmp  --fstype="xfs" --size=5120  --name=tmp --vgname=vg01 --fsoptions=defaults,noexec
logvol swap  --fstype="swap" --size=8192 --name=swap --vgname=vg01

%packages
@^minimal
@core
aide
chrony
curl
mailx
wget
libselinux-python
libsemanage-python
vim
bash-completion
zsh
openscap
openscap-utils
openscap-scanner

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

#Set up sudoers - remove the NOPASSWD wheel group entry, allow password-based wheel group privilege escalation
sed -i -e '/## Same thing without a password/d' /etc/sudoers
sed -i -e '/#.*%wheel.*ALL=(ALL).*NOPASSWD:.*ALL/d' /etc/sudoers
sed -i -e 's/#.*%wheel.*ALL=(ALL).*ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

# Copy ssh public key to root's authorized_keys file
mkdir /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsbzaZtMVw978GopC7eZNavtDnisNYkZGj/69GEZdvM8Cm0DHbvujmoOaul321rBj15F9tIKnNJ/1fA537j1yHTPEN5j/PyryzkCnAW146A6xQpr46KQkoW/tw1C17t+RGdGoxOOWD2dlqx1hXWkj8tJiXcp481tbOY25/9eumQUHR5BRC9IHx7FgVy7kWm2UYqu3wQH1VSBF43+2tg63rIKMFpUw9J4Foc3CWn6aDK6RZ67C4XS1MQ+j51NHChox36uQetSSAfxDuFWLN/IjWzo54K4J06wLNUolzDrWVYSJ5dBLnmhODrF+Cvn57S0DC92A5wS/zhTpamSjQAnMF00oNTtSejz6+LFmhDKX1CKxKSEzobNszmcwMAaaSTSWOVXrVXNsq6AgRHxTOs64pX/05HhqKk3ePBk/If0vx16YtL4DJXL+gvDHBWsoBaAY8Y3FasXQ9hEzTDwtWj9SD4lZmE5OlWdwqkzkLxUQCSlK4L7LhvltvRGXVRcn8LN4sbdJKHxqsAAP7zL9fuyHAYdhSCEazo6uRZBC4ZjUpif8AZVE3QNjT3JvaOadg5ZHuzsGK/0NpNP23M39T33LKL4kVvOxw9L0cyKn1MlKN7cwRMfttGffQNttui4LQmv0fO5FXPc9q7l4oDfeCMNSiu37S1EpAEV0Soqtzj/AKvw== glenn@ansible" > /root/.ssh/authorized_keys
chmod 0700 /root/.ssh
chmod 0600 /root/.ssh/authorized_keys

# Copy ssh public key to glenn's authorized_keys file
mkdir /home/glenn/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsbzaZtMVw978GopC7eZNavtDnisNYkZGj/69GEZdvM8Cm0DHbvujmoOaul321rBj15F9tIKnNJ/1fA537j1yHTPEN5j/PyryzkCnAW146A6xQpr46KQkoW/tw1C17t+RGdGoxOOWD2dlqx1hXWkj8tJiXcp481tbOY25/9eumQUHR5BRC9IHx7FgVy7kWm2UYqu3wQH1VSBF43+2tg63rIKMFpUw9J4Foc3CWn6aDK6RZ67C4XS1MQ+j51NHChox36uQetSSAfxDuFWLN/IjWzo54K4J06wLNUolzDrWVYSJ5dBLnmhODrF+Cvn57S0DC92A5wS/zhTpamSjQAnMF00oNTtSejz6+LFmhDKX1CKxKSEzobNszmcwMAaaSTSWOVXrVXNsq6AgRHxTOs64pX/05HhqKk3ePBk/If0vx16YtL4DJXL+gvDHBWsoBaAY8Y3FasXQ9hEzTDwtWj9SD4lZmE5OlWdwqkzkLxUQCSlK4L7LhvltvRGXVRcn8LN4sbdJKHxqsAAP7zL9fuyHAYdhSCEazo6uRZBC4ZjUpif8AZVE3QNjT3JvaOadg5ZHuzsGK/0NpNP23M39T33LKL4kVvOxw9L0cyKn1MlKN7cwRMfttGffQNttui4LQmv0fO5FXPc9q7l4oDfeCMNSiu37S1EpAEV0Soqtzj/AKvw== glenn@ansible" > /home/glenn/.ssh/authorized_keys
chmod 0700 /home/glenn/.ssh
chown glenn:glenn /home/glenn/.ssh
chmod 0600 /home/glenn/.ssh/authorized_keys
chown glenn:glenn /home/glenn/.ssh/authorized_keys

%end

%anaconda
pwpolicy root --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=50 --notstrict --nochanges --notempty
%end

