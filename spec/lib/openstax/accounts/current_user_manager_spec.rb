require_relative '../../../spec_helper'

module OpenStax
  module Accounts
    RSpec.describe CurrentUserManager do
      let!(:account) { FactoryBot.create(:openstax_accounts_account,
                                         username: 'some_user',
                                         uuid: '4ad8b085-a999-4a16-93a0-d78d4f21aba2',
                                         openstax_uid: 1) }
      let!(:user)    { User.create(:account => account) }

      let!(:request) { double('request',
                              :cookies => {},
                              :host => 'localhost',
                              :ssl? => false) }

      let!(:ssl_request) { double('request',
                                  :cookies => {},
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

      context 'using sso' do
        let!(:request) { double('request',
                                :cookies => {
                                  'ox' => 'MnJMZ1gzdWJhVHR6eVQ4N2NqdDBxQ1RYMHU2NU1PLzVqZmdtUzRZSEI2YURIZ1NtV1RrU091UVBtOFV5RGRMQVVZN2plM1BlMVo1d0p5YUwxaWZQaW95RVFsUnlIaDZ4L3RIcDd2ZzlwQndJbVo3SU5lbUtuUUx6eXAyenZJUENDUzRSTndkNmdXTXNBTHFNL1VNbUEvSmthUnlLeGlqeUpWelc1YndCM29VPS0tYmZlcXliaXE4UWR6SXlhZEt4UklFZz09--dcd97b632fe6e700dc4e8629e70a66ee091d4f5d'
                                },
                                :host => 'localhost',
                                :ssl? => false) }

        it 'signs in a user' do
          expect(OpenStax::Accounts.configuration).to(
            receive(:sso_secret_key).at_most(:once).and_return('1234567890abcd')
          )
          expect(current_user_manager.signed_in?).to eq(true)
          expect(
            current_user_manager.current_account.attributes
          ).to include({
                         openstax_uid: 1, username: 'admin', uuid: '4ad8b085-a999-4a16-93a0-d78d4f21aba2',
                         first_name: 'Admin', last_name: 'Admin'
                       }.stringify_keys)
        end

        it 'is ignored if its invalid' do
          expect(OpenStax::Accounts.configuration).to receive(:sso_secret_key).and_return 'a-bad-secret-key'
          OpenStax::Accounts::Sso.remove_instance_variable(:@encryptor) if OpenStax::Accounts::Sso.instance_variable_defined? :@encryptor
          expect(current_user_manager.signed_in?).to eq(false)
          OpenStax::Accounts::Sso.remove_instance_variable(:@encryptor)
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
