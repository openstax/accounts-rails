module OpenStax
  module Accounts

    class ApplicationController < ActionController::Base

      include Lev::HandleWith

      acts_as_interceptor :override_url_options => false

      skip_interceptor :authenticate_user!

    end

  end
end
