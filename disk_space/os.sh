#!/bin/bash

#------variables used------#
S="************************************"
D="-------------------------------------"

ALERT=5 # disk alert level
MOUNT=$(mount|egrep -iw "ext4|ext3|xfs|gfs|gfs2|btrfs"|grep -v  "loop|tmpfs|cgroup|sysfs|swap"|sort -u -t' ' -k1,2)

echo -e "$S"
echo -e "\tSystem Health Status"
echo -e "$S"

#--------Print Operating System Details--------#
hostname -f &> /dev/null && printf "Hostname : $(hostname -f)" || printf "Hostname : $(hostname -s)"

echo -en "\nOperating System : "
[ -f /etc/os-release ] && echo $(egrep -w "NAME|VERSION" /etc/os-release|awk -F= '{ print $2 }'|sed 's/"//g') || cat /etc/system-release

echo -e "Kernel Version :" $(uname -r)
printf "OS Architecture :"$(arch | grep x86_64 &> /dev/null) && printf " 64 Bit OS\n"  || printf " 32 Bit OS\n"

#--------Print system uptime-------#
UPTIME=$(uptime)
echo -en "System Uptime : "
echo $UPTIME|grep day &> /dev/null
if [ $? != 0 ]; then
  echo $UPTIME|grep -w min &> /dev/null && echo -en "$(echo $UPTIME|awk '{print $2" by "$3}'|sed -e 's/,.*//g') minutes" \
 || echo -en "$(echo $UPTIME|awk '{print $2" by "$3" "$4}'|sed -e 's/,.*//g') hours"
else
  echo -en $(echo $UPTIME|awk '{print $2" by "$3" "$4" "$5" hours"}'|sed -e 's/,//g')
fi
echo -e "\nCurrent System Date & Time : "$(date +%c)

#--------Check for any read-only file systems--------#
echo -e "\nChecking For Read-only File System[s]"
echo -e "$D"
echo "$MOUNT"|grep -w ro && echo -e "\n.....Read Only file system[s] found"|| echo -e ".....No read-only file system[s] found. "

#--------Check disk usage on all mounted file systems--------#
#Monitor Linux disk space
echo -e "$D"
echo "Checking is any of the File system is in running out"
df -H | grep -vE '^Filesystem|tmpfs|cdrom|loop*' | awk '{ print $2" " $6 " " $5 }' | while read -r output;
do
  #echo "$output"
  usep=$(echo "$output" | awk '{ print $3}' | cut -d'%' -f1 )
  partition=$(echo "$output" | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    echo "Running out of space \"$partition ($usep%)\" "
    #echo " All File system are under threshhold value"
  fi
done

#--------Check for SWAP Utilization--------#
echo -e "\n\nChecking SWAP Details"
echo -e "$D"
echo -e "Total Swap Memory in MiB : "$(grep -w SwapTotal /proc/meminfo|awk '{print $2/1024}')", in GiB : "\
$(grep -w SwapTotal /proc/meminfo|awk '{print $2/1024/1024}')
echo -e "Swap Free Memory in MiB : "$(grep -w SwapFree /proc/meminfo|awk '{print $2/1024}')", in GiB : "\
$(grep -w SwapFree /proc/meminfo|awk '{print $2/1024/1024}')

#--------Check for Processor Utilization (current data)--------#
echo -e "$D"
echo -e "\nCurrent Processor Utilization Summary :\n"
echo -e "$D"
mpstat|tail -2

#--------Check for load average (current data)--------#
echo -e "\n\nChecking For Load Average"
echo -e "$D"
echo -e "Current Load Average : $(uptime|grep -o "load average.*"|awk '{print $3" " $4" " $5}')"

#--------Print top 5 Memory & CPU consumed process threads---------#
#--------excludes current running program which is hwlist----------#
echo -e "\n\nTop 5 Memory Resource Hog Processes"
echo -e "$D$D"
ps -eo pmem,pid,ppid,user,stat,args --sort=-pmem|grep -v $$|head -3|sed 's/$/\n/'

echo -e "\nTop 5 CPU Resource Hog Processes"
echo -e "$D$D"
ps -eo pcpu,pid,ppid,user,stat,args --sort=-pcpu|grep -v $$|head -3|sed 's/$/\n/'
