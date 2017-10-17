FROM centos:7

RUN yum makecache fast && \
	yum install -y ruby-devel make gcc git && \
	yum install -y https://repo.blackieops.com/centos/7/ruby-2.4.1-1.el7.centos.x86_64.rpm && \
	yum clean all && rm -fr /var/cache/yum

RUN gem install bundler --no-ri --no-rdoc

RUN git clone https://github.com/nuex/zodiac.git /tmp/zodiac && \
	cd /tmp/zodiac && make install && rm -fr /tmp/zodiac
