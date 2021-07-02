# wait 30 seconds to start the server before executing the start script
(sleep 30s && /var/opt/mssql/start.sh) & /opt/mssql/bin/sqlservr
