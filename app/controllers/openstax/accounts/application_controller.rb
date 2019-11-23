module OpenStax
  module Accounts
    class ApplicationController < ::ActionController::Base
      include Lev::HandleWith

      skip_before_action :authenticate_user!, raise: false

      def configuration
        OpenStax::Accounts.configuration
      end
    end
  end
end
