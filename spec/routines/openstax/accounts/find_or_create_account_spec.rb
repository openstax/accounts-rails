require 'spec_helper'
require 'vcr_helper'

module OpenStax
  module Accounts

    RSpec.describe FindOrCreateAccount, type: :routine, vcr: VCR_OPTS do

      before(:all) do
        @previous_url = OpenStax::Accounts.configuration.openstax_accounts_url
        @previous_enable_stubbing = OpenStax::Accounts.configuration.enable_stubbing
        OpenStax::Accounts.configuration.openstax_accounts_url = "http://localhost:2999/"
        OpenStax::Accounts.configuration.enable_stubbing = false
        OpenStax::Accounts::Api.client.site = "http://localhost:2999/"
      end

      it 'can create users' do
        account_1 = described_class.call(
          email: 'alice@example.com', role: 'instructor'
        ).outputs.account
        expect(account_1).to be_persisted
        expect(account_1.uuid).to(
          match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
        )
        expect(account_1.support_identifier).to match(/\Acs_[0-9a-f]{8}\z/i)
        expect(account_1.role).to eq 'instructor'

        account_2 = described_class.call(username: 'alice').outputs.account
        expect(account_2).to be_persisted
        expect(account_1).not_to eq(account_2)

        account_3 = described_class.call(username: 'alice2',
                                         password: 'abcdefghijklmnop').outputs.account
        expect(account_3).to be_persisted
        expect(account_1).not_to eq(account_3)
        expect(account_2).not_to eq(account_3)
      end

      it 'passes params to the API when creating users' do
        find_or_create_account_response = double('Response')
        allow(find_or_create_account_response).to receive(:status).and_return(201)
        allow(find_or_create_account_response).to(
          receive(:body).and_return(
            "{\"id\":1,\"uuid\":\"#{SecureRandom.uuid
            }\",\"support_identifier\":\"cs_#{SecureRandom.hex(4)}\"}"
          )
        )
        expect(OpenStax::Accounts::Api).to receive(:find_or_create_account).with(
          email: 'bob@example.com', username: nil, password: nil,
          first_name: 'Bob', last_name: 'Smith', full_name: 'Bob Smith',
          salesforce_contact_id: 'b0b', faculty_status: :rejected_faculty,
          role: :instructor
        ).and_return(find_or_create_account_response)

        described_class.call(
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
