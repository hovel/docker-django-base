FROM centos:7
MAINTAINER Sergey Fursov <geyser85@gmail.com>

# Upgrade system
# RUN yum -y upgrade

# Activate EPEL (at least for supervisor)
RUN yum -y install epel-release
# Install some common software packages
RUN yum -y install gcc postfix openssh-server pwgen \
           git mercurial \
		   python-devel python-pip mysql-devel libxslt-devel \
		   curl wget vim mailcap \
           libtiff-devel libjpeg-devel libzip-devel freetype-devel lcms2-devel libwebp-devel tcl-devel tk-devel

RUN pip install pip -U

RUN localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_ALL ru_RU.UTF-8

# Set up sshd
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key && \
    sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config

# Add public source control services to known_hosts
RUN mkdir /root/.ssh
RUN chmod 600 /root/.ssh
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Install common python packages
ADD base_requirements.txt /root/base_requirements.txt
RUN pip install -r /root/base_requirements.txt -U

EXPOSE 22

RUN mkdir -p /etc/supervisor/conf.d /root/logs/gunicorn /root/logs/django /root/logs/nginx
ADD supervisor.conf /etc/supervisor/supervisor.conf

EXPOSE 80

# Add run scripts
ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
ADD prod.sh /prod.sh
ADD dev.sh /dev.sh
ADD empty.sh /empty.sh
RUN chmod +x /*.sh

# default home dir
ENV HOME /root

CMD ["./run.sh"]
