require 'spec_helper'

module OpenStax::Accounts
  RSpec.describe AnonymousAccount, type: :model do
    it 'is anonymous' do
      expect(AnonymousAccount.instance.is_anonymous?).to eq true
    end
  end
end
