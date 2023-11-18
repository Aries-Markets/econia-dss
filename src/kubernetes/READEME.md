# Setup

(install kompose)[https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/#install-kompose]

`brew install kompose`

Under `src/docker`:

`kompose convert -f compose.dss-global.yaml --out ../kubernetes/manifest/testnet --with-kompose-annotation=false`
