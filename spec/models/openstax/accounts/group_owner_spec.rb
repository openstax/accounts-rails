require 'spec_helper'

module OpenStax::Accounts
  describe GroupOwner do
    context 'validation' do
      it 'requires a unique openstax_uid' do
        group_owner = FactoryGirl.build(:openstax_accounts_group_owner, openstax_uid: nil)
        expect(group_owner).not_to be_valid
        expect(group_owner.errors[:openstax_uid]).to eq(['can\'t be blank'])

        group_owner.openstax_uid = 1
        group_owner.save!

        group_owner_2 = FactoryGirl.build(:openstax_accounts_group_owner, openstax_uid: 1)
        expect(group_owner_2).not_to be_valid
        expect(group_owner_2.errors[:openstax_uid]).to eq(['has already been taken'])
      end
    end
  end
end
