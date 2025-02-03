# test-estimateUserOp

- 在 validation phase 寫入 storage，estimateUserOp 會讀更新的 storage 值來做模擬 execution，參考 Demo.sol。
- estimateUserOp 時 signature 來自 dummy signature，recover 的地址不是真正的地址，validateUserOp 若 revert，estimateUserOp 會失敗，若是 signature 驗證錯誤的問題，要 return 1，bundler 知道自己用的 signature 是假的，所以會接續模擬 estimateUserOp，參考 Demo2.sol。
- 


## Test

- 記得填 .env

### Demo 2

- 測試 signature signer 在 estimateUserOperationGas 時 recover 會是 zero address，導致存入 callerFromValidation 的值為 zero address，導致 estimate 失敗，但若跳過 estimate 是可以成功執行的。
- 可以測出 `JSON-RPC Error: eth_estimateUserOperationGas (-32521): UserOperation reverted during simulation with reason: 0xd92e233d`
- `0xd92e233d` == `ZeroAddress()`

```
docker compose up -d

forge script script/Demo2.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

- 記得到 index.ts 裡更新合約地址 DEMO_ADDRESS

```
bun run ts/index.ts
```


### Demo

- 測試 validateUserOp 時存取 callerFromValidation，estimeUserOperationGas 能夠在 execution phase 正確模擬更新後的值。

```
docker compose up -d

forge script script/Demo.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

- 記得到 index.ts 裡更新合約地址 DEMO_ADDRESS

```
bun run ts/index.ts
```


### Error

- 出現 `AA20 account not deployed` 可能是 ts/index.ts 的 Demo 合約地址沒有調成部署的地址