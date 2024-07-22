module move_sui_swap::move_sui_swap {
    use sui::balance;
    use sui::balance::Balance;
    use sui::coin;
    use sui::coin::Coin;
    use sui::transfer::{share_object, transfer, public_transfer};
    use sui::tx_context::sender;
    use move_sui_coin::carry_coin::CARRY_COIN;
    use move_sui_coin::faucet_coin::FAUCET_COIN;

    public struct Bank has key {
        id: object::UID,
        carry_coin: Balance<CARRY_COIN>,
        faucet_coin: Balance<FAUCET_COIN>,
    }

    public struct AdminCap has key {
        id: object::UID
    }

    fun init(ctx: &mut TxContext) {
        let bank = Bank {
            id: object::new(ctx),
            carry_coin: balance::zero<CARRY_COIN>(),
            faucet_coin: balance::zero<FAUCET_COIN>(),
        };
        share_object(bank);

        let admin_cap = AdminCap {
            id: object::new(ctx)
        };

        transfer(admin_cap, sender(ctx));
    }

    public fun swap_carry_coin_to_faucet_coin(
        bank: &mut Bank,
        in: Coin<CARRY_COIN>,
        ctx: &mut TxContext
    ): Coin<FAUCET_COIN> {
        let in_value = coin::value(&in);

        // 1 carry_coin = 7.3 faucet_coin
        let out_amt = in_value * 73000 / 10000;

        let in_balance = coin::into_balance(in);

        balance::join(&mut bank.carry_coin, in_balance);

        let out_balance = balance::split(&mut bank.faucet_coin, out_amt);

        return coin::from_balance(out_balance, ctx)
    }

    public entry fun entry_swap_carry_coin_to_faucet_coin(bank: &mut Bank,
                                                          in: Coin<CARRY_COIN>,
                                                          ctx: &mut TxContext) {
        let coin = swap_carry_coin_to_faucet_coin(bank, in, ctx);
        public_transfer(coin, sender(ctx));
    }

    public fun swap_faucet_coin_to_carry_coin(
        bank: &mut Bank,
        in: Coin<FAUCET_COIN>,
        ctx: &mut TxContext
    ): Coin<CARRY_COIN> {
        let in_value = coin::value(&in);

        // 1 carry_coin = 7.3 faucet_coin
        let out_amt = in_value * 10000 / 73000;

        let in_balance = coin::into_balance(in);

        balance::join(&mut bank.faucet_coin, in_balance);

        let out_balance = balance::split(&mut bank.carry_coin, out_amt);

        return coin::from_balance(out_balance, ctx)
    }

    public entry fun entry_swap_faucet_coin_to_carry_coin(bank: &mut Bank,
                                                          in: Coin<FAUCET_COIN>,
                                                          ctx: &mut TxContext) {
        let coin = swap_faucet_coin_to_carry_coin(bank, in, ctx);
        public_transfer(coin, sender(ctx));
    }


    public entry fun add_carry_coin(bank: &mut Bank, in: Coin<CARRY_COIN>, _ctx: &mut TxContext) {
        let in_balance = coin::into_balance(in);
        balance::join(&mut bank.carry_coin, in_balance);
    }

    public entry fun add_faucet_coin(bank: &mut Bank, in: Coin<FAUCET_COIN>, _ctx: &mut TxContext) {
        let in_balance = coin::into_balance(in);
        balance::join(&mut bank.faucet_coin, in_balance);
    }

    public entry fun remove_carry_coin(_: &AdminCap, bank: &mut Bank, amt: u64, ctx: &mut TxContext) {
        let out_balance = balance::split(&mut bank.carry_coin, amt);
        let out = coin::from_balance(out_balance, ctx);
        public_transfer(out, sender(ctx));
    }

    public entry fun remove_faucet_coin(_: &AdminCap, bank: &mut Bank, amt: u64, ctx: &mut TxContext) {
        let out_balance = balance::split(&mut bank.faucet_coin, amt);
        let out = coin::from_balance(out_balance, ctx);
        public_transfer(out, sender(ctx));
    }
}