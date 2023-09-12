#!/bin/bash

docker compose stop
docker compose down
docker image rm -f e-taxi-micro:latest
docker compose up --build -d --remove-orphans