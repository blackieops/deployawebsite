FROM centos:7

ENV LANG en_US.utf8
ENV LANGUAGE en_US.utf8
ENV LC_ALL en_US.utf8

# Set HOME so bundler shuts up
ENV HOME /tmp

RUN yum makecache fast && \
	yum install -y epel-release && \
	yum install -y make gcc git awscli && \
	yum install -y https://repo.blackieops.com/centos/7/ruby-2.4.1-1.el7.centos.x86_64.rpm && \
	yum clean all && rm -fr /var/cache/yum

RUN gem install bundler --no-ri --no-rdoc

RUN git clone https://github.com/nuex/zodiac.git /tmp/zodiac && \
	cd /tmp/zodiac && make install && rm -fr /tmp/zodiac

# Jenkins sets the UID but some things breaks if the user isn't present in passwd
RUN useradd -u995 jenkins

