module OpenStax
  module Accounts
    module Dev
      class CreateUser
        lev_routine

        protected

        def exec(inputs={})

          username = inputs[:username]

          if username.nil? || inputs[:ensure_no_errors]
            loop do
              break if !username.nil? && OpenStax::Accounts::User.where(username: username).none?
              username = "#{inputs[:username] || 'user'}#{rand(1000000)}"
            end
          end

          outputs[:user] = OpenStax::Accounts::User.create do |user|
            user.first_name = inputs[:first_name]
            user.last_name = inputs[:last_name]
            user.username = username
            user.openstax_uid = available_negative_openstax_uid
          end

          transfer_errors_from(outputs[:user], {type: :verbatim})
        end

        def available_negative_openstax_uid
          (OpenStax::Accounts::User.order("openstax_uid DESC").last.try(:openstax_uid) || 0) - 1
        end

      end
    end
  end
end
