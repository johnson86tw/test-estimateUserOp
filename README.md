# test-estimateUserOp

- 記得填 .env

### Demo 2

在 validation 寫入 storage，estimateUserOp 是會讀新的 storage 值來做模擬的。
```
docker compose up -d

forge script script/Demo2.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

- 記得到 index.ts 裡更新合約地址 DEMO_ADDRESS

```
bun run ts/index.ts
```


### Demo

```
docker compose up -d

forge script script/Demo.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

- 記得到 index.ts 裡更新合約地址 DEMO_ADDRESS

```
bun run ts/index.ts
```