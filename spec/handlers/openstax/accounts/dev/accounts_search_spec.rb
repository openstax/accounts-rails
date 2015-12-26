require 'spec_helper'

module OpenStax
  module Accounts

    describe Dev::AccountsSearch do
      
      let!(:account_1)          { FactoryGirl.create :openstax_accounts_account,
                                                  first_name: 'John',
                                                  last_name: 'Stravinsky',
                                                  username: 'jstrav' }
      let!(:account_2)          { FactoryGirl.create :openstax_accounts_account,
                                                  first_name: 'Mary',
                                                  last_name: 'Mighty',
                                                  full_name: 'Mary Mighty',
                                                  username: 'mary' }
      let!(:account_3)          { FactoryGirl.create :openstax_accounts_account,
                                                  first_name: 'John',
                                                  last_name: 'Stead',
                                                  username: 'jstead' }

      let!(:account_4)          { FactoryGirl.create :openstax_accounts_account,
                                                  first_name: 'Bob',
                                                  last_name: 'JST',
                                                  username: 'bigbear' }

      let!(:billy_accounts) {
        (0..49).to_a.collect{|ii|
          FactoryGirl.create :openstax_accounts_account,
                             first_name: "Billy#{ii.to_s.rjust(2, '0')}",
                             last_name: "Bob_#{(49-ii).to_s.rjust(2,'0')}",
                             username: "billy_#{ii.to_s.rjust(2, '0')}"
        }
      }

      it "should match based on username" do
        result = Dev::AccountsSearch.call(params: {search: {query: "username:jstra"}})
        expect(result.total_count).to eq 1
        expect(result.items).to eq [account_1]
      end

      it "should have no limits" do
        routine = Dev::AccountsSearch.call(params: {search: {query: ""}})
        errors = routine.errors
        expect(routine.total_count).to eq 54
        expect(routine.items).to eq [account_4, billy_accounts, account_3,
                                     account_1, account_2].flatten
        expect(errors).to be_empty
      end

    end

  end
end
