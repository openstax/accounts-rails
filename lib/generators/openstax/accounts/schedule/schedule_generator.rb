# Can't use OpenStax. See https://github.com/rails/rails/issues/13856
module Openstax
  module Accounts
    class ScheduleGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def generate_schedule
        copy_file 'schedule.rb', 'config/schedule.rb'
      end
    end
  end
end
