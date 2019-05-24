module OpenStax
  module Accounts
    class FindOrCreateFromSso

      lev_routine express_output: :account

      def exec(attrs)
        attrs.stringify_keys!
        uid = attrs.delete('id')
        uuid = attrs.delete('uuid')
        account = Account.find_or_initialize_by(
          uuid: uuid, openstax_uid: uid
        )
        account.update_attributes!(
          attrs.slice(*Account.column_names)
        )
        transfer_errors_from(account, {type: :verbatim})
        outputs.account = account
      end

    end
  end
end
