#!/bin/bash
postfix start
supervisord -c /etc/supervisor/supervisor.conf
