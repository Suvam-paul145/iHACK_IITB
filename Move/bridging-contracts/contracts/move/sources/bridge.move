module platform::Bridge {    
    use std::account::new_event_handle;
    use std::coin;
    use std::event::{
        EventHandle,
        emit_event,
    };
    use std::signer::address_of;
    use std::string::String;
    use std::table::{Self, Table};
    use platform::PlatformToken;

    #[test_only]
    use std::event::counter as event_counter;

    struct CreditCapability has key, drop {}

    struct Credits<phantom PlatformToken> has key {
        ledger: Table<address, u64>
    }

    struct Config has key {
        feeE12: u64,
        treasure: address,
        send_event_handle: EventHandle<SendEvent>,
        claim_event_handle: EventHandle<ClaimEvent>
    }

    struct SendEvent has store, drop {
        from: address,
        to: address,
        to_chain: u64,
        token_symbol: String,
        amount: u64
    }

    struct ClaimEvent has store, drop {
        claimee: address,
        token_symbol: String,
        amount: u64
    }

    // 100e12
    const WHOLE_PERCENT: u64 = 100000000000000;

    const EALREADY_INITIALIZED: u64 = 0;
    const EWRONG_FEE: u64 = 1;
    const EUNAUTHORIZED: u64 = 2;
    const ETOKEN_ALREADY_SUPPORTED: u64 = 3;
    const ETOKEN_IS_NOT_SUPPORTED: u64 = 4;
    const ENOTHING_TO_CLAIM: u64 = 5;

    public entry fun initialize(account: &signer, feeE12: u64, treasure: address) {
        assert!(address_of(account) == @platform, EUNAUTHORIZED);
        assert!(feeE12 < WHOLE_PERCENT, EWRONG_FEE);

        if (exists<Config>(@platform)) abort EALREADY_INITIALIZED;

        move_to(account, Config {
            feeE12,
            treasure,
            send_event_handle: new_event_handle<SendEvent>(account),
            claim_event_handle: new_event_handle<ClaimEvent>(account)
        });
        move_to(account, CreditCapability {});
    }

    public entry fun add_token_support<Token>(account: &signer) {
        assert!(address_of(account) == @platform, EUNAUTHORIZED);
        assert!(!is_token_supported<Token>(), ETOKEN_ALREADY_SUPPORTED);

        move_to(account, Credits<Token> { ledger: table::new() });
    }

    public entry fun send<Token>(from: &signer, to: address, to_chain: u64, amount: u64) acquires Config {
        PlatformToken::burn<Token>(address_of(from), amount);
        
        emit_event(
            &mut borrow_global_mut<Config>(@platform).send_event_handle,
            SendEvent {
                from: address_of(from),
                to,
                to_chain,
                token_symbol: coin::symbol<Token>(),
                amount
            }
        );
    }

    public entry fun claim<Token>(account: &signer) acquires Credits, Config {
        assert!(get_credits<Token>(address_of(account)) > 0, ENOTHING_TO_CLAIM);

        if (!coin::is_account_registered<Token>(address_of(account))) {
            coin::register<Token>(account);
        };

        let credits = borrow_global_mut<Credits<Token>>(@platform);

        let debt = table::remove(&mut credits.ledger, address_of(account));
        PlatformToken::mint<Token>(address_of(account), debt);

        emit_event(
            &mut borrow_global_mut<Config>(@platform).claim_event_handle,
            ClaimEvent {
                claimee: address_of(account),
                token_symbol: coin::symbol<Token>(),
                amount: debt
            }
        );
    }

    public entry fun credit_user<Token>(creditor: &signer, user: address, amount: u64) acquires Credits {
        assert!(exists<CreditCapability>(address_of(creditor)), EUNAUTHORIZED);

        let credits = borrow_global_mut<Credits<Token>>(@platform);

        let balance = 0u64;

        if (table::contains(&mut credits.ledger, user)) {
            balance = table::remove(&mut credits.ledger, user);
        };

        table::add(&mut credits.ledger, user, balance + amount);
    }

    public fun is_token_supported<Token>(): bool {
        exists<Credits<Token>>(@platform)
    }

    public fun get_credits<Token>(user: address): u64 acquires Credits {
        assert!(is_token_supported<Token>(), ETOKEN_IS_NOT_SUPPORTED);

        let credits = borrow_global_mut<Credits<Token>>(@platform);
        
        if (table::contains(&mut credits.ledger, user)) {
            *table::borrow(&mut credits.ledger, user)
        } else {
            0
        }
    }

    #[test_only]
    public fun get_send_event_counter(): u64 acquires Config {
        event_counter<SendEvent>(&borrow_global<Config>(@platform).send_event_handle)
    }
}