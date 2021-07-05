set -a
. .env
set +a
docker stop $COMPOSE_PROJECT_NAME
docker container rm $COMPOSE_PROJECT_NAME
docker volume rm sqlbackup
docker volume rm sqldata2
docker image rm $COMPOSE_PROJECT_NAME
docker network rm $COMPOSE_PROJECT_NAME

echo sudo rm -rf ./data/*.bak
