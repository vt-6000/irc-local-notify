#!/usr/bin/env bash

# mostly stolen from
# http://andy.delcambre.com/2008/12/06/growl-notifications-with-irssi.html

#configuration
usernamehostname="~/.irc_notify_username_hostname"
if [ -e $usernamehostname ]; then
  read username hostname < $usernamehostname
else
  read -p "what's your remote username? " username
  read -p "what's your remote hostname? " hostname
  echo "${username} ${hostname}" > $usernamehostname
fi

#start the notifier
(ssh ${username}@${hostname} -o PermitLocalCommand=no \
  ": > .irssi/fnotify; tail -f .irssi/fnotify 2> /dev/null" | \
  while read heading message; do
    notify-send "${heading}" "${message}";
  done
)&

#connect to remote screen with irssi in it
ssh -t ${username}@${hostname} 'screen -xR'

#Kill local notifier
# using square brackets in the regex prevents this process from killing itself
ps axu|awk '{if($0 ~ /[f]notify/ && $0 ~ /irssi/) print $2}' | \
while read id; do
  kill $id
done

echo "cleaning up remote notifier"
#kill remote notifier
# using square brackets in the regex prevents this process from killing itself
(ssh ${username}@${hostname} -o PermitLocalCommand=no \
  "ps axu|awk '{if(\$0 ~ /[f]notify/ && \$0 ~ /irssi/) print \$2}' | \\
  while read id; do
    kill \$id
  done")
