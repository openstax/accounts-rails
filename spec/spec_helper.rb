ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'factory_bot_rails'
require 'shoulda-matchers'

Rails.backtrace_cleaner.remove_silencers!

ActiveRecord::Migration.maintain_test_schema!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

def mock_omniauth_request(
    id: SecureRandom.random_number(10000000),
    first_name: nil,
    last_name: nil,
    name: nil,
    full_name: nil,
    title: nil,
    username: nil,
    uuid: SecureRandom.uuid,
    support_identifier: "cs_#{SecureRandom.hex(4)}",
    faculty_status: 'no_faculty_info',
    self_reported_role: 'unknown_role',
    school_type: 'unknown_school_type',
    salesforce_contact_id: nil
  )
  bd = binding
  raw_info = {}
  # https://stackoverflow.com/a/31234292
  method(__method__).parameters.each do |_, name|
    value = bd.local_variable_get(name)
    next if value.nil?

    raw_info[name] = value
  end

  info = raw_info.slice(:name, :first_name, :last_name, :title).merge(nickname: raw_info[:username])

  OpenStruct.new(
    env: {
      'omniauth.auth' => OpenStruct.new(
        uid: raw_info[:id],
        provider: 'openstax',
        info: OpenStruct.new(info),
        credentials: OpenStruct.new(access_token: 'foo'),
        extra: OpenStruct.new(raw_info: raw_info)
      )
    }
  )
end

def with_stubbing(value)
  begin
    original = OpenStax::Accounts.configuration.enable_stubbing
    OpenStax::Accounts.configuration.enable_stubbing = value
    yield
  ensure
    OpenStax::Accounts.configuration.enable_stubbing = original
  end
end

def silence_omniauth
  previous_logger = OmniAuth.config.logger
  OmniAuth.config.logger = Logger.new("/dev/null")
  yield
ensure
  OmniAuth.config.logger = previous_logger
end
