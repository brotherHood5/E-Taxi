#!/bin/bash

docker compose stop
docker compose down
docker image prune -f
docker compose up --build -d --scale helper_services=2 --scale core_services=2 --remove-orphans