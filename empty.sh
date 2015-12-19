#!/bin/bash
if [ ! -f /.root_pw_set ]; then
    /set_root_pw.sh
fi

/usr/sbin/sshd
set > /envars
sleep infinity
