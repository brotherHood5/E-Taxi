#!/bin/bash

docker compose stop
docker compose down
docker image prune -f
docker compose build --no-cache
docker compose up -d --remove-orphans