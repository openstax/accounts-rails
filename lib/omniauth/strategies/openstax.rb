require 'omniauth'
require 'omniauth-oauth2'
require 'omniauth/rails_csrf_protection'

module OmniAuth
  module Strategies
    class Openstax < OAuth2
      option :name, 'openstax'

      option :client_options, {
        authorize_url: 'oauth/authorize',
        token_url: 'oauth/token'
      }

      uid { raw_info[:uuid] }

      info do
        # Changed to conform to the omniauth schema
        raw_info.slice(:name, :first_name, :last_name, :title).merge(nickname: raw_info[:username])
      end

      extra { { raw_info: raw_info } }

      def raw_info
        @raw_info ||= access_token.get('api/user.json').parsed.symbolize_keys
      end
    end
  end
end
