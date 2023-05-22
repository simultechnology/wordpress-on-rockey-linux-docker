# Use Rocker Linux as the base image
FROM rockylinux:9

# Install required dependencies
RUN dnf update -y && dnf install -y \
    httpd \
    mariadb \
    php \
    php-mysqlnd \
    php-gd \
    php-xml \
    && dnf clean all

# Enable Apache modules
RUN sed -i 's/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/' /etc/httpd/conf.modules.d/00-base.conf
RUN sed -i 's/#LoadModule\ mysqli_module/LoadModule\ mysqli_module/' /etc/httpd/conf.modules.d/00-mysql.conf

# Download and extract WordPress
RUN chown -R apache:apache /var/www/html/ && \
    chmod -R 755 /var/www/html/

# Configure PHP
RUN sed -i 's/;date.timezone\ =/date.timezone\ =\ UTC/' /etc/php.ini

# Expose port 80 for web traffic
EXPOSE 80

# Start Apache server
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

