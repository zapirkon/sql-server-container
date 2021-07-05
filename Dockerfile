ARG SQL_IMAGE=
FROM $SQL_IMAGE
ARG SQL_PORT=
EXPOSE $SQL_PORT
VOLUME [ "/var/opt/mssql/data2", "/var/opt/mssql/backup" ]
WORKDIR /var/opt/mssql
COPY --chmod=755 /start.sh /var/opt/mssql/
ENTRYPOINT (sleep 30s && sed -i 's/\r$//' /var/opt/mssql/start.sh && /var/opt/mssql/start.sh) & /opt/mssql/bin/sqlservr
