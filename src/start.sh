# https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver15
(
    /opt/mssql-tools/bin/sqlcmd -U SA -P $SA_PASSWORD -e -b -Q "SELECT name FROM sys.databases;" \
    | grep ${DB_NAME} \
    && echo "ALL GOOD!"
) || (
    echo "--- ${DB_NAME} NOT FOUND. TRYING TO ATTACH EXISTING DATA AND LOG ... "
    /opt/mssql-tools/bin/sqlcmd -U SA -P $SA_PASSWORD -e -b -Q "CREATE DATABASE [${DB_NAME}] ON (FILENAME = '/var/opt/mssql/data2/${DB_NAME}.mdf'), (FILENAME = '/var/opt/mssql/data2/${DB_NAME}.ldf') FOR ATTACH;" \
    && echo "ATTACHED OK!"
) || (
    /opt/mssql-tools/bin/sqlcmd -U SA -P $SA_PASSWORD -e -b -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/${DB_BAK_NAME}';" \
    && echo "--- ERROR ATTACHING ${DB_NAME}, TRYING TO RESTORE BAK ... PLEASE WAIT ... " \
    && (
        # need to touch for it to work in data2:
        touch /var/opt/mssql/data2/${DB_NAME}.mdf
        touch /var/opt/mssql/data2/${DB_NAME}.ldf
        /opt/mssql-tools/bin/sqlcmd -U SA -P $SA_PASSWORD -e -b -Q 'RESTORE DATABASE '${DB_NAME}' FROM DISK = "/var/opt/mssql/backup/'${DB_BAK_NAME}'" WITH REPLACE, MOVE "'${DB_DATA_NAME}'" TO "/var/opt/mssql/data2/'${DB_NAME}'.mdf", MOVE "'${DB_LOG_NAME}'" TO "/var/opt/mssql/data2/'${DB_NAME}'.ldf";'
    ) \
    && echo "RESTORED OK!"
) || echo "--- !!! DB NOT FOUND NOT ATTACHED AND NOT RESTORED !!! ---"

# for convenience, always try to add new user or update it to own the db with new login

/opt/mssql-tools/bin/sqlcmd -U SA -P $SA_PASSWORD -e -b -Q "USE master; CREATE LOGIN ${DB_LOGIN} WITH PASSWORD = N'${DB_PASS}', CHECK_POLICY = OFF, DEFAULT_DATABASE = ${DB_NAME};" \
&& echo "CREATED LOGIN ${DB_LOGIN}" \
|| echo "--- ERROR CREATING LOGIN ${DB_LOGIN}"

/opt/mssql-tools/bin/sqlcmd -U SA -P $SA_PASSWORD -e -b -Q "USE ${DB_NAME}; CREATE USER ${DB_LOGIN} FOR LOGIN ${DB_LOGIN};" \
&& echo "CREATED DB USER ${DB_LOGIN}" \
|| echo "--- ERROR CREATING DB USER ${DB_LOGIN}"

/opt/mssql-tools/bin/sqlcmd -U SA -P $SA_PASSWORD -e -b -Q "USE ${DB_NAME}; ALTER USER ${DB_LOGIN} WITH LOGIN = ${DB_LOGIN};" \
&& echo "REASSIGNED DB USER TO LOGIN ${DB_LOGIN}" \
|| echo "--- ERROR REASSIGNING DB USER TO LOGIN ${DB_LOGIN}"

/opt/mssql-tools/bin/sqlcmd -U SA -P $SA_PASSWORD -e -b -Q "USE ${DB_NAME}; ALTER ROLE db_owner ADD MEMBER ${DB_LOGIN};" \
&& echo "ASSIGNED DB OWNER ${DB_LOGIN}" \
|| echo "--- ERROR ASSIGNING DB OWNER ${DB_LOGIN}"

#TODO
# /opt/mssql/bin/sqlservr & sleep 60 | echo "Waiting for 60s to start Sql Server"
# echo "Setting RAM to 2GB usage."
# /opt/mssql/bin/mssql-conf set memory.memorylimitmb 2048
# echo "Restarting to apply the changes."
# systemctl restart mssql-server.service
