require 'spec_helper'

module OpenStax::Accounts
  describe SessionsController, type: :controller do
    routes { Engine.routes }

    let!(:account) { FactoryGirl.create :openstax_accounts_account,
                                        username: 'some_user',
                                        openstax_uid: 10 }

    after(:all) {
      OpenStax::Accounts.configuration.logout_redirect_url = nil
    }

    it 'should redirect users to the login path' do
      c = controller
      get :new
      expect(response).to redirect_to(c.dev_accounts_path)
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

    it 'should get signout redirect URL from configured setting' do
      my_lambda = ->(request) { "http://www.google.com" }
      OpenStax::Accounts.configuration.logout_redirect_url = my_lambda

      allow(OpenStax::Accounts.configuration).to receive(:enable_stubbing?) {false}
      expect(my_lambda).to receive(:call).with(anything())

      controller.sign_in account
      delete :destroy
    end
  end
end
