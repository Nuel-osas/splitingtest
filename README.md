 Fund Redirector Smart Contract

Overview
The Fund Redirector is a Sui Move smart contract designed to automatically split and redirect incoming funds between two predefined wallet addresses: SUIonCampus and SUINigeria. Each transaction is split 50/50 between these two recipients, providing a transparent and automated way to manage fund distribution.

 Features
- Automatic 50/50 split of any incoming funds
- Support for any coin type on the Sui network
- Transaction tracking and transparency
- Event emission for each redirection
- Public view functions for monitoring total redirected amounts

 Recipient Addresses
- SUIonCampus: `0x3f3347074d29f4b73dc07b42ddbf121aaec08832153ec0b497a46a1809d17342`
- SUINigeria: `0x7a474eba3c09d6503e5735e701e3162d969317bc48c8b6a52c1f712612b6af2c`

Contract Structure

 Core Components

1. RedirectTracker
   - Shared object that tracks:
     - Total amount of funds redirected
     - Total number of transactions processed

2. FundRedirectEvent
   - Emitted after each successful redirection with details:
     - Total amount redirected
     - Amount sent to SUIonCampus
     - Amount sent to SUINigeria
     - Timestamp (epoch)

 Main Functions

# `redirect_funds<T>`
```move
public entry fun redirect_funds<T>(payment: Coin<T>, tracker: &mut RedirectTracker, ctx: &mut TxContext)
```
- Main function for redirecting funds
- Generic type `T` allows for any coin type
- Automatically splits the payment 50/50
- Updates tracking metrics
- Emits redirection event
- Transfers funds to recipient addresses

# View Functions

1. `get_total_redirected`
   ```move
   public fun get_total_redirected(tracker: &RedirectTracker): u64
   ```
   - Returns the total amount of funds redirected through the contract

2. `get_total_transactions`
   ```move
   public fun get_total_transactions(tracker: &RedirectTracker): u64
   ```
   - Returns the total number of transactions processed

## Error Handling
- `EZERO_AMOUNT` (Code: 1): Thrown when attempting to redirect zero funds

## Usage Example

```move
// Assuming you have a coin of type 'SUI' and the tracker object
let my_coin = // ... your coin object
let tracker = // ... tracker object reference

// Redirect funds
redirect_funds(my_coin, tracker, ctx);
```

## Events
The contract emits `FundRedirectEvent` for each redirection with the following information:
```move
struct FundRedirectEvent {
    amount: u64,              // Total amount redirected
    suioncampus_amount: u64,  // Amount sent to SUIonCampus
    suinigeria_amount: u64,   // Amount sent to SUINigeria
    timestamp: u64            // Epoch timestamp
}
```

 Security Features
1. Immutable recipient addresses
2. Amount validation checks
3. Transparent tracking of all transactions
4. Public view functions for monitoring

 Notes
- The contract splits funds exactly in half, with any remainder going to SUINigeria
- All transactions are permanent and irreversible
- The contract supports any coin type on the Sui network
- Transaction history and amounts are publicly viewable through events and tracker functions
