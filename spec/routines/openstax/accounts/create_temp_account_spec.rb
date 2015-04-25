require 'spec_helper'
require 'vcr_helper'

module OpenStax
  module Accounts

    describe CreateTempAccount, vcr: VCR_OPTS do

      before(:all) do
        @previous_url = OpenStax::Accounts.configuration.openstax_accounts_url
        @previous_enable_stubbing = OpenStax::Accounts.configuration.enable_stubbing
        OpenStax::Accounts.configuration.openstax_accounts_url = "http://localhost:2999/"
        OpenStax::Accounts.configuration.enable_stubbing = false
        OpenStax::Accounts::Api.client.site = "http://localhost:2999/"
      end

      it 'can create temp users' do
        account_1 = CreateTempAccount.call(email: 'alice@example.com').outputs.account
        expect(account_1).to be_persisted

        account_2 = CreateTempAccount.call(username: 'alice').outputs.account
        expect(account_2).to be_persisted
        expect(account_1).not_to eq(account_2)

        account_3 = CreateTempAccount.call(username: 'alice2',
                                           password: 'abcdefghijklmnop').outputs.account
        expect(account_3).to be_persisted
        expect(account_1).not_to eq(account_3)
        expect(account_2).not_to eq(account_3)
      end

      after(:all) do
        OpenStax::Accounts.configuration.openstax_accounts_url = @previous_url
        OpenStax::Accounts.configuration.enable_stubbing = @previous_enable_stubbing
        OpenStax::Accounts::Api.client.site = @previous_url
      end

    end

  end
end
