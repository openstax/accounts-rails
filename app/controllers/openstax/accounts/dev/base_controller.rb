module OpenStax
  module Accounts
    module Dev
      class BaseController < OpenStax::Accounts::ApplicationController

        before_filter do
          raise SecurityTransgression if Rails.env.production?
        end

      end
    end
  end
end
