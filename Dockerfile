# Use Rocker Linux as the base image
FROM rockylinux:9

# Install required dependencies
RUN dnf update -y && dnf install -y \
    gcc \
    vim \
    make \
    tar \
    unzip \
    procps \
    httpd \
    php \
    php-mysqlnd \
    php-gd \
    php-curl \
    php-zip \
    php-mbstring \
    php-xml \
    php-cli \
    php-pdo \
    php-fpm \
    php-pear \
    php-devel \
    && dnf clean all

RUN pecl install xdebug

# Enable Apache modules
RUN sed -i 's/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/' /etc/httpd/conf.modules.d/00-base.conf
RUN sed -i 's/#LoadModule\ proxy_module/LoadModule\ proxy_module/' /etc/httpd/conf.modules.d/00-proxy.conf
RUN sed -i 's/#LoadModule\ proxy_fcgi_module/LoadModule\ proxy_fcgi_module/' /etc/httpd/conf.modules.d/00-proxy.conf

# Download and extract WordPress
RUN chown -R apache:apache /var/www/html/ && \
    chmod -R 755 /var/www/html/

# Configure PHP-FPM
RUN sed -i 's/;date.timezone\ =/date.timezone\ =\ JST/' /etc/php.ini

# Create directory for PHP-FPM socket
RUN mkdir -p /run/php-fpm && \
    chown apache:apache /run/php-fpm && \
    chmod 755 /run/php-fpm

# Configure Apache
RUN echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf

# Configure Apache to process PHP files
RUN echo -e "<FilesMatch \.php$>\n\tSetHandler application/x-httpd-php\n\tSetHandler proxy:unix:/run/php-fpm/www.sock|fcgi://localhost/\n</FilesMatch>" > /etc/httpd/conf.d/php.conf

RUN systemctl enable httpd \
    && systemctl enable php-fpm

# Expose port 80 for web traffic
EXPOSE 80

CMD ["sh", "-c", "php-fpm -D && httpd -DFOREGROUND"]
