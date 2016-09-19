require 'omniauth'
require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Openstax < OAuth2
      option :name, "openstax"

      option :client_options, {
        :site => "http://accounts.openstax.org",
        :authorize_url => "/oauth/authorize"
      }

      uid { raw_info["id"] }

      info do
        username = raw_info["username"]
        title = raw_info["title"]
        first_name = raw_info["first_name"]
        last_name = raw_info["last_name"]
        full_name = raw_info["full_name"] || "#{first_name} #{last_name}"
        full_name = username if full_name.blank?

        # Changed to conform to the omniauth schema
        {
          name: full_name,
          nickname: username,
          first_name: first_name,
          last_name: last_name,
          title: title
        }
      end

      extra do
        hash = {}
        hash['raw_info'] = raw_info
        prune! hash
      end

      def raw_info
        @raw_info ||= access_token.get('/api/user.json').parsed
      end

      protected

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end

    end
  end
end
