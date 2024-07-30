module move_sui_hello_world::move_sui_person {

    use std::string::{Self, String};

    /// An object that contains an arbitrary string
    public struct Person has key, store {
        id: UID,
        /// A string contained in the object
        name: String,
        age: u64,
        city: String
    }
    

    fun init(ctx: &mut TxContext) {
        let person = Person {
            id: object::new(ctx),
            name: string::utf8(b"Carry"),
            age: 28,
            city: string::utf8(b"Hong Kong"),
        };
        transfer::public_transfer(person, tx_context::sender(ctx));
    }
}
