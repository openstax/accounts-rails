require 'spec_helper'
require_relative 'search_accounts_shared_examples'

RSpec.describe OpenStax::Accounts::SearchLocalAccounts, type: :routine do
  include_examples 'search accounts'
end
