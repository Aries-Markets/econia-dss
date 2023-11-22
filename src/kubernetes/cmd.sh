#!/bin/bash

dir=$(dirname $(realpath $0))

function build() {
    kustomize build \
    --load-restrictor LoadRestrictionsNone \
    --output $dir/manifest/$1/artifacts \
    $dir/manifest/$1
}

function apply() {
    build $1
    if [[ -z "$2" ]]; then
        kubectl apply -f "$dir/manifest/$1/artifacts/"
    else
        kubectl apply -f "$dir/manifest/$1/artifacts/*$2.yaml"
    fi
}

case "$1" in
    apply) apply $2 $3 ;;
    build) build $2 ;;
    *) echo "Invalid cmd" ;;
esac