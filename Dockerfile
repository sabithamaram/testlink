FROM ubuntu:latest
MAINTAINER "siddula.kumar@quest-global.com"

RUN apt-get update && apt-get install -y \
    curl apt-utils apt-transport-https debconf-utils gcc build-essential g++-5\
    && rm -rf /var/lib/apt/lists/*

# adding custom MS repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install SQL Server drivers
RUN apt-get update -y
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql17
RUN ACCEPT_EULA=Y apt-get install mssql-tools

# For unixODBC development headers 
RUN apt-get install unixodbc-dev -yqq 
RUN apt-get install software-properties-common -y

RUN add-apt-repository ppa:ondrej/php
RUN apt-get update -yqq && apt-get -y upgrade && DEBIAN_FRONTEND=nointeractive apt-get -y install apache2 php7.2 php7.2-common php7.2-sybase php-pear wget php7.2-curl php7.2-dev apt-transport-https
RUN apt-get install php7.2-mysql
#RUN perl install --nodeps MDB2_Driver_mssql

#RUN ACCEPT_EULA=Y apt-get -y install php7.2-php-pdo php7.2-php-sqlsrv

RUN pecl install sqlsrv
#RUN docker-php-ext-enable sqlsrv 
RUN pecl install pdo_sqlsrv
#RUN docker-php-ext-enable pdo_sqlsrv

RUN wget -q http://sourceforge.net/projects/testlink/files/TestLink%201.9/TestLink%201.9.18/testlink-1.9.18.tar.gz/download -O testlink-1.9.18.tar.gz &&\
    tar zxvf testlink-1.9.18.tar.gz && \
    mv testlink-1.9.18 /var/www/html/testlink && \
    rm testlink-1.9.18.tar.gz

RUN echo "max_execution_time=3000" >> /etc/php/7.2/apache2/php.ini && \
    echo "session.gc_maxlifetime=60000" >> /etc/php/7.2/apache2/php.ini
RUN echo "extension=/usr/lib/php/20151012/sqlsrv.so" >> /etc/php/7.2/cli/php.ini
RUN echo "extension=/usr/lib/php/20151012/pdo_sqlsrv.so" >> /etc/php/7.2/cli/php.ini

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR
RUN mkdir -p /var/testlink/logs /var/testlink/upload_area

RUN chmod 777 -R /var/www/html/testlink && \
    chmod 777 -R /var/testlink/logs && \
    chmod 777 -R /var/testlink/upload_area

EXPOSE 80/tcp

CMD ["/usr/sbin/apache2","-D", "FOREGROUND"]
