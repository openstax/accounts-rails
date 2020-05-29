module OpenStax
  module Accounts
    class FindOrCreateAccount
      lev_routine

      protected

      def exec(email: nil, username: nil, password: nil, first_name: nil, last_name: nil,
               full_name: nil, title: nil, salesforce_contact_id: nil, faculty_status: nil,
               role: nil, school_type: nil, school_location: nil, is_test: nil)
        raise(
          ArgumentError,
          'You must specify either an email address or a username (and an optional password)'
        ) if email.nil? && username.nil?

        if OpenStax::Accounts.configuration.enable_stubbing
          # We can only stub finding by username b/c accounts-rails doesn't persist emails
          uuid = Account.find_by(username: username)&.uuid || SecureRandom.uuid
          openstax_uid = -SecureRandom.hex(4).to_i(16)/2
          support_identifier = "cs_#{SecureRandom.hex(4)}"
        else
          response = OpenStax::Accounts::Api.find_or_create_account(
            email: email, username: username, password: password,
            first_name: first_name, last_name: last_name, full_name: full_name,
            salesforce_contact_id: salesforce_contact_id, faculty_status: faculty_status,
            role: role, school_type: school_type, school_location: school_location, is_test: is_test
          )
          fatal_error(code: :invalid_inputs) unless (200..202).include?(response.status)

          struct = OpenStruct.new
          Api::V1::UnclaimedAccountRepresenter.new(struct).from_json(response.body)
          openstax_uid = struct.id
          uuid = struct.uuid
          support_identifier = struct.support_identifier
        end

        outputs.account = Account.find_or_create_by(uuid: uuid) do |account|
          account.openstax_uid = openstax_uid
          account.username = username
          account.first_name = first_name
          account.last_name = last_name
          account.full_name = full_name
          account.title = title
          account.salesforce_contact_id = salesforce_contact_id
          account.faculty_status = faculty_status || :no_faculty_info
          account.role = role || :unknown_role
          account.school_type = school_type || :unknown_school_type
          account.school_location = school_location || :unknown_school_location
          account.support_identifier = support_identifier
          account.is_test = is_test
        end

        transfer_errors_from outputs.account, { type: :verbatim }, true
      end
    end
  end
end
