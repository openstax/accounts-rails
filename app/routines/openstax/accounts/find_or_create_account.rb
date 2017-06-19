module OpenStax
  module Accounts
    class FindOrCreateAccount

      lev_routine

      protected

      def exec(email: nil, username: nil, password: nil,
               first_name: nil, last_name: nil, full_name: nil, title: nil,
               salesforce_contact_id: nil, faculty_status: nil, role: nil)
        raise ArgumentError,
              'You must specify either an email address or a username (and an optional password)' \
                if email.nil? && username.nil?

        if OpenStax::Accounts.configuration.enable_stubbing
          # We can only stub finding by username b/c accounts-rails doesn't persist emails
          id = Account.find_by(username: username).try!(:openstax_uid) ||
               -SecureRandom.hex(4).to_i(16)/2
          uuid = SecureRandom.uuid
        else
          response = Api.find_or_create_account(
            email: email, username: username, password: password,
            first_name: first_name, last_name: last_name, full_name: full_name,
            salesforce_contact_id: salesforce_contact_id, faculty_status: faculty_status,
            role: role)
          fatal_error(code: :invalid_inputs) unless (200..202).include?(response.status)

          struct = OpenStruct.new
          Api::V1::UnclaimedAccountRepresenter.new(struct).from_json(response.body)
          id = struct.id
          uuid = struct.uuid
        end

        account = Account.find_or_initialize_by(openstax_uid: id)

        unless account.persisted?
          while username.nil? || Account.where(username: username).exists? do
            username = SecureRandom.hex(3).to_s
          end
          account.username = username
          account.first_name = first_name
          account.last_name = last_name
          account.full_name = full_name
          account.title = title
          account.salesforce_contact_id = salesforce_contact_id
          account.faculty_status = faculty_status || :no_faculty_info
          account.role = role || :unknown_role
          account.uuid = uuid
          account.save!
        end

        transfer_errors_from(account, {type: :verbatim}, true)
        outputs[:account] = account
      end

    end
  end
end
