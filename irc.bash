#!/bin/bash

# mostly stolen from
# http://andy.delcambre.com/2008/12/06/growl-notifications-with-irssi.html

usernamehostname="~/.irc_notify_username_hostname"
if [ -e usernamehostname ]; then
  read username hostname < usernamehostname
else
  read -p "what's your remote username? " username
  read -p "what's your remote hostname? " hostname
  echo "${username} ${hostname}" > usernamehostname
fi

(ssh ${username}@${hostname} -o PermitLocalCommand=no \
  ": > .irssi/fnotify; tail -f .irssi/fnotify 2> /dev/null" | \
  while read heading message; do
    notify-send "${heading}" "${message}";
  done
)&

ssh -t ${username}@${hostname} 'screen -xR'

# Kill all current fnotify
ps axu| awk '{if($0 ~ /fnotify/ && $0 ~ /irssi/ && $0 !~ /awk/) print $2}' | \
while read id; do
  kill $id
done
