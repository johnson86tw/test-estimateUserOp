# test-estimateUserOp

- fullfill .env


```
docker compose up -d
(wait a minute for bundler to set up)

forge script script/Demo.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

bun run ts/index.ts
```