#!/bin/bash

# Script que comprueba la conexión 3g. Si está desconectado intenta conectarse y si lo consigue manda un mail con la nueva IP al correo especificado.
# Requiere tener instalado sakisd3g (configurado como servicio)  y exim.
# Además se recomienda poner en el cron con la periocidad deseada


IFACE=ppp0
DOWN="sudo /etc/init.d/sakis3g stop"
UP="sudo /etc/init.d/sakis3g start"
LOG=/var/log/comprueba3g.log
DEST="xxxxxxxxxx@gmail.com"
CORREO="OK"

if [ "$CORREO" = "OK" ]
then

	RECV=`ping -c 8 www.google.com 2>&1|grep received|cut -d , -f 2|cut -d " " -f 2`

	if [ "$RECV" = "" ] 
	then
	 	echo "La conexion 3g se ha caido. Reconectando..."
       		echo ----- >>$LOG
		date>>$LOG
		$DOWN >>$LOG 2>&1
		sleep 3 
		echo "mato posibles procesos zombie" 
		$UP >>$LOG 2>&1
		sleep 80 
		IPLOC=`sudo ifconfig $IFACE 2>&1|grep addr:|cut -d : -f 2|cut -d " " -f 1`
		echo "$IPLOC" 
		 
		if [ "$IPLOC" != "" ]
		then
			echo "$IPLOC" | /usr/bin/mail -s "El asunto que tu quieras xxxxxxxx" $DEST
			sudo exim -qff
		fi

	elif [ "$RECV" -le 5 ]
	then
		echo "La conexion 3g esta perdiendo demasiados paquetes. Reconectando..."
		date>>$LOG
		$DOWN >>$LOG 2>&1
		sleep 3
		echo "mato posibles procesos zombie"
		$UP >>$LOG 2>&1
		sleep 80 
		IPLOC=`sudo ifconfig $IFACE 2>&1|grep addr:|cut -d : -f 2|cut -d " " -f 1`
		echo "$IPLOC" 

		if [ "$IPLOC" != "" ]
		then
			echo "$IPLOC" | /usr/bin/mail -s "El asunto que tu quieras xxxxxxxx" $DEST
			sudo exim -qff	
		fi

	fi

fi
exit
