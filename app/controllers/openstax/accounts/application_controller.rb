module OpenStax
  module Accounts

    class ApplicationController < ::ActionController::Base

      include Lev::HandleWith

      def configuration
        OpenStax::Accounts.configuration
      end

    end

  end
end
