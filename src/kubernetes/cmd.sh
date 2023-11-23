#!/bin/bash

dir=$(dirname $(realpath $0))

export $(grep -v '^#' $HOME/.aptos/auth.env | xargs)

function api_key() {
    case "$1" in
        "testnet")
            echo "$APTOS_TESTNET_API_KEY"
            ;;
        "mainnet")
            echo "$APTOS_MAINNET_API_KEY"
            ;;
        *)
            echo "Invalid parameter. Please specify testnet or mainnet."
            ;;
    esac
}

function build() {
    kustomize build \
    --load-restrictor LoadRestrictionsNone \
    --output $dir/manifest/$1/artifacts \
    $dir/manifest/$1
}

function apply() {
    build $1

    key=$(api_key $1)

    sed -i 's@$API_KEY@'$key'@g' $dir/manifest/$1/artifacts/*

    if [[ -z "$2" ]]; then
        kubectl apply -f "$dir/manifest/$1/artifacts/"
    else
        kubectl apply -f "$dir/manifest/$1/artifacts/*$2.yaml"
    fi

    sed -i 's@'$key'@$API_KEY@g' $dir/manifest/$1/artifacts/*
}

case "$1" in
    apply) apply $2 $3 ;;
    build) build $2 ;;
    *) echo "Invalid cmd" ;;
esac