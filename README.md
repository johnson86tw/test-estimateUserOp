# test-estimateUserOp

- Demo.sol: 在 validation phase 寫入 storage，estimateUserOp 會讀更新的 storage 值來做模擬 execution。
- Demo2.sol: estimateUserOp 時 signature 來自 dummy signature，recover 的地址不是真正的地址，validateUserOp 若 revert，estimateUserOp 會失敗，若是 signature 驗證錯誤的問題，要 return 1，bundler 知道自己用的 signature 是假的，所以會接續模擬 estimateUserOp。
- Demo3.sol: Demo2 問題的解法之一，將地址存在 nonceKey，於 validateUserOp 時做驗證，用 nonceKey 存的地址來做暫存，讓 estimateUserOpGas 能成功。


## Test

- 記得填 .env
- Demo 和 Demo2 共用 ts/index.ts，Demo3 用 ts/demo3.ts

```
Test address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Test privateKey: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

```
forge test --mp test/Demo1.t.sol
forge test --mp test/Demo2.t.sol
forge test --mp test/Demo3.t.sol
```


### Demo 3

- Demo2 的解決方案：將 signer address 存在 nonceKey，使用這個 signer address （而不是 recovered signer address）做權限驗證，並將 signer address 存入 transient storage，最後驗證 signature 是否由 signer 所簽。

```
docker compose up -d

forge script script/Demo3.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

```
bun run ts/demo3.ts
```

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