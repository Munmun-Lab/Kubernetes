# Linux Commands Master Reference Script

```bash
#!/bin/bash

# ============================================================
# Linux Commands Master Reference
# Topic-wise Linux Commands Cheat Sheet
# ============================================================


# ============================================================
# 1. SYSTEM INFORMATION COMMANDS
# ============================================================

uname -a                 # Kernel + OS information
hostname                 # Show hostname
hostnamectl              # Detailed hostname information
uptime                   # System uptime
whoami                   # Current logged-in user
id                       # User UID/GID information
arch                     # CPU architecture
lscpu                    # CPU details
free -h                  # Memory usage
lsblk                    # Block devices
fdisk -l                 # Disk partition details
blkid                    # UUID filesystem information
cat /etc/os-release      # Linux distribution details


# ============================================================
# 2. DATE & TIME COMMANDS
# ============================================================

date                      # Current date/time
cal                       # Calendar
timedatectl               # Time configuration
hwclock                   # Hardware clock


# ============================================================
# 3. FILE & DIRECTORY COMMANDS
# ============================================================

pwd                       # Present working directory
ls                        # List files
ls -l                     # Long listing
ls -la                    # Hidden files
cd /path                  # Change directory
mkdir dir1                # Create directory
mkdir -p a/b/c            # Create nested directories
rmdir dir1                # Remove empty directory
rm -rf dir1               # Remove directory forcefully
touch file.txt            # Create file
cp file1 file2            # Copy file
cp -r dir1 dir2           # Copy directory
mv old new                # Rename/move file
find / -name test.txt     # Search file
locate file.txt           # Quick file search
updatedb                  # Update locate DB
stat file.txt             # File metadata
file file.txt             # File type
basename /tmp/a.txt       # File name only
dirname /tmp/a.txt        # Directory name only


# ============================================================
# 4. FILE VIEWING COMMANDS
# ============================================================

cat file.txt              # Display file
less file.txt             # View large file
more file.txt             # File pager
head -10 file.txt         # First 10 lines
tail -10 file.txt         # Last 10 lines
tail -f /var/log/messages # Live logs
nl file.txt               # Numbered lines
wc -l file.txt            # Count lines
sort file.txt             # Sort content
uniq file.txt             # Unique lines
cut -d: -f1 /etc/passwd   # Extract column
awk '{print $1}' file.txt # Print first column
sed 's/old/new/g' file    # Replace text
tr a-z A-Z                # Convert lowercase to uppercase


# ============================================================
# 5. USER MANAGEMENT COMMANDS
# ============================================================

useradd user1             # Create user
passwd user1              # Set password
usermod -aG wheel user1   # Add user to group
userdel user1             # Delete user
groupadd devops           # Create group
groupdel devops           # Delete group
id user1                  # User info
who                       # Logged-in users
w                         # Active users + process
last                      # Login history
su - user1                # Switch user
sudo su -                 # Switch root
chage -l user1            # Password aging


# ============================================================
# 6. PERMISSION COMMANDS
# ============================================================

chmod 755 file.sh         # Change permission
chmod +x file.sh          # Make executable
chown user:group file     # Change ownership
chgrp devops file         # Change group
umask                     # Default permission mask
getfacl file.txt          # ACL permissions
setfacl -m u:user:rwx f   # Set ACL


# ============================================================
# 7. PROCESS MANAGEMENT COMMANDS
# ============================================================

ps -ef                    # Process list
top                       # Live processes
htop                      # Interactive monitoring
pgrep nginx               # Process ID search
pidof sshd                # Get process ID
kill -9 PID               # Kill process
pkill nginx               # Kill by name
nice -n 10 command        # Set priority
renice 5 PID              # Change priority
jobs                      # Background jobs
bg                        # Run background
fg                        # Bring foreground
nohup command &           # Run persistent process


# ============================================================
# 8. SERVICE MANAGEMENT COMMANDS
# ============================================================

systemctl status nginx       # Service status
systemctl start nginx        # Start service
systemctl stop nginx         # Stop service
systemctl restart nginx      # Restart service
systemctl reload nginx       # Reload config
systemctl enable nginx       # Enable at boot
systemctl disable nginx      # Disable at boot
systemctl daemon-reload      # Reload systemd
journalctl -xe               # System logs
journalctl -u nginx          # Service logs


# ============================================================
# 9. NETWORK COMMANDS
# ============================================================

ip a                         # Network interfaces
ip route                     # Routing table
ping google.com              # Connectivity test
traceroute google.com        # Route path
ss -tulnp                    # Listening ports
netstat -tulnp               # Network statistics
curl https://example.com     # HTTP request
wget https://example.com     # Download file
nslookup google.com          # DNS lookup
dig google.com               # DNS query
host google.com              # DNS resolution
hostname -I                  # IP address
arp -a                       # ARP cache
scp file user@host:/tmp      # Secure copy
rsync -av src/ dst/          # Synchronization
ssh user@server              # SSH login


# ============================================================
# 10. PACKAGE MANAGEMENT COMMANDS
# ============================================================

# Ubuntu/Debian
apt update                   # Update repo
apt upgrade                  # Upgrade packages
apt install nginx            # Install package
apt remove nginx             # Remove package
apt purge nginx              # Remove config
apt search nginx             # Search package
apt list --installed         # Installed packages

# RHEL/CentOS
yum install httpd            # Install package
yum update                   # Update packages
yum remove httpd             # Remove package
rpm -qa                      # Installed RPMs
rpm -ivh pkg.rpm             # Install RPM


# ============================================================
# 11. DISK & STORAGE COMMANDS
# ============================================================

df -h                        # Disk usage
du -sh /var                  # Directory size
mount                        # Mounted filesystems
umount /mnt                  # Unmount filesystem
mkfs.ext4 /dev/sdb1          # Create filesystem
fsck /dev/sdb1               # Filesystem check
parted -l                    # Partition info
pvcreate /dev/sdb            # LVM physical volume
vgcreate vgdata /dev/sdb     # LVM volume group
lvcreate -L 10G -n lv1 vgdata # Logical volume


# ============================================================
# 12. MEMORY & CPU COMMANDS
# ============================================================

vmstat                       # Memory statistics
iostat                       # CPU + IO stats
sar                          # System activity
mpstat                       # CPU statistics
free -m                      # Memory usage
uptime                       # Load average
lscpu                        # CPU details


# ============================================================
# 13. LOG MANAGEMENT COMMANDS
# ============================================================

journalctl                   # Systemd logs
dmesg                        # Kernel logs
less /var/log/messages       # System logs
less /var/log/secure         # Authentication logs
logrotate                    # Log rotation


# ============================================================
# 14. ARCHIVE & COMPRESSION COMMANDS
# ============================================================

tar -cvf backup.tar dir      # Create tar
tar -xvf backup.tar          # Extract tar
gzip file.txt                # Compress file
gunzip file.txt.gz           # Uncompress
zip backup.zip file.txt      # ZIP archive
unzip backup.zip             # Extract ZIP


# ============================================================
# 15. SCHEDULING COMMANDS
# ============================================================

crontab -e                   # Edit cron
crontab -l                   # List cron jobs
at now + 5 minutes           # One-time job
systemctl list-timers        # Systemd timers


# ============================================================
# 16. SECURITY COMMANDS
# ============================================================

sudo visudo                  # Edit sudoers
getenforce                   # SELinux mode
setenforce 0                 # Disable SELinux temporarily
ufw status                   # Firewall status
firewall-cmd --list-all      # Firewalld rules
passwd -l user1              # Lock user
passwd -u user1              # Unlock user


# ============================================================
# 17. ENVIRONMENT VARIABLES
# ============================================================

env                           # Show env vars
export VAR=value              # Set variable
echo $PATH                    # PATH variable
printenv                      # Environment values
source ~/.bashrc              # Reload shell


# ============================================================
# 18. BASH SCRIPTING COMMANDS
# ============================================================

#!/bin/bash

VAR="Hello"

echo $VAR

if [ -f file.txt ]; then
  echo "File exists"
fi

for i in 1 2 3
 do
   echo $i
 done

while true
 do
   break
 done


# ============================================================
# 19. SYSTEM MONITORING COMMANDS
# ============================================================

top                           # Process monitor
htop                          # Interactive monitor
vmstat 1                      # Memory live stats
iostat 1                      # IO live stats
sar -u 1 5                    # CPU monitoring
watch df -h                   # Continuous monitoring


# ============================================================
# 20. CONTAINER COMMANDS
# ============================================================

# Docker

docker ps                     # Running containers
docker images                 # Docker images
docker pull nginx             # Pull image
docker run nginx              # Run container
docker exec -it ID bash       # Access container
docker logs ID                # Container logs
docker rm ID                  # Remove container


# ============================================================
# 21. KUBERNETES COMMANDS
# ============================================================

kubectl get pods              # List pods
kubectl get nodes             # List nodes
kubectl get svc               # Services
kubectl describe pod pod1     # Pod details
kubectl logs pod1             # Pod logs
kubectl exec -it pod1 bash    # Access pod
kubectl apply -f app.yaml     # Deploy resource
kubectl delete -f app.yaml    # Delete resource
kubectl top nodes             # Node metrics
kubectl top pods              # Pod metrics


# ============================================================
# 22. GIT COMMANDS
# ============================================================

git init                      # Initialize repo
git clone URL                 # Clone repo
git status                    # Git status
git add .                     # Stage files
git commit -m "msg"           # Commit
git push origin main          # Push code
git pull                      # Pull latest
git branch                    # List branches
git checkout branch           # Switch branch


# ============================================================
# 23. TROUBLESHOOTING COMMANDS
# ============================================================

history                       # Command history
which kubectl                 # Binary location
whereis docker                # File locations
strace command                # System call trace
lsof -i :80                   # Port usage
tcpdump -i eth0               # Packet capture
nc -zv host 80                # Port test


# ============================================================
# 24. REBOOT & SHUTDOWN COMMANDS
# ============================================================

reboot                        # Restart server
shutdown -h now               # Shutdown now
shutdown -r now               # Reboot now
poweroff                      # Power off
init 6                        # Reboot
init 0                        # Shutdown


# ============================================================
# END OF LINUX MASTER COMMAND REFERENCE
# ============================================================

```
