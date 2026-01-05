#!/bin/bash

docker stop netflix
docker rm netflix
docker image ryansaad85/netflix-react-app:latest 
