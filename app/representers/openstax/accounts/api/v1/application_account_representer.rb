module OpenStax
  module Accounts
    class Api
      module V1
        class ApplicationAccountRepresenter < Roar::Decorator
          include Roar::JSON

          property :id, 
                   type: Integer

          property :application_id,
                   type: Integer

          property :account,
                   as: :user,
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
