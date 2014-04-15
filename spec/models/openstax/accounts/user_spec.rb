require 'spec_helper'

module OpenStax::Accounts
  describe User do
    it 'can return an AnonymousUser' do
      anon = User.anonymous
      expect(anon.is_anonymous?).to eq true
      expect(anon.first_name).to eq 'Guest'
      expect(anon.last_name).to eq 'User'
      expect(anon.openstax_uid).to be_nil
    end
  end
end
