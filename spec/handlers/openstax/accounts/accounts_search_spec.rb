require 'spec_helper'

module OpenStax
  module Accounts

    describe AccountsSearch do
      
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
        outputs = AccountsSearch.call(params: {search: {query: "username:jstra"}}).outputs
        expect(outputs.total_count).to eq 1
        expect(outputs.items).to eq [account_1]
      end

      it "should return no results if the query is too short" do
        routine = AccountsSearch.call(params: {search: {query: ""}})
        outputs = routine.outputs
        errors = routine.errors
        expect(outputs.total_count).to be_nil
        expect(outputs.items).to be_nil
        expect(errors.last.code).to eq :query_too_short
      end

      it "should return no results if the limit is exceeded" do
        routine = AccountsSearch.call(params: {search: {query: "billy"}})
        outputs = routine.outputs
        errors = routine.errors
        expect(outputs.total_count).to eq 50
        expect(outputs.items).to be_nil
        expect(errors.last.code).to eq :too_many_items
      end

    end

  end
end
