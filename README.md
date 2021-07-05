# Spin up SQL Server Database in WSL
> A Docker container using linux SQL Server image

> Configure and spin up a `bak` or `mdf` with most basic settings

> The `data` and `backups` remain where you have them (in a windows folder, not in a docker volume)

> Use it on Windows + WSL + Docker Desktop. For other setups a better soltion should exist
---
## **USE THIS CONTAINER FOR LOCAL DEV ONLY**
---
## **Don't use this** if you can already do it easily with **LocalDB**
---
## Why use linux SQL Server under WSL+Docker?
- I find it more portable (given you already had Docker Desktop installed) and maybe bit faster than installing SQL server
- it's a smaller image than the windows SQL Server container
- and ofcourse because there were challenges in making the linux container work under wsl

## Why this approach?
- your database is too large for LocalDB or you want to use more PC resources
- (I have not made tweaks in this repo to use more than the defaults of Docker and the Linux SQL Server image)

### scenario 1
- attach existing mdf from windows folder to sql container

### scenario 2
- restore bak and make the data files visible in windows

### in both scenarios
- specify sql server name and credentials to work with sql database located in windows folder
- possible to backup database back to windows folder
- SQL master database will remain in the original data folder which is not exposed

## TODOs and issues with docker+windows
- [worked around] restoring to bind mount - https://github.com/docker/for-win/issues/7259
- [wont fix] credentials are in `.env` (didn't bother making build args, i.e. initial image build)
- [wont fix] `.env` needs absolute path for bind mounts (for `driver_opts`)

## HOWTO
- edit the `.env` login credentials and location of where you have the data and backup folders (both under `LOCAL_PWD`)
  - if you want to test as is, [download `AdventureWorks2019.bak` from Microsoft](https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15&tabs=ssms#download-backup-files)
- if you work on a linux partition, `sudo chown -R 10001:0 data` and `sudo chown -R 10001:0 backup` (10001 is the mssql uid)
- `docker compose up`
  - or `DOCKER_BUILDKIT=1 docker-compose up`
- verify externally
  - `sqlcmd -S <ip,port> -U SA -P <SA_PASSWORD> -Q "SELECT name FROM sys.databases;"`
  - the ip address is a static on vEthernet (WSL) adapter (find it with `ipconfig`)
- or verify internally
  - `docker exec -it sql-server-container /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -Q "SELECT name FROM sys.databases;"`
- do your thing
