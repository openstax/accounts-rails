require 'spec_helper'

module OpenStax
  module Accounts

    RSpec.describe Dev::AccountsSearch do
      
      let!(:account_1)          { FactoryBot.create :openstax_accounts_account,
                                                  first_name: 'John',
                                                  last_name: 'Stravinsky',
                                                  username: 'jstrav' }
      let!(:account_2)          { FactoryBot.create :openstax_accounts_account,
                                                  first_name: 'Mary',
                                                  last_name: 'Mighty',
                                                  full_name: 'Mary Mighty',
                                                  username: 'mary' }
      let!(:account_3)          { FactoryBot.create :openstax_accounts_account,
                                                  first_name: 'John',
                                                  last_name: 'Stead',
                                                  username: 'jstead' }

      let!(:account_4)          { FactoryBot.create :openstax_accounts_account,
                                                  first_name: 'Bob',
                                                  last_name: 'JST',
                                                  username: 'bigbear' }

      let!(:billy_accounts) {
        (0..49).to_a.collect{|ii|
          FactoryBot.create :openstax_accounts_account,
                             first_name: "Billy#{ii.to_s.rjust(2, '0')}",
                             last_name: "Bob_#{(49-ii).to_s.rjust(2,'0')}",
                             username: "billy_#{ii.to_s.rjust(2, '0')}"
        }
      }

      it "should match based on username" do
        outputs = Dev::AccountsSearch.call(params: {search: {query: "username:jstra"}}).outputs
        expect(outputs.total_count).to eq 1
        expect(outputs.items).to eq [account_1]
      end

      it "should have no limits" do
        routine = Dev::AccountsSearch.call(params: {search: {query: ""}})
        outputs = routine.outputs
        errors = routine.errors
        expect(outputs.total_count).to eq 54
        expect(outputs.items).to eq [account_4, billy_accounts, account_3,
                                     account_1, account_2].flatten
        expect(errors).to be_empty
      end

    end

  end
end
