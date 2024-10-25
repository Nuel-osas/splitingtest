module beegblue::fund_redirector {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};
    use sui::event;

    // Define the recipient wallet addresses
    const SUIONCAMPUS_WALLET: address = @0x3f3347074d29f4b73dc07b42ddbf121aaec08832153ec0b497a46a1809d17342;
    const SUINIGERIA_WALLET: address = @0x7a474eba3c09d6503e5735e701e3162d969317bc48c8b6a52c1f712612b6af2c;

    // Error codes
    const EZERO_AMOUNT: u64 = 1;

    // Event structs
    struct FundRedirectEvent has copy, drop {
        amount: u64,
        suioncampus_amount: u64,
        suinigeria_amount: u64,
        timestamp: u64
    }

    // Resource struct to track redirections
    struct RedirectTracker has key {
        id: UID,
        total_redirected: u64,
        total_transactions: u64
    }

    // Initialize the module
    fun init(ctx: &mut TxContext) {
        let tracker = RedirectTracker {
            id: object::new(ctx),
            total_redirected: 0,
            total_transactions: 0
        };
        transfer::share_object(tracker);
    }

    // Main function to handle the redirection of any coin type
    public entry fun redirect_funds<T>(
        payment: Coin<T>, 
        tracker: &mut RedirectTracker,
        ctx: &mut TxContext
    ) {
        // Get the total amount
        let total_amount = coin::value(&payment);
        
        // Verify the amount is valid
        assert!(total_amount > 0, EZERO_AMOUNT);
        
        // Calculate equal shares
        let half_amount = total_amount / 2;
        
        // Split the coins
        let split_coin = coin::split(&mut payment, half_amount, ctx);
        
        // Update tracker
        tracker.total_redirected = tracker.total_redirected + total_amount;
        tracker.total_transactions = tracker.total_transactions + 1;

        // Emit event
        event::emit(FundRedirectEvent {
            amount: total_amount,
            suioncampus_amount: half_amount,
            suinigeria_amount: total_amount - half_amount,
            timestamp: tx_context::epoch(ctx)
        });

        // Transfer to recipients
        transfer::public_transfer(split_coin, SUIONCAMPUS_WALLET);
        transfer::public_transfer(payment, SUINIGERIA_WALLET);
    }

    // View function to get total redirected amount
    public fun get_total_redirected(tracker: &RedirectTracker): u64 {
        tracker.total_redirected
    }

    // View function to get total number of transactions
    public fun get_total_transactions(tracker: &RedirectTracker): u64 {
        tracker.total_transactions
    }
}
