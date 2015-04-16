FROM ubuntu:14.04

ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
ENV INITRD no
ENV SONAR_VERSION 5.1

RUN echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup && \
sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list && \
sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list && \
echo 'deb http://archive.ubuntu.com/ubuntu/ trusty multiverse' >> /etc/apt/sources.list && \
apt-get update -qq && \
apt-get -yqq upgrade && \
apt-get dist-upgrade -y --no-install-recommends && \
dpkg-divert --local --rename --add /sbin/initctl && \
dpkg-divert --local --rename --add /usr/bin/ischroot && \
ln -sf /bin/true /sbin/initctl && \
ln -sf /bin/true /usr/bin/ischroot && \
apt-get install -y --no-install-recommends software-properties-common vim unzip wget curl psmisc less language-pack-en openjdk-7-jdk && \
locale-gen en_US.UTF-8 uk_UA.UTF-8 && \
update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 && \
apt-get autoremove -y && \
apt-get clean && \
rm -rf /tmp/* /var/tmp/*

RUN cd /opt && curl -O --progress-bar http://dist.sonar.codehaus.org/sonarqube-$SONAR_VERSION.zip 2>&1 && \
unzip sonarqube-$SONAR_VERSION.zip && \
mv -v /opt/sonarqube-$SONAR_VERSION /opt/sonarqube && \
rm -vf /opt/sonarqube-$SONAR_VERSION.zip && \
sed -i 's|#wrapper.java.additional.6=-server|wrapper.java.additional.6=-server|g' /opt/sonarqube/conf/wrapper.conf && \
sed -i -e 's|#sonar.jdbc.password=sonar|sonar.jdbc.password=123qwe|g' -e 's|#sonar.jdbc.user=sonar|sonar.jdbc.user=sonar|g' -e 's|sonar.jdbc.url=jdbc:h2|#sonar.jdbc.url=jdbc:h2|g' -e 's|#sonar.jdbc.url=jdbc:mysql://localhost|sonar.jdbc.url=jdbc:mysql://${env:DB_PORT_3306_TCP_ADDR}|g' /opt/sonarqube/conf/sonar.properties

EXPOSE 9000

CMD ["/opt/sonarqube/bin/linux-x86-64/sonar.sh", "console"]
