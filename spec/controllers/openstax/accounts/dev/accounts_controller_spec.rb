require 'spec_helper'

module OpenStax::Accounts
  module Dev
    describe AccountsController, type: :controller do
      routes { Engine.routes }

      let!(:account) { FactoryGirl.create :openstax_accounts_account,
                                          username: 'some_user',
                                          openstax_uid: 10 }

      it 'should allow users not in production to become other users' do
        expect(controller.current_account).to eq(AnonymousAccount.instance)
        expect(controller.current_account.is_anonymous?).to eq(true)
        post :become, id: account.id
        expect(controller.current_account).to eq(account)
        expect(controller.current_account.is_anonymous?).to eq(false)
      end
    end
  end
end
