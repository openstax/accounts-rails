require_dependency "openstax/connect/application_controller"

module OpenStax
  module Connect
    module Dev
      class DevController < ApplicationController

        before_filter Proc.new{ 
          raise SecurityTransgression if Rails.env.production?
        }
        
      end
    end
  end
end