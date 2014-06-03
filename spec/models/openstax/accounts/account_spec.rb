require 'spec_helper'

module OpenStax::Accounts
  describe Account do
    it 'is not anonymous' do
      expect(Account.new.is_anonymous?).to be_false
    end
  end
end
