module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationAccountRepresenter < Roar::Decorator
          include Roar::Representer::JSON

          property :id, 
                   type: Integer

          property :application_id,
                   type: Integer

          property :user,
                   class: OpenStax::Accounts::Account,
                   decorator: AccountRepresenter

          property :unread_updates,
                   type: Integer

          property :default_contact_info_id,
                   type: Integer

        end
      end
    end
  end
end
