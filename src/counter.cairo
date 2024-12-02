use starknet::{ContractAddress};

#[starknet::interface]
pub trait ICounter<T> {
    fn set_count(ref self: T, value: u64);
    fn get_count(self: @T) -> u64;
    fn get_admin(self: @T) -> ContractAddress;
}

// - CounterDispatcher
// - CounterLibraryDispatcher
// - CounterDispatcherTrait

#[starknet::contract]
pub mod Counter {
    use super::ContractAddress;
    use starknet::{get_caller_address};

    #[storage]
    struct Storage {
        count: u64,
        admin: ContractAddress
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin_address: ContractAddress) {
        self.admin.write(admin_address);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        SetCount: SetCount
    }

    #[derive(Drop, starknet::Event)]
    pub struct SetCount {
        #[key]
        pub value: u64
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        fn set_count(ref self: ContractState, value: u64) {
            let caller: ContractAddress = get_caller_address();
            let admin: ContractAddress = self.admin.read();

            assert(caller == admin, 'caller not admin');
            assert(value > 0, 'zero value');

            self.count.write(self.count.read() + value);

            self.emit(SetCount { value });
        }

        fn get_count(self: @ContractState) -> u64 {
            self.count.read()
        }

        fn get_admin(self: @ContractState) -> ContractAddress {
            self.admin.read()
        }
    }
}
