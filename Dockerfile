ARG SQL_IMAGE=
FROM $SQL_IMAGE
ARG SQL_PORT=
EXPOSE $SQL_PORT
VOLUME [ "/var/opt/mssql/data2", "/var/opt/mssql/backup" ]
WORKDIR /var/opt/mssql
COPY /src/*.sh .
ENTRYPOINT /var/opt/mssql/entrypoint.sh
