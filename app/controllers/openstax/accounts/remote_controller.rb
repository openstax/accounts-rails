module OpenStax
  module Accounts
    class RemoteController < OpenStax::Accounts::ApplicationController

      def loader
        respond_to do |format|
          format.js
        end
      end

    end
  end
end
