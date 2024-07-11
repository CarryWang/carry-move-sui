#[allow(lint(share_owned))]
module move_sui_coin::faucet_coin {

    use sui::coin;
    use sui::transfer::{ public_freeze_object,  public_share_object};
    use sui::url::Url;

    public struct FAUCET_COIN has drop {}

    fun init(witness: FAUCET_COIN, ctx: &mut TxContext) {
        let icon_url = option::none<Url>();

        let (treasury_cap, coin_metadata) = coin::create_currency(
            witness,
            6,
            b"CFC",
            b"CarryFaucetCoin",
            b"This is the Carry Faucet Coin",
            icon_url,
            ctx
        );

        public_freeze_object(coin_metadata);

        public_share_object(treasury_cap);
    }
}
