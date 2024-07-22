module move_sui_swap::move_sui_swap_generic {
    use sui::balance;
    use sui::balance::Balance;
    use sui::coin;
    use sui::coin::Coin;
    use sui::transfer::{share_object, transfer, public_transfer};
    use sui::tx_context::sender;

    public struct Bank<phantom CoinA, phantom CoinB> has key {
        id: object::UID,
        coin_a: Balance<CoinA>,
        coin_b: Balance<CoinB>,
        ex_rate_a: u64,
        ex_rate_b: u64,
    }

    public struct AdminCap has key {
        id: object::UID
    }

    fun init(ctx: &mut TxContext) {
        let admin_cap = AdminCap {
            id: object::new(ctx)
        };

        transfer(admin_cap, sender(ctx));
    }

    public entry fun create_bank<CoinA, CoinB>(a: u64, b: u64, ctx: &mut TxContext) {
        let bank = Bank {
            id: object::new(ctx),
            coin_a: balance::zero<CoinA>(),
            coin_b: balance::zero<CoinB>(),
            ex_rate_a: a,
            ex_rate_b: b
        };
        share_object(bank);
    }

    public fun swap_coin_a_to_b<CoinA, CoinB>(
        bank: &mut Bank<CoinA, CoinB>,
        in: Coin<CoinA>,
        ctx: &mut TxContext
    ): Coin<CoinB> {
        let amt = coin::value(&in);

        let amt_a = amt * bank.ex_rate_a / bank.ex_rate_b;

        let in_balance = coin::into_balance(in);

        balance::join(&mut bank.coin_a, in_balance);

        let out_balance = balance::split(&mut bank.coin_b, amt_a);

        return coin::from_balance(out_balance, ctx)
    }

    public entry fun entry_swap_coin_a_to_b<CoinA, CoinB>(bank: &mut Bank<CoinA, CoinB>,
                                                          in: Coin<CoinA>,
                                                          ctx: &mut TxContext) {
        let coin = swap_coin_a_to_b(bank, in, ctx);
        public_transfer(coin, sender(ctx));
    }

    public fun swap_coin_b_to_a<CoinA, CoinB>(
        bank: &mut Bank<CoinA, CoinB>,
        in: Coin<CoinB>,
        ctx: &mut TxContext
    ): Coin<CoinA> {
        let amt = coin::value(&in);

        let amt_b = amt * bank.ex_rate_b / bank.ex_rate_a;

        let in_balance = coin::into_balance(in);

        balance::join(&mut bank.coin_b, in_balance);

        let out_balance = balance::split(&mut bank.coin_a, amt_b);

        return coin::from_balance(out_balance, ctx)
    }

    public entry fun entry_swap_coin_b_to_a<CoinA, CoinB>(bank: &mut Bank<CoinA, CoinB>,
                                                          in: Coin<CoinB>,
                                                          ctx: &mut TxContext) {
        let coin = swap_coin_b_to_a(bank, in, ctx);
        public_transfer(coin, sender(ctx));
    }


    public entry fun deposit_coin_a<CoinA, CoinB>(
        bank: &mut Bank<CoinA, CoinB>,
        in: Coin<CoinA>,
        _ctx: &mut TxContext
    ) {
        let in_balance = coin::into_balance(in);
        balance::join(&mut bank.coin_a, in_balance);
    }

    public entry fun deposit_coin_b<CoinA, CoinB>(
        bank: &mut Bank<CoinA, CoinB>,
        in: Coin<CoinB>,
        _ctx: &mut TxContext
    ) {
        let in_balance = coin::into_balance(in);
        balance::join(&mut bank.coin_b, in_balance);
    }


    public entry fun withdraw_coin_a<CoinA, CoinB>(
        _: &AdminCap,
        bank: &mut Bank<CoinA, CoinB>,
        amt: u64,
        ctx: &mut TxContext
    ) {
        let out_balance = balance::split(&mut bank.coin_a, amt);
        let out = coin::from_balance(out_balance, ctx);
        public_transfer(out, sender(ctx));
    }

    public entry fun withdraw_coin_b<CoinA, CoinB>(
        _: &AdminCap,
        bank: &mut Bank<CoinA, CoinB>,
        amt: u64,
        ctx: &mut TxContext
    ) {
        let out_balance = balance::split(&mut bank.coin_b, amt);
        let out = coin::from_balance(out_balance, ctx);
        public_transfer(out, sender(ctx));
    }
}