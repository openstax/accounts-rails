require 'spec_helper'

module OpenStax::Accounts
  module Dev
    describe UsersController do
      routes { OpenStax::Accounts::Engine.routes }

      let!(:user) { OpenStax::Accounts::User.create(username: 'some_user',
                                                    openstax_uid: 1) }

      it 'should allow users not in production to become other users' do
        expect(controller.current_user).to eq(OpenStax::Accounts::User.anonymous)
        expect(controller.current_user.is_anonymous?).to eq(true)
        get :become, user_id: user.id
        expect(controller.current_user).to eq(user)
        expect(controller.current_user.is_anonymous?).to eq(false)
      end
    end
  end
end
