module OpenStax
  module Accounts
    module Dev
      class BaseController < OpenStax::Accounts::ApplicationController

        before_filter Proc.new{
          raise SecurityTransgression if Rails.env.production?
        }

        skip_before_filter :authenticate_user!
        skip_before_filter :require_registration!

        fine_print_skip_signatures :general_terms_of_use, :privacy_policy

      end
    end
  end
end
