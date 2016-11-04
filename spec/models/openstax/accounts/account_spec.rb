require 'spec_helper'

module OpenStax::Accounts
  describe Account do
    context 'validation' do
      it 'requires a unique openstax_uid, if given' do
        account = FactoryGirl.build(:openstax_accounts_account, openstax_uid: nil)
        expect(account).to be_valid

        account.openstax_uid = 1
        account.save!

        account_2 = FactoryGirl.build(:openstax_accounts_account, openstax_uid: 1)
        expect(account_2).not_to be_valid
        expect(account_2.errors[:openstax_uid]).to eq(['has already been taken'])
      end
    end

    it 'is not anonymous' do
      expect(Account.new.is_anonymous?).to eq false
    end
  end
end
