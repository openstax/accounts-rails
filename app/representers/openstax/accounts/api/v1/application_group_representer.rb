module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationGroupRepresenter < Roar::Decorator
          include Roar::Representer::JSON

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
