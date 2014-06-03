require 'spec_helper'

module OpenStax::Accounts
  describe AnonymousAccount do
    it 'is anonymous' do
      expect(AnonymousAccount.instance.is_anonymous?).to be_true
    end
  end
end
