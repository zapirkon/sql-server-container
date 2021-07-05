TODO:
- volume mode cached or delegated or default
- instance name, exposed port (not trivial in windows, simplest way - find the static ip of the virtual adapter)
  - connecting from windows to the docker container through ip of `Ethernet adapter vEthernet (WSL)`, obtained via `ipconfig`
  - https://docs.microsoft.com/en-us/windows/wsl/compare-versions#accessing-a-wsl-2-distribution-from-your-local-area-network-lan

should not happen, but a folder in mssql can be set to be owned by mssql account:
```sh
docker exec -it -u 0:0 sql-server-container bash
chown -R 10001:0 data2
```

> https://docs.docker.com/compose/reference/envvars/#compose_project_name

> https://github.com/dbafromthecold/examplesqldockerfiles

> https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-environment-variables?view=sql-server-ver15#environment-variables

> https://docs.docker.com/engine/reference/builder/#expose

wsl local folders
`$ wsl -d docker-desktop`
`cd /mnt/host/wsl/docker-desktop-data/isocache`

docker builder prune

---

- `docker run --name sql-server-container -p 1500:1433 -v data:/var/opt/mssql/data2 -v backup:/var/opt/mssql/backup -d mcr.microsoft.com/mssql/server:2019-latest`

- `docker build . -t sql-server-container-image`
  - `docker run --name sql-server-container -p 1500:1433 -v data:/var/opt/mssql/data2 -v backup:/var/opt/mssql/backup -d sql-server-container-image`
  - `docker run --name sql-server-container -p 1500:1433 --mount type=bind,source=%~dp0\data,target=/var/opt/mssql/data2 --mount type=bind,source=%~dp0\backup,target=/var/opt/mssql/backup -d sql-server-container-image`

`docker start sql-server-container`

- check
  - `docker exec -it sql-server-container bash`
  - `docker exec -it sql-server-container /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -Q "SELECT name FROM sys.databases;"`
  - `docker exec -it sql-server-container /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/AdventureWorks2019.bak';"`
  