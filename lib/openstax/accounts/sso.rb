require 'cgi'
require 'json'
require 'active_support'
require 'openssl'
require 'base64'


module OpenStax
  module Accounts
    module Sso

      class InvalidSecretsConfiguration < StandardError; end

      extend self

      def user_uuid(request)
        decrypt(request)['user_uuid']
      end

      # https://github.com/rails/rails/blob/4-2-stable/activesupport/lib/active_support/message_encryptor.rb#L90
      def decrypt(request)
        cookie = request.cookies[OpenStax::Accounts.configuration.sso_cookie_name]
        return {} unless cookie.present?

        begin
          encryptor.decrypt_and_verify(cookie)
        rescue ActiveSupport::MessageVerifier::InvalidSignature, InvalidSecretsConfiguration
          {}
        end

      end

      private

      def encryptor
        @encryptor ||= (
          key = OpenStax::Accounts.configuration.sso_secret_key
          raise InvalidSecretsConfiguration, 'Missing sso_secret_key configuration' if key.blank?

          salt          = OpenStax::Accounts.configuration.sso_secret_salt
          signed_salt   = "signed encrypted #{salt}"
          key_generator = ActiveSupport::KeyGenerator.new(key, iterations: 1000)
          secret        = key_generator.generate_key(salt)[0, OpenSSL::Cipher.new('aes-256-cbc').key_len]
          sign_secret   = key_generator.generate_key(signed_salt)
          ActiveSupport::MessageEncryptor.new(secret, sign_secret, serializer: JSON)
        )
      end

    end
  end
end
