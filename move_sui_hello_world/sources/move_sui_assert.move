module move_sui_hello_world::move_sui_assert {

    use std::string::{Self, String};


    fun main(a: bool) {
        assert!(a == true, 0);
        // code here will be executed if (a == true)
    }

    fun factorial(n: u64): u64 {
        if (n == 0) {
            return 1;
        } else {
            return n * factorial(n - 1);
        }
    }
}
