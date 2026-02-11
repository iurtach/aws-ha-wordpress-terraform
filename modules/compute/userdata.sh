#!/bin/bash
# 1. Update and install dependencies
dnf update -y
dnf install -y httpd php php-mysqlnd php-fpm php-gd php-json wget amazon-efs-utils jq

# 2. Start and enable services (PHP-FPM)
systemctl start httpd
systemctl enable httpd
systemctl start php-fpm
systemctl enable php-fpm

# 3. Mount EFS
mkdir -p /var/www/html
mount -t efs ${efs_id}:/ /var/www/html
# Add to fstab for persistence
echo "${efs_id}:/ /var/www/html efs defaults,_netdev 0 0" >> /etc/fstab

# 4. Install WordPress if not present
if [ ! -f /var/www/html/wp-config.php ]; then
    cd /tmp
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* /var/www/html/
    rm -rf wordpress latest.tar.gz
fi

# 5. Configure WordPress using Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "${secret_arn}" --region "${region}" --query SecretString --output text)
DB_USER=$(echo $SECRET_JSON | jq -r .username)
DB_PASS=$(echo $SECRET_JSON | jq -r .password)

cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sed -i "s/database_name_here/wordpress/" /var/www/html/wp-config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$DB_PASS/" /var/www/html/wp-config.php
sed -i "s/localhost/${rds_endpoint}/" /var/www/html/wp-config.php

# 6. Set permissions for Apache
chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

systemctl restart httpd