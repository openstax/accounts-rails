module OpenStax
  module Accounts
    class Api
      module V1
        class ApplicationGroupRepresenter < Roar::Decorator
          include Roar::JSON

          property :id, 
                   type: Integer

          property :application_id,
                   type: Integer

          property :group,
                   class: OpenStax::Accounts::Group,
                   decorator: GroupRepresenter

          property :unread_updates,
                   type: Integer

        end
      end
    end
  end
end
