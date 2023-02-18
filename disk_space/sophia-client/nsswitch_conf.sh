
NSSWITCH=$(cat /etc/nsswitch.conf |egrep '^passwd|^shadow|^group'|grep sss|wc -l)

if [ $NSSWITCH == 3 ]; then
	echo "$HOSTNAME is Sophia greenfield"
else
	echo "$HOSTNAME is /etc/nsswitch.conf is not correct as per Sophia greenfield"
fi
