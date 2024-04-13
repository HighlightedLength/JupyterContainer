#!/bin/sh

# allow for ssh
ssh-keygen -A
exec /usr/sbin/sshd -D -e "$@" &

# run jupyter
cd note
ip=$(ifconfig eth0 | grep -Eo "inet addr:\d+\.\d+\.\d+\.\d+" | grep -Eo "\d+\.\d+\.\d+\.\d+")
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root &


# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?