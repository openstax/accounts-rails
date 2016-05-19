module OpenStax
  module Accounts
    class CreateGroup

      lev_routine express_output: :group

      protected

      def exec(owner:, name: nil, is_public: false)
        group = OpenStax::Accounts::Group.new(name: name, is_public: is_public)
        group.requestor = owner

        if OpenStax::Accounts.configuration.enable_stubbing? || !owner.has_authenticated?
          group.openstax_uid = -SecureRandom.hex(4).to_i(16)/2
          group.add_owner(owner)
        end

        group.save

        transfer_errors_from(group, {type: :verbatim}, true)
        outputs.group = group
      end

    end
  end
end
