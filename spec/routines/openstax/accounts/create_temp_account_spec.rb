require 'spec_helper'
require 'vcr_helper'

module OpenStax
  module Accounts

    describe CreateTempAccount, vcr: VCR_OPTS do

      before(:all) do
        OpenStax::Accounts.configure do |config|
          config.openstax_accounts_url = "http://localhost:2999/"
        end
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
        OpenStax::Accounts.configure do |config|
          config.openstax_accounts_url = "http://localhost:#{CAPYBARA_SERVER.port}/"
        end
      end

    end

  end
end
