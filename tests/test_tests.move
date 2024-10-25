#[test_only]
module beegblue::fund_redirector_tests {
    use sui::test_scenario::{Self, begin, ctx};
    use sui::coin::{Self, mint_for_testing};
    use beegblue::fund_redirector::{Self};

    #[test]
    fun test_split_and_redirect() {
        let owner = @0x1;
        let scenario = begin(owner);

        // Initialize test
        test_scenario::next_tx(&mut scenario, owner); {
            fund_redirector::init(test_scenario::ctx(&mut scenario));
        };

        // Test splitting and redirecting funds
        test_scenario::next_tx(&mut scenario, owner); {
            let coin = mint_for_testing<sui::sui::SUI>(1000, ctx(&mut scenario));
            let tracker = test_scenario::take_shared<fund_redirector::RedirectTracker>(&scenario);
            
            fund_redirector::redirect_funds(
                coin,
                &mut tracker, 
                ctx(&mut scenario)
            );

            assert!(fund_redirector::get_total_redirected(&tracker) == 1000, 0);
            assert!(fund_redirector::get_total_transactions(&tracker) == 1, 1);
            
            test_scenario::return_shared(tracker);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = fund_redirector::EZERO_AMOUNT)]
    fun test_zero_amount_fails() {
        let owner = @0x1;
        let scenario = begin(owner);
        
        // Initialize test
        test_scenario::next_tx(&mut scenario, owner); {
            fund_redirector::init(ctx(&mut scenario));
        };

        // Test zero amount fails
        test_scenario::next_tx(&mut scenario, owner); {
            let coin = mint_for_testing<sui::sui::SUI>(0, ctx(&mut scenario));
            let tracker = test_scenario::take_shared<fund_redirector::RedirectTracker>(&scenario);

            fund_redirector::redirect_funds(
                coin,
                &mut tracker,
                ctx(&mut scenario)
            );

            test_scenario::return_shared(tracker);
        };

        test_scenario::end(scenario);
    }

    #[test] 
    fun test_multiple_redirects() {
        let owner = @0x1;
        let scenario = begin(owner);

        // Initialize
        test_scenario::next_tx(&mut scenario, owner); {
            fund_redirector::init(ctx(&mut scenario));
        };

        // First redirect
        test_scenario::next_tx(&mut scenario, owner); {
            let coin = mint_for_testing<sui::sui::SUI>(500, ctx(&mut scenario));
            let tracker = test_scenario::take_shared<fund_redirector::RedirectTracker>(&scenario);
            
            fund_redirector::redirect_funds(
                coin,
                &mut tracker,
                ctx(&mut scenario)
            );

            test_scenario::return_shared(tracker);
        };

        // Second redirect
        test_scenario::next_tx(&mut scenario, owner); {
            let coin = mint_for_testing<sui::sui::SUI>(1500, ctx(&mut scenario));
            let tracker = test_scenario::take_shared<fund_redirector::RedirectTracker>(&scenario);
            
            fund_redirector::redirect_funds(
                coin,
                &mut tracker,
                ctx(&mut scenario)
            );

            assert!(fund_redirector::get_total_redirected(&tracker) == 2000, 0);
            assert!(fund_redirector::get_total_transactions(&tracker) == 2, 1);

            test_scenario::return_shared(tracker);
        };

        test_scenario::end(scenario);
    }
}
