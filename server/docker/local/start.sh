#!/bin/bash

docker compose stop
docker compose down
docker image prune -f
docker compose up --build -d --remove-orphans