module OpenStax
  module Accounts

    class ApplicationController < ::ActionController::Base

      include Lev::HandleWith

      skip_before_filter :authenticate_user!

    end

  end
end
