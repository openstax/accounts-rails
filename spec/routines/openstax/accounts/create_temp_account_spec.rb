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

      it 'passes names to the API when creating users' do
        create_temp_account_response = double('Response')
        allow(create_temp_account_response).to receive(:status).and_return(200)
        allow(create_temp_account_response).to receive(:body).and_return('{"id":1}')

        expect(OpenStax::Accounts::Api).to receive(:create_temp_account).with(
          email: 'bob@example.com', username: nil, password: nil,
          first_name: 'Bob', last_name: 'Smith', full_name: 'Bob Smith'
        ).and_return(create_temp_account_response)

        CreateTempAccount.call(
          email: 'bob@example.com', first_name: 'Bob', last_name: 'Smith',
          full_name: 'Bob Smith'
        )
      end

      after(:all) do
        OpenStax::Accounts.configuration.openstax_accounts_url = @previous_url
        OpenStax::Accounts.configuration.enable_stubbing = @previous_enable_stubbing
        OpenStax::Accounts::Api.client.site = @previous_url
      end

    end

  end
end
