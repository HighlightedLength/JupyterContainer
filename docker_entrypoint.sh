#!/bin/sh

# allow for ssh
ssh-keygen -A
exec /usr/sbin/sshd -D -e "$@" &

# run jupyter
if ! test -d /root/notebook ; then
    echo '/root/notebook not found' > /tmp/log.txt
    mkdir /root/notebook
    echo 'CAUTION: The contents of this notebook are not *permanent*!' > /root/notebook/README.md
    echo 'You need to mount a host folder.' >> /root/notebook/README.md
    echo 'example: `docker run -p 127.0.0.1:8888:8888 -v .\notebook:/root/notebook jupyter-container:latest`' >> /root/notebook/README.md
else
    echo '/root/notebook found' > /tmp/log.txt
fi
cd /root/notebook
ip=$(ifconfig eth0 | grep -Eo "inet addr:\d+\.\d+\.\d+\.\d+" | grep -Eo "\d+\.\d+\.\d+\.\d+")
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root &


# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?