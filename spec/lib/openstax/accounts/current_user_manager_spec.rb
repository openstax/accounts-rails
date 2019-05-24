require 'spec_helper'

module OpenStax
  module Accounts
    RSpec.describe CurrentUserManager do
      let(:account) do
        FactoryBot.create(
          :openstax_accounts_account,
          username: 'some_user',
          uuid: '4ad8b085-a999-4a16-93a0-d78d4f21aba2',
          openstax_uid: 1
        )
      end
      let!(:user)    { User.create(account: account) }

      let(:request) { ::ActionController::TestRequest.create(host: 'localhost') }

      let(:session) { request.session }

      let(:cookies) { ActionDispatch::Cookies::CookieJar.new(request) }

      let(:current_user_manager) { CurrentUserManager.new(request, session, cookies) }

      context 'signing in' do

        it 'signs in an account' do
          expect(current_user_manager.signed_in?).to eq(false)
          expect(current_user_manager.current_account).to eq(AnonymousAccount.instance)
          expect(current_user_manager.current_user).to eq(AnonymousUser.instance)

          current_user_manager.sign_in!(account)

          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)
        end

        it 'signs in a user' do
          expect(current_user_manager.signed_in?).to eq(false)
          expect(current_user_manager.current_account).to eq(AnonymousAccount.instance)
          expect(current_user_manager.current_user).to eq(AnonymousUser.instance)

          current_user_manager.sign_in!(user)

          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)
        end

      end

      context 'from session' do

        before(:each) { current_user_manager.sign_in!(account) }

        it 'keeps a legitimate user signed in' do
          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)

          # Secure cookies are not sent with non-SSL requests
          current_user_manager = CurrentUserManager.new(request, session, cookies)

          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)

          # But they are sent with SSL requests
          expect(request).to receive(:ssl?).at_least(:once).and_return(true)
          current_user_manager = CurrentUserManager.new(request, session, cookies)

          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)
        end

        it 'signs out an attacker attempting to hijack the session' do
          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)

          # The protection relies on the attacker not being
          # able to get the secure cookies
          cookies.delete(:secure_account_id)

          # The attacker can still access non-SSL pages
          current_user_manager = CurrentUserManager.new(request, session, cookies)

          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)

          # But not SSL pages
          expect(request).to receive(:ssl?).at_least(:once).and_return(true)
          current_user_manager = CurrentUserManager.new(request, session, cookies)

          expect(current_user_manager.signed_in?).to eq(false)
          expect(current_user_manager.current_account).to eq(AnonymousAccount.instance)
          expect(current_user_manager.current_user).to eq(AnonymousUser.instance)

          # And after they logout, that's it
          current_user_manager = CurrentUserManager.new(request, session, cookies)

          expect(current_user_manager.signed_in?).to eq(false)
          expect(current_user_manager.current_account).to eq(AnonymousAccount.instance)
          expect(current_user_manager.current_user).to eq(AnonymousUser.instance)
        end

      end

      context 'using sso' do
        before do
          request.cookies['ox'] = 'rHYo4mcrfC7q4zwvONJwUFXn2jAFvstsGGcdPsOUcQO6RYT/BgZdOn9ZCv+OSxRb+eX9O+MHVYVJp4kwD8jnJTq1TfHLcetn0JoRlpYhx9yzU7GynvPa+6Am3McHhOkuA6FNYne184DCBru16e1YUiIB+UdII9GKsIkP--ZhszDn22tN9eASU0--o/AVN/yMC2NM0Uhba3yIZw=='
        end

        it 'signs in a user' do
          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account.attributes).to include(
            {
              openstax_uid: 1,
              username: 'admin',
              uuid: '4ad8b085-a999-4a16-93a0-d78d4f21aba2',
              first_name: 'Admin',
              last_name: 'Admin'
            }.stringify_keys
          )
        end

        context 'with an invalid sso cookie' do
          before      do
            expect(OpenStax::Accounts.configuration).to(
              receive(:sso_secret_key).once.and_return 'a-bad-secret-key'
            )
            OpenStax::Accounts::Sso.send :reset_config
          end
          after(:all) { OpenStax::Accounts::Sso.send :reset_config }

          it 'is ignored' do
            expect(current_user_manager.signed_in?).to eq(false)
          end
        end

      end

      context 'signing out' do

        before(:each) { current_user_manager.sign_in!(account) }

        it 'signs out users' do
          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)

          current_user_manager.sign_out!

          expect(current_user_manager.signed_in?).to eq(false)
          expect(current_user_manager.current_account).to eq(AnonymousAccount.instance)
          expect(current_user_manager.current_user).to eq(AnonymousUser.instance)
        end

      end

    end
  end
end
