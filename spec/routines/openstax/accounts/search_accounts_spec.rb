require 'spec_helper'

module OpenStax
  module Accounts

    describe SearchAccounts, type: :routine do

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

      it "should match based on username" do
        outcome = SearchAccounts.call('username:jstra').outputs.items
        expect(outcome).to eq [account_1]
      end

      it "should ignore leading wildcards on username searches" do
        outcome = SearchAccounts.call('username:%rav').outputs.items
        expect(outcome).to eq []
      end

      it "should match based on one first name" do
        outcome = SearchAccounts.call('first_name:"John"').outputs.items
        expect(outcome).to eq [account_3, account_1]
      end

      it "should match based on one full name" do
        outcome = SearchAccounts.call('full_name:"Mary Mighty"').outputs.items
        expect(outcome).to eq [account_2]
      end

      it "should return all results if the query is empty" do
        outcome = SearchAccounts.call("").outputs.items
        expect(outcome).to eq [account_4, account_3, account_1, account_2]
      end

      it "should match any field when no prefix given" do
        outcome = SearchAccounts.call("jst").outputs.items
        expect(outcome).to eq [account_4, account_3, account_1]
      end

      it "should match any field when no prefix given and intersect when prefix given" do
        outcome = SearchAccounts.call("jst username:jst").outputs.items
        expect(outcome).to eq [account_3, account_1]
      end

      it "shouldn't allow users to add their own wildcards" do
        outcome = SearchAccounts.call("username:'%ar'").outputs.items
        expect(outcome).to eq []
      end

      it "should gather comma-separated unprefixed search terms" do
        outcome = SearchAccounts.call("john,mighty").outputs.items
        expect(outcome).to eq [account_3, account_1, account_2]
      end

      it "should not gather space-separated unprefixed search terms" do
        outcome = SearchAccounts.call("john mighty").outputs.items
        expect(outcome).to eq []
      end

      context "pagination and sorting" do

        let!(:billy_accounts) {
          (0..45).to_a.collect{|ii|
            FactoryBot.create :openstax_accounts_account,
                               first_name: "Billy#{ii.to_s.rjust(2, '0')}",
                               last_name: "Bob_#{(45-ii).to_s.rjust(2,'0')}",
                               username: "billy_#{ii.to_s.rjust(2, '0')}"
          }
        }

        it "should return the first page of values by default when requested" do
          outcome = SearchAccounts.call("username:billy", per_page: 20).outputs.items
          expect(outcome.length).to eq 20
          expect(outcome[0]).to eq Account.find_by!(username: "billy_00")
          expect(outcome[19]).to eq Account.find_by!(username: "billy_19")
        end

        it "should return the second page when requested" do
          outcome = SearchAccounts.call("username:billy", page: 2, per_page: 20).outputs.items
          expect(outcome.length).to eq 20
          expect(outcome[0]).to eq Account.find_by!(username: "billy_20")
          expect(outcome[19]).to eq Account.find_by!(username: "billy_39")
        end

        it "should return the incomplete 3rd page when requested" do
          outcome = SearchAccounts.call("username:billy", page: 3, per_page: 20).outputs.items
          expect(outcome.length).to eq 6
          expect(outcome[5]).to eq Account.find_by!(username: "billy_45")
        end

      end

      context "sorting" do

        let!(:bob_brown) { FactoryBot.create :openstax_accounts_account, first_name: "Bob", last_name: "Brown", username: "foo_bb" }
        let!(:bob_jones) { FactoryBot.create :openstax_accounts_account, first_name: "Bob", last_name: "Jones", username: "foo_bj" }
        let!(:tim_jones) { FactoryBot.create :openstax_accounts_account, first_name: "Tim", last_name: "Jones", username: "foo_tj" }

        it "should allow sort by multiple fields in different directions" do
          outcome = SearchAccounts.call("username:foo", order_by: "first_name, last_name DESC").outputs.items
          expect(outcome).to eq [bob_jones, bob_brown, tim_jones]

          outcome = SearchAccounts.call("username:foo", order_by: "first_name, last_name ASC").outputs.items
          expect(outcome).to eq [bob_brown, bob_jones, tim_jones]
        end

      end

    end

  end
end
