# build the image and tag it appropriately

docker buildx build --platform linux/amd64,linux/arm64 --build-arg SOLANA_CLI=1.17.29 -f Dockerfile -t ghcr.io/wormholelabs-xyz/solana-test-validator:1.17.29 .

# push to ghcr

docker push ghcr.io/wormholelabs-xyz/solana-test-validator:1.17.29
