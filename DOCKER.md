# build the image and tag it appropriately

DOCKER_BUILDKIT=1 docker build -f Dockerfile -t ghcr.io/wormholelabs-xyz/solana-test-validator-m1:1.17.29 .

# push to ghcr

docker push ghcr.io/wormholelabs-xyz/solana-test-validator-m1:1.17.29
