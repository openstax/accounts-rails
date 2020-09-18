require 'omniauth'
require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Openstax < OAuth2
      option :name, "openstax"

      option :client_options, {
        site: "http://accounts.openstax.org",
        authorize_url: "/oauth/authorize"
      }

      uid { raw_info[:uuid] }

      info do
        # Changed to conform to the omniauth schema
        raw_info.slice(:name, :first_name, :last_name, :title).merge(nickname: raw_info[:username])
      end

      extra { { raw_info: raw_info } }

      def raw_info
        @raw_info ||= access_token.get('/api/user.json').parsed.symbolize_keys
      end

      protected

      def ssl?
        return true if Rails.env.production?

        super
      end
    end
  end
end
