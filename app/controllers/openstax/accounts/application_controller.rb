module OpenStax
  module Accounts

    class ApplicationController < ActionController::Base

      include Lev::HandleWith

      acts_as_interceptor :override_url_options => false

      skip_interceptor :authenticate_user!, :registration

      fine_print_skip_signatures :general_terms_of_use, :privacy_policy \
        if respond_to?(:fine_print_skip_signatures)

    end

  end
end
