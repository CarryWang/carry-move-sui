module move_sui_game::move_sui_game {

    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::coin::{Coin, into_balance, from_balance};
    use sui::random;
    use sui::random::Random;
    use sui::transfer::{transfer, public_transfer};
    use sui::tx_context::sender;
    use move_sui_coin::faucet_coin::FAUCET_COIN;

    public struct GamePool has key {
        id: UID,
        val: Balance<FAUCET_COIN>
    }

    public struct AdminCap has key {
        id: UID
    }

    fun init(ctx: &mut TxContext) {
        let game_pool = GamePool {
            id: object::new(ctx),
            val: balance::zero()
        };

        transfer::share_object(game_pool);

        let admin = AdminCap {
            id: object::new(ctx)
        };

        transfer(admin, sender(ctx));
    }

    #[allow(lint(public_random))]
    public entry fun play(game_pool: &mut GamePool, flip_value: bool, in: Coin<FAUCET_COIN>, rand: &Random, ctx: &mut TxContext) {
        let coin_value = coin::value(&in);
        let game_val = balance::value(&game_pool.val);

        let player_address = sender(ctx);

        if (game_val < coin_value) {
            abort 100u64
        };

        if (coin_value > (game_val / 10)) {
            abort 100u64
        };

        let mut gen = random::new_generator(rand, ctx);


        let flag = random::generate_bool(&mut gen);

        if (flip_value == flag) {
            // win the game
            let win_balance = balance::split(&mut game_pool.val, coin_value);
            let win_coin = from_balance(win_balance, ctx);
            public_transfer(win_coin, player_address);
            public_transfer(in, player_address);
        }else {
            // lose the game
            let in_balance = into_balance(in);
            balance::join(&mut game_pool.val, in_balance);
        }
    }

    public entry fun add_coin(game_pool: &mut GamePool, in: Coin<FAUCET_COIN>, _ctx: &mut TxContext) {
        let in_balance = into_balance(in);
        balance::join(&mut game_pool.val, in_balance);
    }

    public entry fun remove_coin(_: &AdminCap, game_pool: &mut GamePool, amount: u64, ctx: &mut TxContext) {
        let balance = balance::split(&mut game_pool.val, amount);
        let coin = from_balance(balance, ctx);
        public_transfer(coin, sender(ctx));
    }
}