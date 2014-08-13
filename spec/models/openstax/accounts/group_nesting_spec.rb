require 'spec_helper'

module OpenStax::Accounts
  describe GroupNesting do
    context 'validation' do
      it 'requires a unique openstax_uid' do
        group_nesting = FactoryGirl.build(:openstax_accounts_group_nesting, openstax_uid: nil)
        expect(group_nesting).not_to be_valid
        expect(group_nesting.errors[:openstax_uid]).to eq(['can\'t be blank'])

        group_nesting.openstax_uid = 1
        group_nesting.save!

        group_nesting_2 = FactoryGirl.build(:openstax_accounts_group_nesting, openstax_uid: 1)
        expect(group_nesting_2).not_to be_valid
        expect(group_nesting_2.errors[:openstax_uid]).to eq(['has already been taken'])
      end
    end
  end
end
