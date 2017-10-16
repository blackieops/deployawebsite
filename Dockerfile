FROM centos:7

RUN yum makecache fast && \
    yum install -y epel-release && \
    yum install -y awscli && \
    yum clean all && rm -fr /var/cache/yum

RUN mkdir /usr/local/hugo/ && \
    curl -L https://github.com/gohugoio/hugo/releases/download/v0.29/hugo_0.29_Linux-64bit.tar.gz | tar -xvzC /usr/local/hugo/
