ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'factory_girl_rails'

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


def mock_omniauth_request(uid: nil, first_name: nil, last_name: nil, title: nil, nickname: nil, faculty_status: nil)
  extra_hash = {
    'raw_info' => {
      'faculty_status' => faculty_status
    }
  }

  OpenStruct.new(
    env: {
      'omniauth.auth' => OpenStruct.new({
        uid: uid || SecureRandom.hex(4),
        provider: "openstax",
        info: OpenStruct.new({
          nickname: nickname || "",
          first_name: first_name || "",
          last_name: last_name || "",
          title: title || ""
        }),
        credentials: OpenStruct.new({
          access_token: "foo"
        }),
        extra: OpenStruct.new(extra_hash)
      })
    }
  )
end

def remove_faculty_status!(omniauth_request)
  omniauth_request.env["omniauth.auth"].extra.raw_info.delete("faculty_status")
end

def remove_nickname!(omniauth_request)
  omniauth_request.env["omniauth.auth"].info.nickname = nil
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
