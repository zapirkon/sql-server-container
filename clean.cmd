@echo off
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=*" %%A in (.env) do SET %%A 2>nul
docker stop %COMPOSE_PROJECT_NAME%
docker container rm %COMPOSE_PROJECT_NAME%
docker volume rm sqlbackup
docker volume rm sqldata2
docker image rm %COMPOSE_PROJECT_NAME%
docker network rm %COMPOSE_PROJECT_NAME%
