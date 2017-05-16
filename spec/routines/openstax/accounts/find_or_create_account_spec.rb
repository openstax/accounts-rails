require 'spec_helper'
require 'vcr_helper'

module OpenStax
  module Accounts

    describe FindOrCreateAccount, type: :routine, vcr: VCR_OPTS do

      before(:all) do
        @previous_url = OpenStax::Accounts.configuration.openstax_accounts_url
        @previous_enable_stubbing = OpenStax::Accounts.configuration.enable_stubbing
        OpenStax::Accounts.configuration.openstax_accounts_url = "http://localhost:2999/"
        OpenStax::Accounts.configuration.enable_stubbing = false
        OpenStax::Accounts::Api.client.site = "http://localhost:2999/"
      end

      it 'can create users' do
        account_1 = FindOrCreateAccount.call(email: 'alice@example.com').outputs.account
        expect(account_1).to be_persisted

        account_2 = FindOrCreateAccount.call(username: 'alice').outputs.account
        expect(account_2).to be_persisted
        expect(account_1).not_to eq(account_2)

        account_3 = FindOrCreateAccount.call(username: 'alice2',
                                             password: 'abcdefghijklmnop').outputs.account
        expect(account_3).to be_persisted
        expect(account_1).not_to eq(account_3)
        expect(account_2).not_to eq(account_3)
      end

      it 'passes params to the API when creating users' do
        find_or_create_account_response = double('Response')
        allow(find_or_create_account_response).to receive(:status).and_return(201)
        allow(find_or_create_account_response).to receive(:body).and_return('{"id":1}')
        expect(OpenStax::Accounts::Api).to receive(:find_or_create_account).with(
          email: 'bob@example.com', username: nil, password: nil,
          first_name: 'Bob', last_name: 'Smith', full_name: 'Bob Smith',
          salesforce_contact_id: 'b0b', faculty_status: :rejected_faculty,
          role: :instructor
        ).and_return(find_or_create_account_response)

        FindOrCreateAccount.call(
          email: 'bob@example.com',
          first_name: 'Bob',
          last_name: 'Smith',
          full_name: 'Bob Smith',
          salesforce_contact_id: 'b0b',
          faculty_status: :rejected_faculty,
          role: :instructor
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
