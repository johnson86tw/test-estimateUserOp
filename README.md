# test-estimateUserOp

- 在 validation phase 寫入 storage，estimateUserOp 會讀更新的 storage 值來做模擬 execution
- estimateUserOp 時 signature 來自 dummy signature，recover 的地址不是真正的地址，validateUserOp 若 revert，estimateUserOp 會失敗，若是 signature 驗證錯誤的問題，要 return 1，bundler 知道自己用的 signature 是假的，所以會接續模擬 estimateUserOp。


## Test

- 記得填 .env

### Demo 2

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