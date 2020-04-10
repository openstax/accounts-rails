require 'spec_helper'

module OpenStax::Accounts
  RSpec.describe SessionsController, type: :controller do
    routes { Engine.routes }

    let!(:account) { FactoryBot.create :openstax_accounts_account,
                                        username: 'some_user',
                                        openstax_uid: 10 }

    after(:all) {
      OpenStax::Accounts.configuration.logout_redirect_url = nil
      OpenStax::Accounts.configuration.return_to_url_approver = nil
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

    it 'should store specified url for redirection after to login if approved' do
      OpenStax::Accounts.configuration.return_to_url_approver = ->(url) { true }
      allow(OpenStax::Accounts.configuration).to receive(:enable_stubbing?) {false}
      get :new, params: { return_to: "https://woohoo" }
      expect(session["accounts_return_to"]).to eq "https://woohoo"
    end

    it 'should not store specified url for redirection after login if not approved' do
      OpenStax::Accounts.configuration.return_to_url_approver = ->(url) { false }
      allow(OpenStax::Accounts.configuration).to receive(:enable_stubbing?) {false}
      get :new, params: { return_to: "https://woohoo" }
      expect(session["accounts_return_to"]).to eq nil
    end

    it 'should give the return_to url to the config approver' do
      my_lambda = ->(url) { true }
      OpenStax::Accounts.configuration.return_to_url_approver = my_lambda

      allow(OpenStax::Accounts.configuration).to receive(:enable_stubbing?) {false}
      expect(my_lambda).to receive(:call).with("http://jimmy")

      get :new, params: { return_to: 'http://jimmy' }
    end

    it 'should include sp param hash when redirecting' do
      allow(OpenStax::Accounts.configuration).to receive(:enable_stubbing?) {false}
      params = { sp: { foo: 'bar', test: 'true' } }
      get :new, params: params
      expect(response).to redirect_to(controller.openstax_login_path(params))
    end

  end
end
