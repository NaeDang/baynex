Install and configure Zabbix for your platform
a. Become root user
Start new shell session with root privileges.

$ sudo -s
b. Install Zabbix repository
Documentation

# wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu22.04_all.deb

# dpkg -i zabbix-release_latest_7.2+ubuntu22.04_all.deb

# apt update

c. Install Zabbix server, frontend, agent

# apt install zabbix-server-pgsql zabbix-frontend-php php8.1-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent

d. Create initial database

Database setup
Create the user that will be the database owner, and create the Zabbix database; the database owner is the user that is specified on database creation:

createuser -U postgres -h localhost --pwprompt usr_owner
createdb -U postgres -h localhost -O usr_owner -E Unicode -T template0 zabbix

CREATE SCHEMA zabbix AUTHORIZATION usr_owner;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON DATABASE zabbix FROM PUBLIC;
-- Note: search_path should point to the "zabbix" schema:
ALTER ROLE ALL IN DATABASE zabbix SET search_path = "zabbix";

CREATE ROLE zbx_srv;
GRANT CONNECT ON DATABASE zabbix TO zbx_srv;
GRANT USAGE ON SCHEMA zabbix TO zbx_srv;
ALTER DEFAULT PRIVILEGES FOR ROLE usr_owner IN SCHEMA zabbix GRANT DELETE, INSERT, SELECT, UPDATE ON TABLES TO zbx_srv;
ALTER DEFAULT PRIVILEGES FOR ROLE usr_owner IN SCHEMA zabbix GRANT SELECT, UPDATE, USAGE ON sequences TO zbx_srv;

Make sure you have database server up and running.

Run the following on your database host.

sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix

On Zabbix server host import initial schema and data. You will be prompted to enter your newly created password.

# zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

e. Configure the database for Zabbix server
Edit file /etc/zabbix/zabbix_server.conf

DBPassword=password
f. Start Zabbix server and agent processes
Start Zabbix server and agent processes and make it start at system boot.

# systemctl restart zabbix-server zabbix-agent apache2

# systemctl enable zabbix-server zabbix-agent apache2

g. Open Zabbix UI web page
The default URL for Zabbix UI when using Apache web server is http://host/zabbix
