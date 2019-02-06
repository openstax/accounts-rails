require 'spec_helper'
require 'vcr_helper'

module OpenStax
  module Accounts

    RSpec.describe FindOrCreateFromSso, type: :routine, vcr: VCR_OPTS do

      let(:attributes) {
        { id: 1, username: 'admin', uuid: '4ad8b085-a999-4a16-93a0-d78d4f21aba2',
          first_name: 'Admin', last_name: 'Admin' }
      }

      it 'creates new accounts' do
        account = described_class.call(attributes).outputs.account
        expect(account).not_to be_new_record
        expect(account.errors).to be_empty
      end

      it 'updates existing accounts' do
        account = Account.create!(attributes.except(:id).merge(openstax_uid: 1))
        described_class.call(
          attributes.merge(first_name: 'Bob')
        ).outputs.account
        expect(account.reload.first_name).to eq 'Bob'
      end

    end
  end
end
