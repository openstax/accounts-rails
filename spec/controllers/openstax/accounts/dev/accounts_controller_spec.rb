require 'spec_helper'

module OpenStax::Accounts
  module Dev
    RSpec.describe AccountsController, type: :controller do
      routes { Engine.routes }

      let!(:account) { FactoryBot.create :openstax_accounts_account,
                                          username: 'some_user',
                                          openstax_uid: 10 }

      it 'should allow users not in production to become other users' do
        expect(controller.current_account).to eq(AnonymousAccount.instance)
        expect(controller.current_account.is_anonymous?).to eq(true)
        post :become, params: { id: account.openstax_uid }
        expect(controller.current_account).to eq(account)
        expect(controller.current_account.is_anonymous?).to eq(false)
      end

      it 'should not set X-Frame-Options header' do
        get :index
        expect(response.header['X-Frame-Options']).to be_nil
      end

    end
  end
end
