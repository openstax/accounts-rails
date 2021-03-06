FactoryBot.define do
  factory :openstax_accounts_account, class: OpenStax::Accounts::Account do
    openstax_uid       { -SecureRandom.hex(4).to_i(16)/2 }
    username           { SecureRandom.hex.to_s }
    access_token       { SecureRandom.hex.to_s }
    faculty_status     { OpenStax::Accounts::Account.faculty_statuses[:no_faculty_info] }
    role               { OpenStax::Accounts::Account.roles[:unknown_role] }
    school_type        { OpenStax::Accounts::Account.school_types[:unknown_school_type] }
    school_location    { OpenStax::Accounts::Account.school_locations[:unknown_school_location] }
    uuid               { SecureRandom.uuid }
    support_identifier { "cs_#{SecureRandom.hex(4)}" }
    is_test            { true }
  end
end
