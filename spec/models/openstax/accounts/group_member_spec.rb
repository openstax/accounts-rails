require 'spec_helper'

module OpenStax::Accounts
  describe GroupMember do
    context 'validation' do
      it 'requires a unique openstax_uid' do
        group_member = FactoryGirl.build(:openstax_accounts_group_member, openstax_uid: nil)
        expect(group_member).not_to be_valid
        expect(group_member.errors[:openstax_uid]).to eq(['can\'t be blank'])

        group_member.openstax_uid = 1
        group_member.save!

        group_member_2 = FactoryGirl.build(:openstax_accounts_group_member, openstax_uid: 1)
        expect(group_member_2).not_to be_valid
        expect(group_member_2.errors[:openstax_uid]).to eq(['has already been taken'])
      end
    end
  end
end
