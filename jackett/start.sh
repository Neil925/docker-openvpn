#!/bin/bash
if [[ ! -e /config/Jackett ]]; then
	mkdir -p /config/Jackett/config/
	chown -R ${PUID}:${PGID} /config/Jackett
else
	chown -R ${PUID}:${PGID} /config/Jackett
fi

## Check for missing group
/bin/egrep  -i "^${PGID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "Group $PGID exists"
else
   echo "Adding $PGID group"
	 groupadd -g $PGID jackett
fi

## Check for missing userid
/bin/egrep  -i "^${PUID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "User $PUID exists in /etc/passwd"
else
   echo "Adding $PUID user"
	 useradd -c "jackett user" -g $PGID -u $PUID jackett
fi

# set umask
export UMASK=$(echo "${UMASK}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

if [[ ! -z "${UMASK}" ]]; then
  echo "[info] UMASK defined as '${UMASK}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] UMASK not defined (via -e UMASK), defaulting to '002'" | ts '%Y-%m-%d %H:%M:%.S'
  export UMASK="002"
fi


echo "[info] Starting Jackett daemon..." | ts '%Y-%m-%d %H:%M:%.S'
/bin/bash /etc/jackett/jackett.init start &
chmod -R 755 /config/Jackett

sleep 1
qbpid=$(pgrep -o -x jackett)
echo "[info] Jackett PID: $qbpid" | ts '%Y-%m-%d %H:%M:%.S'

if [ -e /proc/$qbpid ]; then
	if [[ -e /config/Jackett/data/logs/jackett.log ]]; then
		chmod 775 /config/Jackett/data/logs/jackett.log
	fi
	sleep infinity
else
	echo "Jackett failed to start!"
fi
