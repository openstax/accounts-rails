require 'spec_helper'

module OpenStax::Accounts
  describe Group do
    context 'validation' do
      it 'requires a unique openstax_uid' do
        group = FactoryGirl.build(:openstax_accounts_group, openstax_uid: nil)
        expect(group).not_to be_valid
        expect(group.errors[:openstax_uid]).to eq(['can\'t be blank'])

        group.openstax_uid = 1
        group.save!

        group_2 = FactoryGirl.build(:openstax_accounts_group, openstax_uid: 1)
        expect(group_2).not_to be_valid
        expect(group_2.errors[:openstax_uid]).to eq(['has already been taken'])
      end
    end
  end
end
