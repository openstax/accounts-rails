require 'spec_helper'

module OpenStax
  module Accounts

    describe CreateGroup, type: :routine do

      before(:all) do
        @previous_enable_stubbing = OpenStax::Accounts.configuration.enable_stubbing
        OpenStax::Accounts.configuration.enable_stubbing = true
      end

      let!(:owner) { FactoryBot.create :openstax_accounts_account }

      it 'can create groups' do
        group = CreateGroup[owner: owner, name: 'Test', is_public: true]
        expect(group).to be_persisted

        expect(group.name).to eq 'Test'
        expect(group.is_public).to eq true
        expect(group.owners.first).to eq owner
        expect(group.members).to be_empty
      end

      after(:all) do
        OpenStax::Accounts.configuration.enable_stubbing = @previous_enable_stubbing
      end

    end

  end
end
