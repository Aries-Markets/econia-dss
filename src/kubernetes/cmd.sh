#!/bin/bash

dir=$(dirname $(realpath $0))

function apply-testnet() {
    kustomize build \
    --load-restrictor LoadRestrictionsNone \
    --output $dir/manifest/testnet/artifacts \
    $dir 
    kubectl apply -f $dir/manifest/testnet/artifacts/*$1.yaml
}

function apply-mainnet() {
    kustomize build \
    --load-restrictor LoadRestrictionsNone \
    --output $dir/manifest/mainnet/artifacts \
    $dir 
    kubectl apply -f $dir/manifest/mainnet/artifacts/*$1.yaml
}

case "$1" in
    testnet) apply-testnet $2 ;;
    mainnet) apply-mainnet $2 ;;
    *) echo "Invalid cmd" ;;
esac