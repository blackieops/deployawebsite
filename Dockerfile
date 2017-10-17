FROM centos:7

RUN yum makecache fast && \
	yum install -y ruby rubygem-bundler make gcc git && \
	yum clean all && rm -fr /var/cache/yum

RUN git clone https://github.com/nuex/zodiac.git /tmp/zodiac && \
	cd /tmp/zodiac && make install && rm -fr /tmp/zodiac
