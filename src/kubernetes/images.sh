#!/bin/bash

dir=$(dirname $(realpath $0))

IMAGE_TAG="latest"

export DOCKER_REGISTRY="854153369854.dkr.ecr.ap-southeast-1.amazonaws.com/econia-dss"
export PROJECT_DIR=$dir/../../src/docker

function ecr-auth() {
    aws ecr get-login-password --region ap-southeast-1 | \
    docker login --username AWS --password-stdin $DOCKER_REGISTRY
}

function aggregator() {
    docker build \
    -f $PROJECT_DIR/aggregator/Dockerfile \
    -t $DOCKER_REGISTRY/aggregator:$IMAGE_TAG \
    $PROJECT_DIR/aggregator
}

function postgres() {
    docker build \
    -f $PROJECT_DIR/database/Dockerfile.postgres \
    -t $DOCKER_REGISTRY/postgres:$IMAGE_TAG \
    $PROJECT_DIR/database
}

function deisel() {
    docker build \
    -f $PROJECT_DIR/database/Dockerfile.diesel \
    -t $DOCKER_REGISTRY/diesel:$IMAGE_TAG \
    --build-arg "DATABASE_URL=postgres://econia:econia@postgres:5432/econia" \
    $PROJECT_DIR/database
}

function processor() {
    docker build \
    -f $PROJECT_DIR/processor/Dockerfile \
    -t $DOCKER_REGISTRY/processor:$IMAGE_TAG \
    $PROJECT_DIR/processor
}

function ws() {
    docker build \
    -f $PROJECT_DIR/api/Dockerfile.ws \
    -t $DOCKER_REGISTRY/ws:$IMAGE_TAG \
    --build-arg POSTGRES_WEBSOCKETS_VERSION=0.11.1.0 \
    $PROJECT_DIR/api
}

function postgrest() {
    docker build \
    -f $PROJECT_DIR/api/Dockerfile.postgrest \
    -t $DOCKER_REGISTRY/postgrest:$IMAGE_TAG \
    $PROJECT_DIR/api
}

function push() {
    docker push $DOCKER_REGISTRY/$1:$IMAGE_TAG 
}

case "$1" in
    ecr) ecr-auth ;;
    build) $2 ;;
    push) push $2 ;;
    *) echo "Invalid cmd" ;;
esac