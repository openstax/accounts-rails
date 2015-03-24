module OpenStax
  module Accounts
    module Api
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
                   decorator: AccountRepresenter,
                   instance: ->(*) {
                     a = OpenStax::Accounts::Account.new
                     a.syncing = true
                     a
                   }

          property :unread_updates,
                   type: Integer

          property :default_contact_info_id,
                   type: Integer

        end
      end
    end
  end
end
