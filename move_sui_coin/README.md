## 模块部署信息

Transaction Digest: `FnuQnjEKCFHPEhAEGXTxkdk3op8XRP5ERFFr4xR3Bpcw`

PackageID: `0xa1be27082216fde27263bcae5f42a8ec0cb1b68b2a35b758a045ac74e335f93b`

Sender: `0x5bdcb0dd355f072607a5643b72197ec4409ab053856165d4b32b166a6cdcd6cb` 

CarryCoin TreasuryCap ObjectID: `0xd2a5c75ac888960665f877b6620da050347d7f88b2536e5dc9259feea3a2150`

CarryFaucetCoin Shared TreasuryCap ObjectID: `0xeeb1e388c5ffecfb8cf9eaa414782b69722e5b96335011b919373ab3e8b9f31e`

---

## Mint Coin
调用`coin`模块的`mint_and_transfer`函数
```sui move
/// Mint `amount` of `Coin` and send it to `recipient`. Invokes `mint()`.
public entry fun mint_and_transfer<T>(
    c: &mut TreasuryCap<T>, amount: u64, recipient: address, ctx: &mut TxContext
) {
    transfer::public_transfer(mint(c, amount, ctx), recipient)
}
```
调用命令
```shell
sui client call --package 0x2 --module coin --function mint_and_transfer
```
完整调用
```shell
sui client call \
  --package 0x2 \
  --module coin \
  --function mint_and_transfer \
  --args \
  0xd2a5c75ac888960665f877b6620da050347d7f88b2536e5dc9259feea3a2150 \
  100000000 \
  0x5bdcb0dd355f072607a5643b72197ec4409ab053856165d4b32b166a6cdcd6cb \
 --type-args "0xa1be27082216fde27263bcae5f42a8ec0cb1b68b2a35b758a045ac74e335f93b::carry_coin::CARRY_COIN"
```

