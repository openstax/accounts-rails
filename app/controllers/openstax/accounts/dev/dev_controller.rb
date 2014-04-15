module OpenStax
  module Accounts
    module Dev
      class DevController < OpenStax::Accounts::ApplicationController

        before_filter Proc.new{ 
          raise SecurityTransgression if Rails.env.production?
        }
        
      end
    end
  end
end