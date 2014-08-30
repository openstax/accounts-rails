module OpenStax
  module Accounts
    describe CurrentUserManager do
      let!(:account) { FactoryGirl.create(:openstax_accounts_account,
                         username: 'some_user',
                         openstax_uid: 1) }
      let!(:user)    { User.create(:account => account) }

      let!(:request) { double('request',
                              :host => 'localhost',
                              :ssl? => false) }

      let!(:ssl_request) { double('request',
                                  :host => 'localhost',
                                  :ssl? => true) }

      let!(:session) { {} }

      let!(:cookies) { ActionDispatch::Cookies::CookieJar.new(
                         ActiveSupport::KeyGenerator.new(SecureRandom.hex),
                         'localhost', false,
                         encrypted_cookie_salt: 'encrypted cookie salt',
                         encrypted_signed_cookie_salt: 'encrypted signed cookie salt') }

      let!(:current_user_manager) { CurrentUserManager.new(
                                      request, session, cookies) }

      context 'signing in' do

        it 'signs in an account' do
          expect(current_user_manager.signed_in?).to eq(false)
          expect(current_user_manager.current_account).to(
            eq(AnonymousAccount.instance))
          expect(current_user_manager.current_user).to(
            eq(AnonymousUser.instance))

          current_user_manager.sign_in!(account)

          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)
        end

        it 'signs in a user' do
          expect(current_user_manager.signed_in?).to eq(false)
          expect(current_user_manager.current_account).to(
            eq(AnonymousAccount.instance))
          expect(current_user_manager.current_user).to(
            eq(AnonymousUser.instance))

          current_user_manager.sign_in!(user)

          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)
        end

      end

      context 'from session' do

        before(:each) do
          current_user_manager.sign_in!(account)
        end

        it 'keeps a legitimate user signed in' do
          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)

          # Secure cookies are not sent with non-SSL requests
          unsecure_cookies = ActionDispatch::Cookies::CookieJar.new(
                               ActiveSupport::KeyGenerator.new(SecureRandom.hex),
                               'localhost', false,
                               encrypted_cookie_salt: 'encrypted cookie salt',
                               encrypted_signed_cookie_salt: 'encrypted signed cookie salt')
          unsecure_cookies[:account_id] = cookies[:account_id]

          current_user_manager = CurrentUserManager.new(
                                   request, session, unsecure_cookies)

          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)

          # But they are sent with SSL requests
          current_user_manager = CurrentUserManager.new(
                                   ssl_request, session, cookies)

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
          current_user_manager = CurrentUserManager.new(
                                   request, session, cookies)

          expect(current_user_manager.signed_in?).to eq(true)
          expect(current_user_manager.current_account).to eq(account)
          expect(current_user_manager.current_user).to eq(user)

          # But not SSL pages
          current_user_manager = CurrentUserManager.new(
                                   ssl_request, session, cookies)

          expect(current_user_manager.signed_in?).to eq(false)
          expect(current_user_manager.current_account).to(
            eq(AnonymousAccount.instance))
          expect(current_user_manager.current_user).to(
            eq(AnonymousUser.instance))

          # And after they logout, that's it
          current_user_manager = CurrentUserManager.new(
                                   request, session, cookies)

          expect(current_user_manager.signed_in?).to eq(false)
          expect(current_user_manager.current_account).to(
            eq(AnonymousAccount.instance))
          expect(current_user_manager.current_user).to(
            eq(AnonymousUser.instance))
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
          expect(current_user_manager.current_account).to(
            eq(AnonymousAccount.instance))
          expect(current_user_manager.current_user).to(
            eq(AnonymousUser.instance))
        end

      end

    end
  end
end
