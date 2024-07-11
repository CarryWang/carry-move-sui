module move_sui_coin::carry_coin {

    use sui::coin;
    use sui::transfer::{public_transfer, public_freeze_object};
    use sui::url::Url;

    public struct CARRY_COIN has drop {}

    fun init(witness: CARRY_COIN, ctx: &mut TxContext) {
        let icon_url = option::none<Url>();

        let (treasury_cap, coin_metadata) = coin::create_currency(
            witness,
            6,
            b"CC",
            b"CarryCoin",
            b"This is the Carry Coin",
            icon_url,
            ctx
        );

        public_freeze_object(coin_metadata);

        public_transfer(treasury_cap, tx_context::sender(ctx));
    }
}
