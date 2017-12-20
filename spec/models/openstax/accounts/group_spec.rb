require 'spec_helper'

module OpenStax::Accounts
  RSpec.describe Group, type: :model do
    context 'validation' do
      it 'requires a unique openstax_uid' do
        group = FactoryBot.build(:openstax_accounts_group, openstax_uid: nil)
        expect(group).not_to be_valid
        expect(group.errors[:openstax_uid]).to eq(['can\'t be blank'])

        group.openstax_uid = 1
        group.save!

        group_2 = FactoryBot.build(:openstax_accounts_group, openstax_uid: 1)
        expect(group_2).not_to be_valid
        expect(group_2.errors[:openstax_uid]).to eq(['has already been taken'])
      end
    end

    context 'no stubbing' do
      before(:all)     do
        @stubbing = OpenStax::Accounts.configuration.enable_stubbing?
        OpenStax::Accounts.configuration.enable_stubbing = false
      end

      after(:all)      { OpenStax::Accounts.configuration.enable_stubbing = @stubbing }

      let!(:requestor) { FactoryBot.create(:openstax_accounts_account) }
      let!(:group)     do
        FactoryBot.build(:openstax_accounts_group).tap{ |group| group.requestor = requestor }
      end

      it 'calls OpenStax Accounts when created' do
        expect(OpenStax::Accounts::Api).to receive(:create_group).with(requestor, group)
        group.save!
      end

      it 'fails to save if the requestor is nil' do
        group.requestor = nil
        expect(OpenStax::Accounts::Api).not_to receive(:create_group)
        expect(group.save).to eq false
      end

      it 'does not call OpenStax Accounts if the requestor is temp' do
        group.requestor.access_token = nil
        expect(OpenStax::Accounts::Api).not_to receive(:create_group)
        group.save!
      end
    end
  end
end
