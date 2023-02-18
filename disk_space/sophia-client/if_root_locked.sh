ROOT=$(sudo passwd --status root |grep LK |wc -l)

if [ $ROOT == 1 ];then
	echo "your root account is locked"
else
	echo "root account is not lcoeked"
fi
