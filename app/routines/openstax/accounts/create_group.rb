module OpenStax
  module Accounts
    class CreateGroup

      lev_routine outputs: { group: :_self }

      protected

      def exec(owner:, name: nil, is_public: false)
        group = OpenStax::Accounts::Group.new(name: name, is_public: is_public)
        group.requestor = owner
        group.add_member(owner)
        group.add_owner(owner)

        group.openstax_uid = -SecureRandom.hex(4).to_i(16)/2 \
          if OpenStax::Accounts.configuration.enable_stubbing? || !owner.has_authenticated?

        group.save

        transfer_errors_from(group, {type: :verbatim}, true)
        set(group: group)
      end

    end
  end
end
