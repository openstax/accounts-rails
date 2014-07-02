require 'spec_helper'

module OpenStax::Accounts
  describe SessionsController do
    routes { Engine.routes }

    let!(:account) { FactoryGirl.create :openstax_accounts_account,
                                        username: 'some_user',
                                        openstax_uid: 10 }

    it 'should redirect users to the login path' do
      c = controller
      get :new
      expect(response).to redirect_to(
        c.send(:with_interceptor) { c.dev_accounts_path })
      expect(response.code).to eq('302')
    end

    it 'should authenticate users based on the oauth callback' do
      # TODO
    end

    it 'should let users logout' do
      controller.sign_in account
      expect(controller.current_account).to eq(account)
      expect(controller.current_account.is_anonymous?).to eq(false)
      delete :destroy
      expect(controller.current_account).to eq(AnonymousAccount.instance)
      expect(controller.current_account.is_anonymous?).to eq(true)
    end
  end
end
