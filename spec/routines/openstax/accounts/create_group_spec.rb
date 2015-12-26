require 'spec_helper'

module OpenStax
  module Accounts

    describe CreateGroup do

      before(:all) do
        @previous_enable_stubbing = OpenStax::Accounts.configuration.enable_stubbing
        OpenStax::Accounts.configuration.enable_stubbing = true
      end

      let!(:owner) { FactoryGirl.create :openstax_accounts_account }

      it 'can create groups' do
        group = CreateGroup.call(owner: owner, name: 'Test', is_public: true).group
        expect(group).to be_persisted

        expect(group.name).to eq 'Test'
        expect(group.is_public).to eq true
        expect(group.owners.first).to eq owner
        expect(group.members.first).to eq owner
      end

      after(:all) do
        OpenStax::Accounts.configuration.enable_stubbing = @previous_enable_stubbing
      end

    end

  end
end
