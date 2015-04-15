# Routine for creating a temporary account by email or username

module OpenStax
  module Accounts
    class CreateTempAccount

      lev_routine
            
      protected

      def exec(inputs={})
        response = Api.create_temp_account(inputs)
        fatal_error(code: :invalid_inputs) unless response.status == 200

        struct = OpenStruct.new
        Api::V1::UnclaimedAccountRepresenter.new(struct).from_json(response.body)
        id = struct.id

        account = Account.find_or_initialize_by(openstax_uid: id)

        unless account.persisted?
          username = inputs[:username]
          while username.nil? || Account.where(username: username).exists? do 
            username = SecureRandom.hex(3).to_s
          end
          account.username = username
          account.save!
        end

        transfer_errors_from(account, {type: :verbatim}, true)
        outputs[:account] = account
      end

    end
  end
end
