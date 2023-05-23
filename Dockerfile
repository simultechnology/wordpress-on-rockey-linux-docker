# Use Rocker Linux as the base image
FROM rockylinux:9

# Install required dependencies
RUN dnf update -y && dnf install -y \
    systemd \
    gcc \
    make \
    tar \
    unzip \
    sudo \
    procps \
    httpd \
    php \
    php-mysqlnd \
    php-gd \
    php-xml \
    php-cli \
    php-pdo \
    php-fpm \
    php-pear \
    php-devel \
    && dnf clean all

RUN pecl install xdebug

RUN systemctl enable httpd \
    && systemctl enable httpd php-fpm.service

# Enable Apache modules
RUN sed -i 's/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/' /etc/httpd/conf.modules.d/00-base.conf
# RUN sed -i 's/#LoadModule\ mysqli_module/LoadModule\ mysqli_module/' /etc/httpd/conf.modules.d/00-mysql.conf

# Download and extract WordPress
RUN chown -R apache:apache /var/www/html/ && \
    chmod -R 755 /var/www/html/

# Configure PHP
RUN sed -i 's/;date.timezone\ =/date.timezone\ =\ UTC/' /etc/php.ini

# Configure Apache to process PHP files
RUN echo -e "<FilesMatch \.php$>\n\tSetHandler application/x-httpd-php\n</FilesMatch>" > /etc/httpd/conf.d/php.conf


# Expose port 80 for web traffic
EXPOSE 80

# Start Apache server
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

