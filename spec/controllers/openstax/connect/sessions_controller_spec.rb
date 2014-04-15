require 'spec_helper'

module OpenStax::Connect
  describe SessionsController do
    routes { OpenStax::Connect::Engine.routes }

    let!(:user) { OpenStax::Connect::User.create(username: 'some_user', openstax_uid: 1) }

    it 'should redirect users to the login path' do
      get :new
      expect(response).to redirect_to RouteHelper.get_path(:login)
      expect(response.code).to eq('302')
    end

    it 'should authenticate users based on the oauth callback' do
      # TODO
    end

    it 'should let users logout' do
      controller.sign_in user
      expect(controller.current_user).to eq(user)
      expect(controller.current_user.is_anonymous?).to eq(false)
      delete :destroy
      expect(controller.current_user).to eq(OpenStax::Connect::User.anonymous)
      expect(controller.current_user.is_anonymous?).to eq(true)
    end
  end
end
