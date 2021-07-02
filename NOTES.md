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


---
### multistage docker
```dockerfile
FROM ubuntu as intermediate
RUN mkdir -p /data
RUN mkdir -p /result
ADD data.tar /data/data.tar
RUN #some expensive operation
# finally, /result ends up with the final data

FROM ubuntu
COPY --from=intermediate /result /result
# simply use the result
```

### example 2 SSH
> https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/syntax.md#run---mounttypessh

> https://vsupalov.com/better-docker-private-git-ssh/

> https://vsupalov.com/docker-buildkit-features/

```dockerfile
# this is our first build stage, it will not persist in the final image
FROM ubuntu as intermediate

# install git
RUN apt-get update
RUN apt-get install -y git

# add credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa

# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

RUN git clone git@bitbucket.org:your-user/your-repo.git

FROM ubuntu
# copy the repository form the previous image
COPY --from=intermediate /your-repo /srv/your-repo
# ... actually use the repo :)

# There are two images defined here. One of them is named “intermediate”, the final one doesn’t have a name. The “intermediate” image is referenced, and we’re copying the repository data over from it into the final image.

# The SSH_PRIVATE_KEY is passed when issuing the build command with --build-arg or in the build block of your docker-compose.yml file. That ARG variable is not used in the final image, the value will not be available using the history command.
```