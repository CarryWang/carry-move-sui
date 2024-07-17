module move_sui_nft::carry_nft {
    use sui::tx_context::{sender};
    use std::string::{utf8, String};

    // The creator bundle: these two packages often go together.
    use sui::package;
    use sui::display;

    /// The Carry NFT - an outstanding collection of digital art.
    public struct CarryNFT has key, store {
        id: UID,
        name: String,
        image_url: String,
    }

    /// One-Time-Witness for the module.
    public struct CARRY_NFT has drop {}

    /// In the module initializer one claims the `Publisher` object
    /// to then create a `Display`. The `Display` is initialized with
    /// a set of fields (but can be modified later) and published via
    /// the `update_version` call.
    ///
    /// Keys and values are set in the initializer but could also be
    /// set after publishing if a `Publisher` object was created.
    fun init(otw: CARRY_NFT, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"project_url"),
            utf8(b"creator"),
        ];

        let values = vector[
            // For `name` one can use the `Hero.name` property
            utf8(b"{name}"),
            // For `link` one can build a URL using an `id` property
            utf8(b"https://sui-heroes.io/hero/{id}"),
            // For `image_url` use an IPFS template + `image_url` property.
            utf8(b"ipfs://{image_url}"),
            // Description is static for all `Hero` objects.
            utf8(b"A true Hero of the Sui ecosystem!"),
            // Project URL is usually static
            utf8(b"https://sui-heroes.io"),
            // Creator field can be any
            utf8(b"Unknown Sui Fan")
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `CarryNFT` type.
        let mut display = display::new_with_fields<CarryNFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
    }

    /// Anyone can mint their `CarryNFT`!
    public entry fun mint(name: String, image_url: String, ctx: &mut TxContext) {
        let id = object::new(ctx);
        let nft =  CarryNFT { id, name, image_url };
        transfer::public_transfer(nft, sender(ctx));
    }

    public entry fun transfer(nft: CarryNFT, recipient: address){
        transfer::public_transfer(nft, recipient);
    }
}
