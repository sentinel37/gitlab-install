#!/bin/bash
var="$(ip route get 1 | awk '{print $NF;exit}')"
yum update -y;sudo yum install -y curl policycoreutils-python openssh-server;sudo systemctl enable sshd;sudo systemctl start sshd;sudo firewall-cmd --permanent --add-service=http;firewall-cmd --zone=public --add-port=25/tcp --permanent;sudo firewall-cmd --permanent --add-service=https;sudo systemctl reload firewalld;sudo yum install postfix;sudo systemctl enable postfix;sudo systemctl start postfix;curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash;sudo EXTERNAL_URL="https://$var" yum install -y gitlab-ee;

# Setting up GitLab SMTP
# More configurations may be needed to update the SMTP Settings:

echo 'mydomain = mail.boozallencsn.com'>>/etc/postfix/main.cf
echo 'relay_domains = mail.boozallencsn.com'>>/etc/postfix/main.cf


echo 'relayhost = $mydomain'>>/etc/postfix/main.cf
echo 'myorigin = $myhostname'>>/etc/postfix/main.cf
echo 'myorigin = $mydomain'>>/etc/postfix/main.cf

systemctl restart postfix

#backup once a week on Sunday
# Ref: https://docs.gitlab.com/omnibus/settings/backups.html
echo '0 0 * * 0 gitlab-ctl backup-etc && cd /etc/gitlab/config_backup && cp $(ls -t | head -n1) /secret/gitlab/backups/'>>/etc/crontab
